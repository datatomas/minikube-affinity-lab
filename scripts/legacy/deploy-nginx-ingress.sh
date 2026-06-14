#!/bin/bash
set -euo pipefail

kubectl apply -n ingress-lab -f kubernetes/legacy/ingress/ing-frontend-nginx.yaml
kubectl get ingress -n ingress-lab
