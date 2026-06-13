#!/bin/bash
minikube start \
  --nodes=3 \
  --memory=2048 \
  --cpus=2
#verify they're created
minikube start \
  --nodes=3 \
  --memory=2048 \
  --cpus=2

  
kubectl create ns affinity-lab --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns ingress-lab --dry-run=client -o yaml | kubectl apply -f -


kubectl apply -n affinity-lab -f kubernetes/rs-gpu-nvidia.yaml
kubectl apply -n affinity-lab -f kubernetes/rs-gpu-exists.yaml
kubectl apply -n affinity-lab -f kubernetes/rs-cpu-ryzen.yaml
