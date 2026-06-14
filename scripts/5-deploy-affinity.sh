#!/bin/bash
set -euo pipefail

kubectl apply -n affinity-lab -f kubernetes/replicasets/rs-gpu-in-nvidia.yaml
kubectl apply -n affinity-lab -f kubernetes/replicasets/rs-gpu-exists.yaml
kubectl apply -n affinity-lab -f kubernetes/replicasets/rs-gpu-doesnotexist.yaml
kubectl apply -n affinity-lab -f kubernetes/replicasets/rs-gpu-notin-nvidia.yaml
kubectl apply -n affinity-lab -f kubernetes/replicasets/rs-workload-ai-or-frontend.yaml

kubectl get rs -n affinity-lab
kubectl get pods -n affinity-lab -o wide