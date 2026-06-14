#!/bin/bash
set -e

kubectl apply -n ingress-lab -f kubernetes/replicasets/rs-streamlit-frontend-ha.yaml
kubectl apply -n ingress-lab -f kubernetes/services/svc-frontend-ha.yaml
