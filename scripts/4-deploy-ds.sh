#!/bin/bash
set -e

kubectl apply -n affinity-lab -f kubernetes/daemonsets/
kubectl apply -n ingress-lab -f kubernetes/daemonsets/ds-node-streamlit-checker.yaml
kubectl get ds -n affinity-lab
kubectl get pods -n affinity-lab -l app=system-node-agent -o wide
kubectl get pods -n ingress-lab -l app=node-streamlit-checker -o wide