#!/bin/bash
set -euo pipefail

TRAEFIK_NAMESPACE="${TRAEFIK_NAMESPACE:-traefik}"
TRAEFIK_RELEASE="${TRAEFIK_RELEASE:-traefik}"

kubectl delete httproute frontend-route -n "${TRAEFIK_NAMESPACE}" --ignore-not-found
kubectl delete referencegrant allow-traefik-routes-to-frontend-service -n ingress-lab --ignore-not-found
kubectl delete httproute frontend-route -n ingress-lab --ignore-not-found
kubectl delete gateway lab-gateway -n ingress-lab --ignore-not-found

helm uninstall "${TRAEFIK_RELEASE}" -n "${TRAEFIK_NAMESPACE}" --ignore-not-found

echo "Traefik uninstalled. Gateway API CRDs were left installed."
