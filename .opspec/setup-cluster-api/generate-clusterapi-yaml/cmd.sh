#!/usr/bin/env sh

# install git
apk update && apk -U add git

### clone repo ###
host=$(echo "$url" | awk -F/ '{print $3}')

echo "adding $host to .netrc"
echo -e "machine $host\n" \
"login ${username}\n"\
"password $password" > ~/.netrc

git clone "$url" /go/src/repo
### end clone repo ###

### generate yaml ###
go run /go/src/repo/genClusterApiServerYaml.go > /clusterapi-apiserver.yaml
