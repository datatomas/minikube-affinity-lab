
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
chmod +x scripts/8-test-frontend-post-forward.sh
