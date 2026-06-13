kubectl apply -n affinity-lab -f kubernetes/rs-gpu-in-nvidia.yaml
kubectl apply -n affinity-lab -f kubernetes/rs-gpu-exists.yaml
kubectl apply -n affinity-lab -f kubernetes/rs-gpu-doesnotexist.yaml
kubectl apply -n affinity-lab -f kubernetes/rs-gpu-notin-nvidia.yaml
kubectl apply -n affinity-lab -f kubernetes/rs-workload-ai-or-frontend.yaml
kubectl apply -n affinity-lab -f kubernetes/rs-frontend.yaml

# or if you create them all in one folder
kubectl apply -n affinity-lab -f kubernetes/
