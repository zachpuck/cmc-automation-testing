#!/usr/bin/env sh

# cluster-manager-api
if $enable ; then
    if [ -z "$(helm list | grep cma-aks)" ]; then
        echo "helm installing release: cma-aks"
        helm install --tiller-namespace=kube-system --name cma-aks --namespace cma-aks /repo/deployments/helm/cma-aks
    else
        echo "helm upgrading release: cma-aks"
        helm upgrade cma-aks /repo/deployments/helm/cma-aks
    fi
fi