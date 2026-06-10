kubectl create secret docker-registry dockerhub-secret \
  -n gpu-test \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=datatomas \
  --docker-password='YOUR_DOCKERHUB_TOKEN'
