#!/bin/bash
set -euo pipefail

: "${CLOUDFLARE_API_TOKEN:?Set CLOUDFLARE_API_TOKEN before running this script}"

CLOUDFLARE_SECRET_NAME="${CLOUDFLARE_SECRET_NAME:-cloudflare-api-token-secret}"
CLUSTER_ISSUER_NAME="${CLUSTER_ISSUER_NAME:-letsencrypt-cloudflare}"
CLUSTER_ISSUER_MANIFEST="${CLUSTER_ISSUER_MANIFEST:-kubernetes/certificates/clusterissuer-letsencrypt-cloudflare.yaml}"

kubectl create secret generic "${CLOUDFLARE_SECRET_NAME}" \
  -n cert-manager \
  --from-literal=api-token="${CLOUDFLARE_API_TOKEN}" \
  --dry-run=client \
  -o yaml \
  | kubectl apply -f -

kubectl apply -f "${CLUSTER_ISSUER_MANIFEST}"

kubectl get clusterissuer "${CLUSTER_ISSUER_NAME}"
