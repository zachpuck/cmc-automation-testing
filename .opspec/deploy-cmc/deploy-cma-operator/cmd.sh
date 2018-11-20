#!/usr/bin/env sh

# cluster-manager-api
if $enable ; then
    if [ -z "$(helm list | grep cma-operator)" ]; then
        echo "helm installing release: cma-operator"
        helm install --tiller-namespace=kube-system --name cma-operator --namespace cma-operator /repo/deployments/helm/cma-operator
    else
        echo "helm upgrading release: cma-operator"
        helm upgrade cma-operator /repo/deployments/helm/cma-operator
    fi
fi