kubectl apply -n affinity-lab -f replicasets/rs-gpu-in-nvidia.yaml
kubectl apply -n affinity-lab -f replicasets/rs-gpu-exists.yaml
kubectl apply -n affinity-lab -f replicasets/rs-gpu-doesnotexist.yaml
kubectl apply -n affinity-lab -f replicasets/rs-gpu-notin-nvidia.yaml
kubectl apply -n affinity-lab -f replicasets/rs-workload-ai-or-frontend.yaml
kubectl apply -n affinity-lab -f replicasets/rs-frontend.yaml

# or if you create them all in one folder
kubectl apply -n affinity-lab -f replicasets/
