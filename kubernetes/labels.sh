#!/bin/bash

kubectl label node minikube gpu=nvidia --overwrite

kubectl label node minikube-m02 gpu=other --overwrite
kubectl label node minikube-m02 cpu=ryzen --overwrite
