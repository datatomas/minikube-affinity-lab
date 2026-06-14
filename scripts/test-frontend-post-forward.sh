#!/bin/bash
set -euo pipefail

kubectl get pods -n ingress-lab -o wide
kubectl get svc -n ingress-lab

echo "Port forwarding svc/svc-frontend-ha to http://localhost:8080"
kubectl port-forward -n ingress-lab svc/svc-frontend-ha 8080:80