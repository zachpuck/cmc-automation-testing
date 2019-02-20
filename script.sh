##!/bin/bash
#
#set -o errexit
#set -o nounset
#set -o pipefail
#set -o xtrace
#
##function finish {
##  kind delete cluster
##}
##trap finish EXIT
#
#echo "The current environment contains these variables: $(env)"
#echo "The current directory is $(pwd)"
#
##service docker start
#sleep 30
##kind create cluster --wait=10m --loglevel=debug
##
##export KUBECONFIG=$(kind get kubeconfig-path)
#
#kubectl create clusterrolebinding superpowers --clusterrole=cluster-admin --user=system:serviceaccount:kube-system:default
#
#echo "The current pods are:"
#kubectl get pods --all-namespaces
#kubectl get pods -n kube-system
#
#kubectl get nodes
#
## tillerless helm
##helm tiller start
#
## install cert-manager (required by cma-aws chart)
## installing cert-manager and ingress, but using NodePort for CI
## Note: removed --wait, it times out downloading the .tgz file
#kubectl apply \
#    -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml
#kubectl create namespace cert-manager
#kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
#helm repo update
#helm install --name cert-manager --namespace cert-manager stable/cert-manager --debug
#sleep 10
#helm install --name nginx-ingress stable/nginx-ingress --debug

#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

function finish {
  kind delete cluster
}
trap finish EXIT

echo "The current environment contains these variables: $(env)"
echo "The current directory is $(pwd)"

#service docker start
#sleep 10
kind create cluster --wait=10m --loglevel=debug

export KUBECONFIG=$(kind get kubeconfig-path)

kubectl create clusterrolebinding superpowers --clusterrole=cluster-admin --user=system:serviceaccount:kube-system:default

echo "The current pods are:"
kubectl get pods --all-namespaces
kubectl describe pods --all-namespaces

echo $HELM_HOST
# expects tillerless helm, since HELM_HOST is defined
helm plugin install https://github.com/rimusz/helm-tiller || true
helm tiller start-ci

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

# TODO: This is incorrect. We should be installing the repo containing the PR we
# wish to test.
#go get github.com/samsung-cnct/cma-aws
#helm install --name cma-aws ${GOPATH}/src/github.com/samsung-cnct/cma-aws/deployments/helm/cma-aws/ --wait --debug

helm repo add cnct https://charts.migrations.cnct.io
helm install --name cma-aws cnct/cma-aws --debug
#helm install --name cluster-manager-api cnct/cluster-manager-api --debug
#helm install --name cma-operator cnct/cma-operator --debug
helm install -f test/e2e/cma-values.yaml --name cluster-manager-api cnct/cluster-manager-api --debug
helm install -f test/e2e/cma-operator-values.yaml --name cma-operator cnct/cma-operator --debug


helm tiller stop

# TODO: set api endpoint and service port
#test/e2e/full-test.sh
