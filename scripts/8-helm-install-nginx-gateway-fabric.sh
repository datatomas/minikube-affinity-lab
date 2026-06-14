#!/bin/bash
set -euo pipefail

NGF_NAMESPACE="${NGF_NAMESPACE:-nginx-gateway}"
NGF_RELEASE="${NGF_RELEASE:-ngf}"
NGF_SERVICE_TYPE="${NGF_SERVICE_TYPE:-NodePort}"
INSTALL_HELM_IF_MISSING="${INSTALL_HELM_IF_MISSING:-false}"

install_helm_with_apt() {
  local apt_key_id="DDF78C3E6EBB2D2CC223C95C62BA89D07698DBC6"
  local key_file="${TMPDIR:-/tmp}/helm.gpg"

  sudo apt-get update
  sudo apt-get install curl gpg apt-transport-https --yes

  curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey > "${key_file}"

  if [ "$(gpg --show-keys --with-colons "${key_file}" | awk -F: '$1 == "fpr" {print $10}' | head -n 1)" != "${apt_key_id}" ]; then
    echo "ERROR: Unexpected Helm APT key fingerprint" >&2
    exit 1
  fi

  cat "${key_file}" | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" \
    | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

  sudo apt-get update
  sudo apt-get install helm --yes
}

if ! command -v helm >/dev/null 2>&1; then
  if [ "${INSTALL_HELM_IF_MISSING}" = "true" ]; then
    echo "Helm was not found. Installing Helm with apt..."
    install_helm_with_apt
  else
    cat >&2 <<'EOF'
Helm was not found.

Install it first, then rerun this script:

  sudo apt-get update
  sudo apt-get install curl gpg apt-transport-https --yes
  curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey > /tmp/helm.gpg
  cat /tmp/helm.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  sudo apt-get update
  sudo apt-get install helm --yes

Or let this script install it:

  INSTALL_HELM_IF_MISSING=true ./scripts/8-helm-install-nginx-gateway-fabric.sh
EOF
    exit 1
  fi
fi

echo "Installing NGINX Gateway Fabric release ${NGF_RELEASE} in namespace ${NGF_NAMESPACE}"
helm upgrade --install "${NGF_RELEASE}" \
  oci://ghcr.io/nginx/charts/nginx-gateway-fabric \
  --create-namespace \
  --namespace "${NGF_NAMESPACE}" \
  --set "nginx.service.type=${NGF_SERVICE_TYPE}" \
  --wait

kubectl wait --timeout=5m \
  -n "${NGF_NAMESPACE}" \
  "deployment/${NGF_RELEASE}-nginx-gateway-fabric" \
  --for=condition=Available

kubectl get gatewayclass
kubectl get pods -n "${NGF_NAMESPACE}"
