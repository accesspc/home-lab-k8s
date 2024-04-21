#!/bin/bash

set -e

echo "=> Setting up defaults..."

# metrics-server
echo -e "\n=> metrics-server\n"
kubectl apply -f defaults/metrics-server

echo -e "\n==> metrics-server pods:\n"
kubectl -n kube-system wait pods --selector k8s-app=metrics-server --for=condition=Ready
kubectl -n kube-system get pods --selector k8s-app=metrics-server

# kube-state-metrics
echo -e "\n=> kube-state-metrics\n"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install -n kube-system kube-state-metrics prometheus-community/kube-state-metrics

echo -e "\n==> kube-state-metrics pods:\n"
kubectl -n kube-system wait pods --selector app.kubernetes.io/name=kube-state-metrics --for=condition=Ready
kubectl -n kube-system get pods --selector app.kubernetes.io/name=kube-state-metrics

# dashboard
echo -e "\n=> dashboard\n"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

echo -e "\n==> dashboard pods:\n"
kubectl -n kubernetes-dashboard wait pods --selector k8s-app=kubernetes-dashboard --for=condition=Ready
kubectl -n kubernetes-dashboard wait pods --selector k8s-app=dashboard-metrics-scraper --for=condition=Ready
kubectl -n kubernetes-dashboard get pods
echo

kubectl apply -f defaults/dashboard/
for i in $(seq 1 3) ; do echo -n "." ; sleep 1 ; done ; echo 
kubectl apply -f defaults/dashboard/

# cert-manager
echo -e "\n=> cert-manager\n"
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true

kubectl apply -f defaults/cert-manager/

echo -e "\n==> cert-manager pods:\n"
kubectl -n cert-manager wait pods --selector app.kubernetes.io/instance=cert-manager --for=condition=Ready
kubectl -n cert-manager get pods
echo

echo "Done"
