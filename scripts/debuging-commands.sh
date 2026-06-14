
#check pods 
kubectl get pods -n affinity-lab -o wide
kubectl get pods -n affinity-lab -o wide -w
# if pod has image pull errors meaning it never acutally started 
kubectl describe pod rs-gpu-exists-7z7kg -n affinity-lab

# Only use logs when the container actually started:
kubectl logs rs-gpu-exists-7z7kg -n affinity-lab

# Verify secret exits
kubectl get secret dockerhub-secret -n affinity-lab
kubectl get secret dockerhub-secret -n ingress-lab

# delete and recreate setitngs

kubectl delete secret dockerhub-secret -n affinity-lab
kubectl delete secret dockerhub-secret -n ingress-lab


# test  access docker registry
docker logout
echo 'yourdockerpat' | docker login -u datatomas --password-stdin
docker pull datatomas/uppercut_analytics:http-prober

# delete all the pods in a namespace
kubectl delete pods -n affinity-lab --all

# get pods from frontend lab
kubectl get pods -n ingress-lab -o wide -w


# port forward  front end service
kubectl port-forward -n ingress-lab svc/svc-frontend-ha 8080:80
# test access to frontend
curl -i http://localhost:8080/_stcore/health
# from browser
http://localhost:8080
http://localhost:8080/_stcore/health
# chmod all scripts

chmod +x scripts/*.sh
chmod +x scripts/test-frontend-post-forward.sh

# install Gateway API CRDs, then choose a Gateway controller
./scripts/7-install-gateway-api-crds.sh
./scripts/8-helm-install-nginx-gateway-fabric.sh
./scripts/9-deploy-gateway.sh
kubectl get gatewayclass
kubectl get gateway -n ingress-lab
kubectl get httproute -n ingress-lab
./scripts/test-gateway-from-cluster.sh

# alternate Traefik Gateway API controller path
./scripts/11-helm-install-traefik-gateway-api.sh
./scripts/12-deploy-traefik-gateway-api.sh

# legacy classic Ingress examples
./scripts/legacy/deploy-traefik-ingress.sh
./scripts/legacy/deploy-nginx-ingress.sh

# domain TLS with Cloudflare DNS-01 and Let's Encrypt
./scripts/14-install-cert-manager.sh
export CLOUDFLARE_API_TOKEN='your-cloudflare-api-token'
./scripts/15-create-cloudflare-clusterissuer.sh
./scripts/16-deploy-domain-certificate.sh
kubectl describe certificate uppercutanalytics-tls -n ingress-lab
kubectl get secret uppercutanalytics-tls -n ingress-lab
