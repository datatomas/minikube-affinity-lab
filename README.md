# Minikube Affinity Lab

A hands-on Kubernetes lab focused on node labels, node affinity, ReplicaSets, imagePullSecrets, namespaces, and liveness probes using a multi-node Minikube cluster.

## Overview

This lab demonstrates how Kubernetes schedules workloads based on node labels and affinity rules.

The environment includes:

* Multi-node Minikube cluster
* Docker Hub hosted image
* Namespace isolation
* Docker Hub image pull secret
* ReplicaSets
* Node labels
* Node Affinity (`In` and `Exists`)
* Liveness probes
* Container restart behavior

## Architecture

### Nodes

| Node         | Labels               |
| ------------ | -------------------- |
| minikube     | gpu=nvidia           |
| minikube-m02 | gpu=other, cpu=ryzen |

### ReplicaSets

| ReplicaSet    | Affinity Rule   | Expected Node        |
| ------------- | --------------- | -------------------- |
| rs-gpu-nvidia | gpu In [nvidia] | minikube             |
| rs-gpu-exists | gpu Exists      | any GPU labeled node |
| rs-cpu-ryzen  | cpu In [ryzen]  | minikube-m02         |

## Repository Structure

```text
minikube-affinity-lab
├── README.md
│
├── app
│   ├── Dockerfile
│   ├── probe.py
│   └── requirements.txt
│
└── kubernetes
    ├── namespace.yaml
    ├── docker-hub-secret.md
    ├── labels.sh
    ├── deploy.sh
    ├── rs-gpu-nvidia.yaml
    ├── rs-gpu-exists.yaml
    └── rs-cpu-ryzen.yaml
```

## Prerequisites

* Docker
* kubectl
* Minikube
* Docker Hub account
* Docker Hub Access Token

## Create Cluster

Create a two-node Minikube cluster:

```bash
minikube start --nodes 2
```

Verify:

```bash
kubectl get nodes
```

Expected:

```text
minikube
minikube-m02
```

## Label Nodes

Apply node labels:

```bash
bash kubernetes/labels.sh
```

Or manually:

```bash
kubectl label node minikube gpu=nvidia --overwrite

kubectl label node minikube-m02 gpu=other --overwrite
kubectl label node minikube-m02 cpu=ryzen --overwrite
```

Verify:

```bash
kubectl get nodes -L gpu,cpu
```

## Create Namespace

```bash
kubectl apply -f kubernetes/namespace.yaml
```

Verify:

```bash
kubectl get ns
```

## Create Docker Hub Secret

Create a Docker Hub Access Token and then:

```bash
kubectl create secret docker-registry dockerhub-secret \
  -n gpu-test \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=<DOCKER_USERNAME> \
  --docker-password=<DOCKER_ACCESS_TOKEN>
```

Verify:

```bash
kubectl get secrets -n gpu-test
```

## Build and Push Image

Build:

```bash
docker build \
  -t datatomas/uppercut_analytics:http-prober \
  ./app
```

Push:

```bash
docker push datatomas/uppercut_analytics:http-prober
```

Verify:

```bash
docker pull datatomas/uppercut_analytics:http-prober
```

## Deploy ReplicaSets

```bash
bash kubernetes/deploy.sh
```

Or manually:

```bash
kubectl apply -f kubernetes/rs-gpu-nvidia.yaml

kubectl apply -f kubernetes/rs-gpu-exists.yaml

kubectl apply -f kubernetes/rs-cpu-ryzen.yaml
```

## Verify Scheduling

View pods:

```bash
kubectl get pods -n gpu-test -o wide
```

Expected behavior:

* rs-gpu-nvidia schedules only on gpu=nvidia
* rs-gpu-exists schedules on any node with a gpu label
* rs-cpu-ryzen schedules only on cpu=ryzen

## Verify Affinity Rules

Check pod placement:

```bash
kubectl get pods -n gpu-test -o wide
```

Inspect node labels:

```bash
kubectl get nodes -L gpu,cpu
```

Describe a pod:

```bash
kubectl describe pod <pod-name> -n gpu-test
```

## Liveness Probe Testing

