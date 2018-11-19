#!/usr/bin/env sh

# initialize helm/tiller on cluster with cluster-admin account
if [ "$(kubectl get deploy -n kube-system --no-headers=true -o custom-columns=:metadata.name | grep tiller-deploy)" != "tiller-deploy" ]; then
    echo "initilizing tiller on cluster"
    # create tiller service account
    kubectl apply -f /tiller.yaml
    
    kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

    helm init --service-account tiller --wait
fi

echo "installing cert-manager"
helm install --tiller-namespace=kube-system --name cert-manager --namespace kube-system stable/cert-manager

echo "installing cma-vmware"
helm install --tiller-namespace=kube-system --name cma-vmware --namespace cma-vmware /repo/deployments/helm/cma-vmware