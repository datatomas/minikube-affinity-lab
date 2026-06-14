
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