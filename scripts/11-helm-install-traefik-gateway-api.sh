#!/bin/bash
set -euo pipefail

TRAEFIK_NAMESPACE="${TRAEFIK_NAMESPACE:-traefik}"
TRAEFIK_RELEASE="${TRAEFIK_RELEASE:-traefik}"
TRAEFIK_SERVICE_TYPE="${TRAEFIK_SERVICE_TYPE:-NodePort}"

if ! command -v helm >/dev/null 2>&1; then
  echo "Helm is required. Install Helm first or run the NGINX Gateway Fabric script with INSTALL_HELM_IF_MISSING=true." >&2
  exit 1
fi

helm repo add traefik https://traefik.github.io/charts
helm repo update

helm upgrade --install "${TRAEFIK_RELEASE}" traefik/traefik \
  --create-namespace \
  --namespace "${TRAEFIK_NAMESPACE}" \
  --set "providers.kubernetesGateway.enabled=true" \
  --set "providers.kubernetesIngress.enabled=false" \
  --set "ingressClass.enabled=false" \
  --set "service.type=${TRAEFIK_SERVICE_TYPE}" \
  --wait

kubectl get gatewayclass
kubectl get pods -n "${TRAEFIK_NAMESPACE}"
kubectl get svc -n "${TRAEFIK_NAMESPACE}"