The lab uses a liveness probe to demonstrate container restarts.

Watch pods:

```bash
kubectl get pods -n gpu-test -w
```

Check restart count:

```bash
kubectl get pods -n gpu-test
```

Inspect events:

```bash
kubectl describe pod <pod-name> -n gpu-test
```

Typical output:

```text
Liveness probe failed
Container failed liveness probe, will be restarted
Back-off restarting failed container
```

## Domain TLS With Cloudflare

Create a Cloudflare API token with these settings:

```text
Permissions:
  Zone / DNS / Edit
  Zone / Zone / Read

Zone Resources:
  Include / Specific zone / uppercutanalytics.com

Client IP Address Filtering:
  Leave blank unless your outbound IP is stable
```

Install cert-manager, then create a Cloudflare-backed Let's Encrypt issuer and certificate:

```bash
./scripts/14-install-cert-manager.sh

export CLOUDFLARE_API_TOKEN='your-cloudflare-api-token'

./scripts/15-create-cloudflare-clusterissuer.sh
./scripts/16-deploy-domain-certificate.sh
```

The Let's Encrypt email is set in `kubernetes/certificates/clusterissuer-letsencrypt-cloudflare.yaml`.

Do not commit the Cloudflare token. The scripts create Kubernetes secrets from environment variables.

## Gateway API Controllers

The `Gateway` and `HTTPRoute` objects are Gateway API resources. They still need a controller.

Manifest map:

```text
kubernetes/gateway/api-gateway.yaml
  NGINX Gateway Fabric Gateway.
  Creates ingress-lab/lab-gateway with gatewayClassName: nginx.

kubernetes/gateway/httproute.yaml
  NGINX Gateway Fabric HTTPRoute.
  Attaches to ingress-lab/lab-gateway.

kubernetes/gateway/httproute-traefik.yaml
  Traefik Gateway API HTTPRoute.
  Attaches to traefik/traefik-gateway created by the Traefik Helm chart.

kubernetes/gateway/referencegrant-traefik-to-ingress-lab.yaml
  Allows the Traefik HTTPRoute in namespace traefik to route to svc-frontend-ha in namespace ingress-lab.
```

Use NGINX Gateway Fabric:

```bash
./scripts/7-install-gateway-api-crds.sh
./scripts/8-helm-install-nginx-gateway-fabric.sh
./scripts/9-deploy-gateway.sh
```

Delete the NGINX-backed Gateway before trying Traefik:

```bash
kubectl delete httproute frontend-route -n ingress-lab
kubectl delete gateway lab-gateway -n ingress-lab
./scripts/10-uninstall-nginx-gateway-fabric.sh
```

Use Traefik as a Gateway API controller:

```bash
./scripts/7-install-gateway-api-crds.sh
./scripts/11-helm-install-traefik-gateway-api.sh
./scripts/12-deploy-traefik-gateway-api.sh
```

This is not the classic Kubernetes `Ingress` object path. It is Gateway API plus the Traefik controller.

Legacy classic Ingress examples live under `kubernetes/legacy/ingress/` and `scripts/legacy/`.

## Troubleshooting

### ImagePullBackOff

Verify image:

```bash
docker pull datatomas/uppercut_analytics:http-prober
```

Verify secret:

```bash
kubectl get secret dockerhub-secret -n gpu-test
```

### Pending Pods

Verify labels:

```bash
kubectl get nodes -L gpu,cpu
```

Verify affinity:

```bash
kubectl describe pod <pod-name> -n gpu-test
```

### Liveness Probe Failures

Inspect events:

```bash
kubectl describe pod <pod-name> -n gpu-test
```

## Cleanup

Delete the namespace:

```bash
kubectl delete namespace gpu-test
```

Delete Minikube:

```bash
minikube delete
```

## Concepts Demonstrated

* Kubernetes Namespaces
* ReplicaSets
* Node Labels
* Node Affinity
* Match Expressions
* In Operator
* Exists Operator
* Docker Hub imagePullSecrets
* Multi-node Scheduling
* Liveness Probes
* Container Restarts
* Troubleshooting with kubectl
