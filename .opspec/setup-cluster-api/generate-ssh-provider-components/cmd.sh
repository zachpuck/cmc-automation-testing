#!/usr/bin/env sh

# install git
apk update && apk -U add git bash gettext

### clone repo ###
host=$(echo "$url" | awk -F/ '{print $3}')

echo "adding $host to .netrc"
echo -e "machine $host\n" \
"login $username\n"\
"password $password" > ~/.netrc

git clone "$url" /go/src/repo
### end clone repo ###

### setup environment variables ###
export OS_TYPE=$osType
export CLUSTER_PRIVATE_KEY=$(cat /clusterPrivateKey | base64 )

### generate yaml ###
cd /go/src/repo/clusterctl/examples/ssh
./generate-yaml.sh

cat /go/src/repo/clusterctl/examples/ssh/out/provider-components.yaml > /provider-components.yaml
