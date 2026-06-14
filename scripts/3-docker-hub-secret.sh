#!/bin/bash
set -euo pipefail

DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-datatomas}"
: "${DOCKERHUB_TOKEN:?Set DOCKERHUB_TOKEN before running this script}"

for ns in affinity-lab ingress-lab; do
  kubectl delete secret dockerhub-secret -n "$ns" --ignore-not-found

  kubectl create secret docker-registry dockerhub-secret \
    -n "$ns" \
    --docker-server=https://index.docker.io/v1/ \
    --docker-username="$DOCKERHUB_USERNAME" \
    --docker-password="$DOCKERHUB_TOKEN"
done

kubectl get secret dockerhub-secret -n affinity-lab
kubectl get secret dockerhub-secret -n ingress-lab

