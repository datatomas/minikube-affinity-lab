# use calico so your node pools will actualy get connectivity to get ready
minikube start \
  --nodes=3 \
  --driver=docker \
  --cni=calico
#enable multinode csi storage drivers and volumesnaphots

minikube addons enable csi-hostpath-driver
minikube addons enable volumesnapshots
#Disable the old Minikube provisioner:
minikube addons disable storage-provisioner
minikube addons disable default-storageclass

#Set CSI hostpath as default:
kubectl patch storageclass csi-hostpath-sc \
  -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'


# label simulated nodes

kubectl label node minikube agentpool=systempool

kubectl label node minikube-m02 agentpool=userpool
kubectl label node minikube-m03 agentpool=userpool

# verify

kubectl get nodes -L agentpool


# verify storage and snapshot classes 
"""you should have
csi-hostpath-sc
csi-hostpath-snapclass
"""
kubectl get storageclass
kubectl get volumesnapshotclass
