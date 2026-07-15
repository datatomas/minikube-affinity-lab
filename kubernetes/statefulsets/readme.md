# StatefulSet, Dynamic Storage, and Volume Snapshots

This lab demonstrates how Kubernetes dynamically provisions persistent storage for StatefulSet replicas using a CSI driver.

The goal is to deploy:

```text
3-node Minikube cluster
        |
        +-- systempool
        |
        +-- userpool
              |
              +-- nginx-stateful-0 -> PVC 0 -> PV 0
              +-- nginx-stateful-1 -> PVC 1 -> PV 1
              +-- nginx-stateful-2 -> PVC 2 -> PV 2
```

The lab also creates a `VolumeSnapshot` and restores the snapshot into a new PVC.

## Static vs Dynamic Provisioning

A PersistentVolume can be provisioned in two main ways.

### Static provisioning

The storage already exists or is explicitly created by an administrator.

```text
Storage administrator
        |
        v
Create disk / file share / NFS export
        |
        v
Create PersistentVolume
        |
        v
PersistentVolumeClaim
        |
        v
Pod
```

Example use cases:

* Existing Azure Managed Disk containing application data.
* Existing Azure File Share.
* Existing NFS export.
* Legacy application migration.
* Storage managed by a dedicated infrastructure or SAN team.
* Importing existing production data into Kubernetes.

In this model, the administrator normally defines the `PersistentVolume`.

### Dynamic provisioning

The application requests storage through a PVC.

```text
PersistentVolumeClaim
        |
        v
StorageClass
        |
        v
CSI provisioner
        |
        +-- Creates the storage
        |
        +-- Creates the PersistentVolume
        |
        v
PVC binds to PV
```

The application does not manually define a `PersistentVolume`.

Example use cases:

* PostgreSQL StatefulSets.
* Kafka brokers.
* Redis persistence.
* Application upload storage.
* New Azure Files shares.
* New Azure Managed Disks.
* K3s workloads using a dynamic provisioner.

For new Kubernetes workloads, dynamic provisioning is generally the preferred pattern when the storage platform supports it.

## Minikube Cluster

Create a three-node Minikube cluster using Calico as the CNI.

```bash
minikube start \
  --nodes=3 \
  --driver=docker \
  --cni=calico
```

Calico provides the CNI networking required for Pods and nodes to communicate correctly.

Verify the nodes:

```bash
kubectl get nodes
```

## CSI Storage and Volume Snapshots

Enable the CSI Hostpath Driver:

```bash
minikube addons enable csi-hostpath-driver
```

Enable Kubernetes VolumeSnapshot support:

```bash
minikube addons enable volumesnapshots
```

Verify the StorageClass:

```bash
kubectl get storageclass
```

Verify the VolumeSnapshotClass:

```bash
kubectl get volumesnapshotclass
```

This lab explicitly requests:

```yaml
storageClassName: csi-hostpath-sc
```

The existing Minikube StorageClass does not need to be disabled because the workload explicitly selects the CSI StorageClass.

## Simulated Node Pools

Minikube does not provide AKS-style node pools.

Node labels are used to simulate them.

Label the control-plane node:

```bash
kubectl label node minikube agentpool=systempool
```

Label the worker nodes:

```bash
kubectl label node minikube-m02 agentpool=userpool

kubectl label node minikube-m03 agentpool=userpool
```

Verify:

```bash
kubectl get nodes -L agentpool
```

Expected topology:

```text
minikube       -> systempool
minikube-m02   -> userpool
minikube-m03   -> userpool
```

The StatefulSet uses:

```yaml
nodeSelector:
  agentpool: userpool
```

This restricts the StatefulSet Pods to nodes labeled as members of the simulated `userpool`.

A `nodeSelector` selects eligible nodes. It does not guarantee even Pod distribution between those nodes.

## Headless Service

StatefulSets use a governing Service to provide stable network identities.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-headless
spec:
  clusterIP: None
  selector:
    app: nginx-stateful
  ports:
    - name: http
      port: 80
      targetPort: 80
