#!/bin/bash
set -euo pipefail

CERT_MANAGER_VERSION="${CERT_MANAGER_VERSION:-v1.20.0}"

kubectl apply -f "https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.yaml"

kubectl wait --timeout=5m \
  -n cert-manager \
  deployment/cert-manager \
  deployment/cert-manager-cainjector \
  deployment/cert-manager-webhook \
  --for=condition=Available

echo "Waiting for cert-manager webhook CA injection"
for _ in {1..60}; do
  ca_bundle="$(kubectl get validatingwebhookconfiguration cert-manager-webhook -o jsonpath='{.webhooks[0].clientConfig.caBundle}' 2>/dev/null || true)"
  if [ -n "${ca_bundle}" ]; then
    break
  fi
  sleep 5
done

if [ -z "${ca_bundle:-}" ]; then
  echo "cert-manager webhook CA bundle was not injected in time" >&2
  exit 1
fi

kubectl get pods -n cert-manager
