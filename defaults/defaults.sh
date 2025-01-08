#!/bin/bash

set -e

cd $(dirname -- "${BASH_SOURCE[0]}")

# metrics-server
read -p "=> metrics-server [Y/n]: " yn_ms
if [[ "x$yn_ms" == "xy" ]] || [[ "x$yn_ms" == "xY" ]] || [[ "x$yn_ms" == "x" ]] ; then
  echo -e "\n==> metrics-server: apply:\n"
  kubectl apply -f metrics-server

  echo -e "\n==> metrics-server: pods\n"
  kubectl -n kube-system wait pods --selector k8s-app=metrics-server --for=condition=Ready --timeout=90s
  kubectl -n kube-system get pods --selector k8s-app=metrics-server
fi

echo

# kube-state-metrics
read -p "=> kube-state-metrics [Y/n]: " yn_ksm
if [[ "x$yn_ksm" == "xy" ]] || [[ "x$yn_ksm" == "xY" ]] || [[ "x$yn_ksm" == "x" ]] ; then
  echo -e "\n==> kube-state-metrics: helm install:\n"
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
  helm upgrade --install -n kube-system kube-state-metrics prometheus-community/kube-state-metrics

  echo -e "\n==> kube-state-metrics: pods:\n"
  kubectl -n kube-system wait pods --selector app.kubernetes.io/name=kube-state-metrics --for=condition=Ready --timeout=90s
  kubectl -n kube-system get pods --selector app.kubernetes.io/name=kube-state-metrics
fi

echo

# dashboard
read -p "=> dashboard [Y/n]: " yn_d
if [[ "x$yn_d" == "xy" ]] || [[ "x$yn_d" == "xY" ]] || [[ "x$yn_d" == "x" ]] ; then
  echo -e "\n==> dashboard: apply:\n"
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

  echo -e "\n==> dashboard: pods:\n"
  kubectl -n kubernetes-dashboard wait pods --selector k8s-app=kubernetes-dashboard --for=condition=Ready --timeout=90s
  kubectl -n kubernetes-dashboard wait pods --selector k8s-app=dashboard-metrics-scraper --for=condition=Ready --timeout=90s
  kubectl -n kubernetes-dashboard get pods

  echo -e "\n==> dashboard: apply:\n"
  kubectl apply -f dashboard/
  for i in $(seq 1 3) ; do echo -n "." ; sleep 1 ; done ; echo 
  kubectl apply -f dashboard/
fi

echo

# cert-manager
read -p "=> cert-manager [Y/n]: " yn_cm
if [[ "x$yn_cm" == "xy" ]] || [[ "x$yn_cm" == "xY" ]] || [[ "x$yn_cm" == "x" ]] ; then
  echo -e "\n==> cert-manager: cli:\n"
  latest=$(curl -sL https://api.github.com/repos/cert-manager/cert-manager/releases/latest | jq -r '.tag_name')
  if [ ! -x ~/bin/cmctl ] ; then
    mkdir -p ~/bin
    curl -fsSL -o ~/bin/cmctl https://github.com/cert-manager/cmctl/releases/latest/download/cmctl_linux_amd64
    chmod +x ~/bin/cmctl
  fi

  echo -e "\n==> cert-manager: helm install:\n"
  helm repo add jetstack https://charts.jetstack.io
  helm repo update
  helm upgrade --install --timeout 20m \
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version ${latest} \
    --set crds.enabled=true

  echo -e "\n==> cert-manager: cmctl check api:\n"
  cmctl check api --wait=2m

  kubectl apply -f cert-manager/

  echo -e "\n==> cert-manager: pods:\n"
  kubectl -n cert-manager wait pods --selector app.kubernetes.io/instance=cert-manager --for=condition=Ready --timeout=90s
  kubectl -n cert-manager get pods
  echo
fi

echo "Done"