```

Apply:

```bash
kubectl apply -f nginx-headless-service.yaml
```

The StatefulSet Pods receive stable identities such as:

```text
nginx-stateful-0.nginx-headless
nginx-stateful-1.nginx-headless
nginx-stateful-2.nginx-headless
```

## StatefulSet and Dynamic PVC Provisioning

The StatefulSet contains a `volumeClaimTemplates` definition.

```yaml
volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes:
        - ReadWriteOnce
      storageClassName: csi-hostpath-sc
      resources:
        requests:
          storage: 1Gi
```

With three replicas:

```yaml
replicas: 3
```

Kubernetes creates three PVCs:

```text
data-nginx-stateful-0
data-nginx-stateful-1
data-nginx-stateful-2
```

The CSI provisioner dynamically creates the backing volumes and their Kubernetes PersistentVolume objects.

```text
nginx-stateful-0
        |
        v
data-nginx-stateful-0
        |
        v
PV dynamically provisioned

nginx-stateful-1
        |
        v
data-nginx-stateful-1
        |
        v
PV dynamically provisioned

nginx-stateful-2
        |
        v
data-nginx-stateful-2
        |
        v
PV dynamically provisioned
```

The PV manifests are not manually created in this lab.

Verify the resources:

```bash
kubectl get pods -o wide

kubectl get pvc

kubectl get pv
```

Watch Pod changes:

```bash
kubectl get pods -o wide -w
```

## Volume Snapshots

Write data to the first StatefulSet replica:

```bash
kubectl exec nginx-stateful-0 -- sh -c \
  'echo "STATEFUL DATA FROM POD 0" > /usr/share/nginx/html/index.html'
```

Verify the data:

```bash
kubectl exec nginx-stateful-0 -- \
  cat /usr/share/nginx/html/index.html
```

Create a snapshot of the first replica's PVC:

```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: nginx-data-0-snapshot
spec:
  volumeSnapshotClassName: csi-hostpath-snapclass
  source:
    persistentVolumeClaimName: data-nginx-stateful-0
```

Apply:

```bash
kubectl apply -f snapshot.yaml
```

Verify:

```bash
kubectl get volumesnapshot
```

Wait until:

```text
READYTOUSE=true
```

## Restore From Snapshot

A snapshot is restored by creating a new PVC and using the `VolumeSnapshot` as its data source.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-data-0-restored
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: csi-hostpath-sc
  resources:
    requests:
      storage: 1Gi
  dataSource:
    name: nginx-data-0-snapshot
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
```

Apply:

```bash
kubectl apply -f restore-pvc.yaml
```

Verify:

```bash
kubectl get pvc
```

The resulting flow is:

```text
Original PVC
     |
     v
VolumeSnapshot
     |
     v
Restored PVC
     |
     v
New dynamically provisioned PV
```

## AKS Comparison

The same Kubernetes storage model applies to AKS.

For Azure Disk, a StatefulSet can request a CSI-backed StorageClass:

```yaml
storageClassName: managed-csi
```

Conceptually:

```text
PVC
 |
 v
Azure Disk StorageClass
 |
 v
Azure Disk CSI Driver
 |
 +-- Creates Azure Managed Disk
 |
 +-- Creates Kubernetes PV
```

Azure Files can also use dynamic provisioning.

```text
PVC
 |
 v
Azure Files StorageClass
 |
 v
Azure Files CSI Driver
 |
 +-- Creates Azure File Share
 |
 +-- Creates Kubernetes PV
```

An existing Azure Disk or Azure File Share can instead be statically provisioned and represented by an administrator-defined PersistentVolume.

## K3s Comparison

K3s includes a local storage provisioner.

A PVC can request dynamically provisioned storage through the `local-path` StorageClass.

```yaml
storageClassName: local-path
```

The flow remains the same:

```text
PVC
 |
 v
StorageClass
 |
 v
Provisioner
 |
 v
PV
```

The storage implementation changes, but the Kubernetes PVC and StorageClass model remains consistent.

## Key Takeaway

Do not associate dynamic provisioning only with block disks.

Both block and shared file storage can support dynamic provisioning.

The deciding question is:

> Should Kubernetes create new storage for this workload, or should Kubernetes attach storage that already exists?

Use dynamic provisioning when Kubernetes should create storage on demand.

Use static provisioning when Kubernetes must consume existing or administrator-controlled storage.
