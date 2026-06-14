#!/bin/bash
set -euo pipefail

GATEWAY_API_VERSION="${GATEWAY_API_VERSION:-v1.5.0}"
GATEWAY_API_CHANNEL="${GATEWAY_API_CHANNEL:-standard}"

case "${GATEWAY_API_CHANNEL}" in
  standard|experimental)
    ;;
  *)
    echo "GATEWAY_API_CHANNEL must be standard or experimental" >&2
    exit 1
    ;;
esac

GATEWAY_API_URL="https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/${GATEWAY_API_CHANNEL}-install.yaml"

echo "Installing Gateway API CRDs from ${GATEWAY_API_URL}"
kubectl apply --server-side -f "${GATEWAY_API_URL}"

kubectl get crd gatewayclasses.gateway.networking.k8s.io gateways.gateway.networking.k8s.io httproutes.gateway.networking.k8s.io
