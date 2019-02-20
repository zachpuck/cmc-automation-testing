#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

#function finish {
#  kind delete cluster
#}
#trap finish EXIT

echo "The current environment contains these variables: $(env)"
echo "The current directory is $(pwd)"

#service docker start
sleep 30
#kind create cluster --wait=10m --loglevel=debug
#
#export KUBECONFIG=$(kind get kubeconfig-path)

kubectl create clusterrolebinding superpowers --clusterrole=cluster-admin --user=system:serviceaccount:kube-system:default

echo "The current pods are:"
kubectl get pods --all-namespaces
kubectl get pods -n kube-system

kubectl get nodes

 # install cert-manager (required by cma-aws chart)
# installing cert-manager and ingress, but using NodePort for CI
# Note: removed --wait, it times out downloading the .tgz file
kubectl apply \
    -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml
kubectl create namespace cert-manager
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
helm repo update
helm install --name cert-manager --namespace cert-manager stable/cert-manager --debug
sleep 10
helm install --name nginx-ingress stable/nginx-ingress --debug
