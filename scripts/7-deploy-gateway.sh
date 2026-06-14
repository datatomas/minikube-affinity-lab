#!/bin/bash
set -e
kubectl apply -n ingress-lab -f kubernetes/gateway/api-gateway.yaml
kubectl apply -n ingress-lab -f kubernetes/gateway/httproute.yaml
