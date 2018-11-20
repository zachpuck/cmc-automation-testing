#!/usr/bin/env sh

# cma-vmware
if $enable ; then
    if [ -z "$(helm list | grep cma-vmware)" ]; then
        echo "helm installing release: cma-vmware"
        helm install --tiller-namespace=kube-system --name cma-vmware --namespace cma-vmware /repo/deployments/helm/cma-vmware
    else
        echo "helm upgrading release: cma-vmware"
        helm upgrade cma-vmware /repo/deployments/helm/cma-vmware
    fi
fi