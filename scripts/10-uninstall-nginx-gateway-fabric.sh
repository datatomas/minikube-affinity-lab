#!/bin/bash
set -euo pipefail

NGF_NAMESPACE="${NGF_NAMESPACE:-nginx-gateway}"
NGF_RELEASE="${NGF_RELEASE:-ngf}"

kubectl delete httproute frontend-route -n ingress-lab --ignore-not-found
kubectl delete gateway lab-gateway -n ingress-lab --ignore-not-found

helm uninstall "${NGF_RELEASE}" -n "${NGF_NAMESPACE}" --ignore-not-found

echo "NGINX Gateway Fabric uninstalled. Gateway API CRDs were left installed."
echo "If you are done with Gateway API entirely, remove CRDs separately and carefully."
