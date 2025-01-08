#!/bin/bash

set -e

cd $(dirname -- "${BASH_SOURCE[0]}")

cat <<EOF
 ____  __. ______             .____          ___.    
|    |/ _|/  __  \  ______    |    |   _____ \_ |__  
|      <  >      < /  ___/    |    |   \__  \ | __ \ 
|    |  \/   --   \\\\___ \     |    |___ / __ \| \_\ \ 
|____|__ \______  /____  >    |_______ (____  /___  /
        \/      \/     \/             \/    \/    \/ 

Help:
  Prompt options:
    i - install
    r - remove
    s - skip (or just press Enter)

EOF

# kube-system: metrics-server

echo
read -p "=> kube-system: metrics-server [i/r/S]: " yn
if [[ "x$yn" == "xi" ]] ; then
  kubectl apply -f metrics-server

  kubectl -n kube-system wait pods --selector k8s-app=metrics-server --for=condition=Ready --timeout=90s
  kubectl -n kube-system get pods --selector k8s-app=metrics-server
elif [[ "x$yn" == "xr" ]] ; then
  kubectl delete -f metrics-server
fi

# kube-system: kube-state-metrics

echo
read -p "=> kube-system: kube-state-metrics [i/r/S]: " yn
if [[ "x$yn" == "xi" ]] ; then
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
  helm upgrade --install -n kube-system kube-state-metrics prometheus-community/kube-state-metrics

  kubectl -n kube-system wait pods --selector app.kubernetes.io/name=kube-state-metrics --for=condition=Ready --timeout=90s
  kubectl -n kube-system get pods --selector app.kubernetes.io/name=kube-state-metrics
elif [[ "x$yn" == "xr" ]] ; then
  helm uninstall -n kube-system kube-state-metrics
fi

# kubernetes-dashboard

echo
read -p "=> kubernetes-dashboard [i/r/S]: " yn
if [[ "x$yn" == "xi" ]] ; then
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

  echo -e "\n==> dashboard: pods:\n"
  kubectl -n kubernetes-dashboard wait pods --selector k8s-app=kubernetes-dashboard --for=condition=Ready --timeout=90s
  kubectl -n kubernetes-dashboard wait pods --selector k8s-app=dashboard-metrics-scraper --for=condition=Ready --timeout=90s
  kubectl -n kubernetes-dashboard get pods

  echo -e "\n==> dashboard: apply:\n"
  kubectl apply -f kubernetes-dashboard/
  for i in $(seq 1 3) ; do echo -n "." ; sleep 1 ; done ; echo 
  kubectl apply -f kubernetes-dashboard/
elif [[ "x$yn" == "xr" ]] ; then
  kubectl delete -f kubernetes-dashboard/
  kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
fi

# cert-manager

echo
read -p "=> cert-manager [i/r/S]: " yn
if [[ "x$yn" == "xi" ]] ; then
  if [ ! -f cert-manager/clusterissuer.yml ] ; then
    echo "> Missing file: cert-manager/clusterissuer.yml"
    echo "> Create from template provided in cert-manager/clusterissuer.yml.sample.* "
    echo "> or using documentation in https://cert-manager.io/docs/configuration/"
    exit 1
  fi

  if [ ! -f cert-manager/secret.yml ] ; then
    echo "> Missing file: cert-manager/secret.yml"
    echo "> Create from template provided in cert-manager/secret.yml.sample.* "
    echo "> or using documentation in https://cert-manager.io/docs/configuration/"
    exit 1
  fi

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
elif [[ "x$yn" == "xr" ]] ; then
  kubectl delete -f cert-manager
  helm uninstall -n cert-manager cert-manager
  rm -f ~/bin/cmctl
fi
