#!/bin/bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-ingress-lab}"
DOMAIN="${DOMAIN:-uppercutanalytics.com}"
GATEWAY_NAME="${GATEWAY_NAME:-lab-gateway}"
POD_NAME="${POD_NAME:-curl-gateway-test}"

gateway_ip="$(kubectl get gateway "${GATEWAY_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status.addresses[0].value}')"

if [ -z "${gateway_ip}" ]; then
  echo "Gateway ${NAMESPACE}/${GATEWAY_NAME} does not have an address yet" >&2
  exit 1
fi

kubectl apply -n "${NAMESPACE}" -f kubernetes/testing/pods/pod-curl-gateway-test.yaml
kubectl wait --timeout=2m -n "${NAMESPACE}" pod/"${POD_NAME}" --for=condition=Ready

kubectl exec -n "${NAMESPACE}" "${POD_NAME}" -- \
  curl -ik --resolve "${DOMAIN}:443:${gateway_ip}" "https://${DOMAIN}/_stcore/health"

kubectl delete pod -n "${NAMESPACE}" "${POD_NAME}" --ignore-not-found
