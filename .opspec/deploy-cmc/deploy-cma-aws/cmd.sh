#!/usr/bin/env sh

# cluster-manager-api
if $enable ; then
    if [ -z "$(helm list | grep cma-aws)" ]; then
        echo "helm installing release: cma-aws"
        helm install --tiller-namespace=kube-system --name cma-aws --namespace cma-aws /repo/deployments/helm/cma-aws
    else
        echo "helm upgrading release: cma-aws"
        helm upgrade cma-aws /repo/deployments/helm/cma-aws
    fi
fi