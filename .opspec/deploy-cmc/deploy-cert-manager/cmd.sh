#!/usr/bin/env sh

# cert-manager
if [ -z "$(helm list | grep cert-manager)" ]; then
    echo "helm installing release: cert-manager"
    helm init --client-only
    helm repo update
    helm install --tiller-namespace=kube-system --name cert-manager --namespace kube-system stable/cert-manager
else
    echo "cert-manager already installed on cluster"
fi