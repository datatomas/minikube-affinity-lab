#!/bin/bash
set -e
kubectl label node minikube \
  pool=system \
  workload=system \
  disk=ssd \
  zone=zone-a \
  --overwrite

kubectl label node minikube-m02 \
  pool=user \
  workload=ai \
  gpu=nvidia \
  cpu=ryzen \
  disk=ssd \
  zone=zone-b \
  --overwrite

kubectl label node minikube-m03 \
  pool=user \
  workload=frontend \
  cpu=intel \
  disk=ssd \
  zone=zone-c \
  --overwrite
#Para bloquear apps normales ne system
kubectl taint node minikube CriticalAddonsOnly=true:NoSchedule --overwrite
# verify
kubectl get nodes -L pool,workload,gpu,cpu,disk,zone
kubectl describe node minikube | grep -i taint
