#!/bin/bash
set -e
#verify they're created
minikube start \
  --nodes=3 \
  --memory=2048 \
  --cpus=2
kubectl get nodes 
  
kubectl create ns affinity-lab --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns ingress-lab --dry-run=client -o yaml | kubectl apply -f -

