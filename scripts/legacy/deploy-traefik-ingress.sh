#!/bin/bash
set -euo pipefail

kubectl apply -n ingress-lab -f kubernetes/legacy/ingress/ing-frontend-traefik.yaml
kubectl get ingress -n ingress-lab
