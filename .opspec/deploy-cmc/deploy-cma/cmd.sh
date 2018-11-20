#!/usr/bin/env sh

# cluster-manager-api
if $enable ; then
    if [ -z "$(helm list | grep cluster-manager-api)" ]; then
        echo "helm installing release: cluster-manager-api"
        helm install --tiller-namespace=kube-system --name cluster-manager-api --namespace cluster-manager-api /repo/deployments/helm/cluster-manager-api
    else
        echo "helm upgrading release: cluster-manager-api"
        helm upgrade cluster-manager-api /repo/deployments/helm/cluster-manager-api
    fi
fi