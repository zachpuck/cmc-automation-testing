#!/bin/sh

echo "Deploying CMC"

# install tiller
if [ "$(kubectl get deploy -n kube-system --no-headers=true -o custom-columns=:metadata.name | grep tiller-deploy)" != "tiller-deploy" ]; then
    echo "initilizing tiller on cluster"
    # create tiller service account
    kubectl apply -f values-files/tiller-rbac.yaml

    kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

    helm init --service-account tiller --wait
else
    echo "tiller already installed on cluster"
    helm init --client-only
fi

# setup helm repo's
helm repo add cnct https://charts.cnct.io
helm repo update

# install helm plugins
# TODO: add this to the kind image
helm plugin install https://github.com/databus23/helm-diff --version master

# install cert manager
if [ -z "$(helm list | grep cert-manager)" ]; then
    echo "helm installing release: cert-manager"
    kubectl apply \
    -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml

    kubectl create namespace cert-manager
    kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
    helm install --name cert-manager --namespace cert-manager stable/cert-manager
else
    echo "cert-manager already installed on cluster"
fi

# install nginx ingress controller
if [ -z "$(helm list | grep ingress-controller)" ]; then
    echo "helm installing release: ingress-controller"
    helm install --tiller-namespace=kube-system --name ingress-controller --namespace kube-system stable/nginx-ingress
else
    echo "ingress-controller already installed on cluster"
fi

# install/upgrade cluster-manager-api (CMA)
if [ -z "$(helm list | grep cluster-manager-api)" ] || [ ! -z "$(helm diff upgrade cluster-manager-api cnct/cluster-manager-api)" ]; then
    echo "helm install/upgrade release: cluster-manager-api"
    helm upgrade cluster-manager-api \
        cnct/cluster-manager-api \
        --namespace cma \
        --tiller-namespace=kube-system \
        --set helpers.ssh.enabled=true \
        --install
else
    echo "no changes to helm release: cluster-manager-api"
fi

# install/upgrade cma-operator
# TODO: require CRD to be installed before bundles install, help avoid the need for 2 commands here.
if [ -z "$(helm list | grep cma-operator)" ] || [ ! -z "$(helm diff upgrade cma-operator cnct/cma-operator)" ]; then
    echo "helm install/upgrade release: cma-operator"
    helm upgrade cma-operator \
        cnct/cma-operator \
        --namespace cma \
        --tiller-namespace=kube-system \
        --set cma.enabled=true \
        --set cma.endpoint=cluster-manager-api-cluster-manager-api:80 \
        --set cma.insecure=true \
        --set bundles.metrics=false \
        --set bundles.nginxk8smon=false \
        --set bundles.nodelabelbot5000=false \
        --install

    echo "update cma-operator default bundles"
        helm upgrade cma-operator \
        cnct/cma-operator \
        --namespace cma \
        --tiller-namespace=kube-system \
        --set cma.enabled=true \
        --set cma.endpoint=cluster-manager-api-cluster-manager-api:80 \
        --set cma.insecure=true \
        --set bundles.metrics=true \
        --set bundles.nginxk8smon=true \
        --set bundles.nodelabelbot5000=true \
        --install
else
    echo "no changes to helm release: cma-operator"
fi

# install/upgrade cma-ssh
if [ -z "$(helm list | grep cma-ssh)" ] || [ ! -z "$(helm diff upgrade cma-ssh cnct/cma-ssh)" ]; then
    echo "helm install/upgrade release: cma-ssh"
    helm upgrade cma-ssh \
        cnct/cma-ssh \
        --namespace cma \
        --tiller-namespace=kube-system \
        --set install.bootstrapIp='' \
        --set install.airgapProxyIp='' \
        --install
else
    echo "no changes to helm release: cma-ssh"
fi
