#!/usr/bin/env sh

echo "installing git and docker"
apk update && apk -U add git docker
apk add openrc --no-cache

echo "installing kind (kubernetes in docker)"
cd /go/src/
go get sigs.k8s.io/kind

echo "create cluster"
kind create cluster --name $name

cat ~/.kube/kind-config-$name > /kubeConfig
