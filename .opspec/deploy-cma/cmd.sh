#!/usr/bin/env sh

# initialize helm/tiller on cluster with cluster-admin account
if [ "$(kubectl get deploy -n kube-system --no-headers=true -o custom-columns=:metadata.name | grep tiller-deploy)" != "tiller-deploy" ]; then
    echo "initilizing tiller on cluster"
    # create tiller service account
    kubectl apply -f /tiller.yaml
    
    kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

    helm init --service-account tiller --wait
else
    helm init --service-account tiller
fi

echo "updating helm repo"
helm repo update

# cert-manager
if [ -z "$(helm list | grep cert-manager)" ]; then
    echo "helm installing release: cert-manager"
    helm install --tiller-namespace=kube-system --name cert-manager --namespace kube-system stable/cert-manager
else
    echo "helm upgrading release: cert-manager"
    helm upgrade cert-manager stable/cert-manager
fi


# cma-vmware
if [ -z "$(helm list | grep cma-vmware)" ]; then
    echo "helm installing release: cma-vmware"
    helm install --tiller-namespace=kube-system --name cma-vmware --namespace cma-vmware /repo/deployments/helm/cma-vmware
else
    echo "helm upgrading release: cma-vmware"
    helm upgrade cma-vmware /repo/deployments/helm/cma-vmware
fi