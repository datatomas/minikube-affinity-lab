#!/bin/bash

kubectl create namespace gpu-test

kubectl apply -f kubernetes/rs-gpu-nvidia.yaml
kubectl apply -f kubernetes/rs-gpu-exists.yaml
kubectl apply -f kubernetes/rs-cpu-ryzen.yaml
