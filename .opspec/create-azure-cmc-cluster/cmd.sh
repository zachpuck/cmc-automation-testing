#!/usr/bin/env sh

### begin login
loginCmd='az login -u "$loginId" -p "$loginSecret"'

# handle opts
if [ "$loginTenantId" != " " ]; then
    loginCmd=$(printf "%s --tenant %s" "$loginCmd" "$loginTenantId")
fi

case "$loginType" in
    "user")
        echo "logging in as user"
        ;;
    "sp")
        echo "logging in as service principal"
        loginCmd=$(printf "%s --service-principal" "$loginCmd")
        ;;
esac
eval "$loginCmd" >/dev/null

echo "setting default subscription"
az account set --subscription "$subscriptionId"
### end login

echo "checking for existing cmc"
if [ "$(az aks show --resource-group "$resourceGroup" --name "$name")" != "" ]
then
  echo "found exiting cmc"
else
    echo "creating cmc"
    az aks create -n $name -g $resourceGroup --ssh-key-value /sshKeyValue --kubernetes-version $k8sVersion --service-principal $clusterAccountId --client-secret $clusterAccountSecret
fi
