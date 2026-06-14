#!/bin/bash
set -euo pipefail

kubectl apply -n ingress-lab -f kubernetes/certificates/cert-uppercutanalytics.yaml
kubectl get certificate -n ingress-lab
