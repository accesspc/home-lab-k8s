#!/bin/bash

set -e

cd $(dirname -- "${BASH_SOURCE[0]}")
opt=""

function show_opts() {
  # clear
  cat <<EOF

========================================================
 ____  __. ______             .____          ___.
|    |/ _|/  __  \  ______    |    |   _____ \_ |__
|      <  >      < /  ___/    |    |   \__  \ | __ \ 
|    |  \/   --   \\\\___ \     |    |___ / __ \| \_\ \ 
|____|__ \______  /____  >    |_______ (____  /___  /
        \/      \/     \/             \/    \/    \/

Options:

  0 - all

  1 - kube-system: metrics-server
  2 - kube-system: kube-state-metrics
  3 - kubernetes-dashboard
  4 - cert-manager

  5 - postgres
  6 - keycloak
  7 - prometheus
  8 - grafana

  x - exit (or Ctrl+C)

EOF
}

while [[ "x$opt" != "xx" ]] ; do

  show_opts

  read -p "> Choose an option: " opt
  if [[ "x$opt" == "xx" ]] ; then
    exit 0
  fi

  read -p "> Choose [I]nstall or [r]emove: " yn

  # namespace
  # TODO: create namespace
  read -p "> Choose namespace [default]: " select_ns
  if [[ "x$select_ns" == "x" ]] ; then
    select_ns="default"
  fi

  # TODO: create netpol: deny ingress
  # ---
  # apiVersion: networking.k8s.io/v1
  # kind: NetworkPolicy
  # metadata:
  #   name: deny-ingress-all
  #   namespace: system
  # spec:
  #   podSelector: {}
  #   # ingress:
  #   #   - {}
  #   policyTypes:
  #     - Ingress

  # kube-system: metrics-server
  if [[ "x$opt" == "x0" ]] || [[ "x$opt" == "x1" ]] ; then
    if [[ "x$yn" == "xi" ]] || [[ "x$yn" == "xI" ]] || [[ "x$yn" == "x" ]] ; then
      kubectl apply -f metrics-server

      kubectl -n kube-system wait pods --selector k8s-app=metrics-server --for=condition=Ready --timeout=90s
      kubectl -n kube-system get pods --selector k8s-app=metrics-server
    elif [[ "x$yn" == "xr" ]] ; then
      kubectl delete -f metrics-server
    fi
  fi

  # kube-system: kube-state-metrics
  if [[ "x$opt" == "x0" ]] || [[ "x$opt" == "x2" ]] ; then
    if [[ "x$yn" == "xi" ]] || [[ "x$yn" == "xI" ]] || [[ "x$yn" == "x" ]] ; then
      helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
      helm repo update
      helm upgrade --install -n kube-system kube-state-metrics prometheus-community/kube-state-metrics

      kubectl -n kube-system wait pods --selector app.kubernetes.io/name=kube-state-metrics --for=condition=Ready --timeout=90s
      kubectl -n kube-system get pods --selector app.kubernetes.io/name=kube-state-metrics
    elif [[ "x$yn" == "xr" ]] ; then
      helm uninstall -n kube-system kube-state-metrics
    fi
  fi

  # kubernetes-dashboard
  if [[ "x$opt" == "x0" ]] || [[ "x$opt" == "x3" ]] ; then
    if [[ "x$yn" == "xi" ]] || [[ "x$yn" == "xI" ]] || [[ "x$yn" == "x" ]] ; then
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
  fi

  # cert-manager
  if [[ "x$opt" == "x0" ]] || [[ "x$opt" == "x4" ]] ; then
    if [[ "x$yn" == "xi" ]] || [[ "x$yn" == "xI" ]] || [[ "x$yn" == "x" ]] ; then
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
      helm upgrade --install --wait --timeout 20m \
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
  fi

  # postgres
  if [[ "x$opt" == "x0" ]] || [[ "x$opt" == "x5" ]] ; then
    # install / remove
    if [[ "x$yn" == "xi" ]] || [[ "x$yn" == "xI" ]] || [[ "x$yn" == "x" ]] ; then
      if [ ! -f helm/postgres/templates/secret.yml ] ; then
        read -s -p "==> Enter postgres password: " pg_pwd
        pg_pwd=$(echo -n $pg_pwd | base64)
        cat helm/postgres/templates/_secret.yml | sed "s/_PG_PWD_/$pg_pwd/g" > helm/postgres/templates/secret.yml
      fi

      echo -e "\n==> postgres: helm install:\n"
      helm upgrade --install --wait --timeout 20m \
        postgres helm/postgres \
        --namespace $select_ns \
        --create-namespace \
        -f helm/postgres.yaml

      kubectl -n $select_ns wait pods --selector app=postgres --for=condition=Ready --timeout=90s

    elif [[ "x$yn" == "xr" ]] ; then
      helm uninstall -n $select_ns postgres
    fi
  fi

  # keycloak
  if [[ "x$opt" == "x0" ]] || [[ "x$opt" == "x6" ]] ; then
    # install / remove
    if [[ "x$yn" == "xi" ]] || [[ "x$yn" == "xI" ]] || [[ "x$yn" == "x" ]] ; then
      if [ ! -f helm/keycloak/templates/secret.yml ] ; then
        read -s -p "==> Enter keycloak password: " kc_pwd
        kc_pwd=$(echo -n $kc_pwd | base64)
        cat helm/keycloak/templates/_secret.yml | sed "s/_KC_PWD_/$kc_pwd/g" > helm/keycloak/templates/secret.yml
      fi

      echo -e "\n==> keycloak: helm install:\n"
      helm upgrade --install --wait --timeout 20m \
        keycloak helm/keycloak \
        --namespace $select_ns \
        --create-namespace \
        -f helm/keycloak.yaml

      kubectl -n $select_ns wait pods --selector app=keycloak --for=condition=Ready --timeout=90s

    elif [[ "x$yn" == "xr" ]] ; then
      helm uninstall -n $select_ns keycloak
    fi
  fi

  # prometheus
  if [[ "x$opt" == "x0" ]] || [[ "x$opt" == "x7" ]] ; then
    # install / remove
    if [[ "x$yn" == "xi" ]] || [[ "x$yn" == "xI" ]] || [[ "x$yn" == "x" ]] ; then
      echo -e "\n==> prometheus: helm install:\n"
      helm dep up helm/prometheus
      helm upgrade --install --wait --timeout 20m \
        prometheus helm/prometheus \
        --namespace $select_ns \
        --create-namespace \
        -f helm/prometheus.yaml

      kubectl -n $select_ns wait pods --selector app=prometheus --for=condition=Ready --timeout=90s

    elif [[ "x$yn" == "xr" ]] ; then
      helm uninstall -n $select_ns prometheus
    fi
  fi

  # grafana
  if [[ "x$opt" == "x0" ]] || [[ "x$opt" == "x8" ]] ; then
    # install / remove
    if [[ "x$yn" == "xi" ]] || [[ "x$yn" == "xI" ]] || [[ "x$yn" == "x" ]] ; then
      echo -e "\n==> grafana: helm install:\n"
      helm upgrade --install --wait --timeout 20m \
        grafana helm/grafana \
        --namespace $select_ns \
        --create-namespace \
        -f helm/grafana.yaml

      kubectl -n $select_ns wait pods --selector app=grafana --for=condition=Ready --timeout=90s

    elif [[ "x$yn" == "xr" ]] ; then
      helm uninstall -n $select_ns grafana
    fi
  fi

done

echo "Done"
