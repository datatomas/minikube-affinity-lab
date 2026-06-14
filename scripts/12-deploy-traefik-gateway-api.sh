#!/bin/bash
set -euo pipefail

kubectl apply -n ingress-lab -f kubernetes/gateway/referencegrant-traefik-to-ingress-lab.yaml
kubectl apply -n traefik -f kubernetes/gateway/httproute-traefik.yaml
kubectl get gateway -A
kubectl get httproute -A
kubectl describe gateway traefik-gateway -n traefik
kubectl describe httproute frontend-route -n traefik
