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

echo "checking for existing control plane"
if [ "$(az vm show --resource-group "$resourceGroup" --name "$name-cp")" != "" ]
then
  echo "found exiting control plane"
else
    echo "creating control plane vm"
    az vm create -n $name-cp -g $resourceGroup --image $image --admin-username $adminUsername --ssh-key-value /sshKeyValue --query "publicIpAddress" --output tsv > /controlPlaneIP 
fi

echo "checking for existing node"
if [ "$(az vm show --resource-group "$resourceGroup" --name "$name-node")" != "" ]
then
  echo "found exiting node"
else
    echo "creating node vm"
    az vm create -n $name-node -g $resourceGroup --image $image --admin-username $adminUsername --ssh-key-value /sshKeyValue --query "publicIpAddress" --output tsv > /nodeIP
fi

# open port for api server
echo "opening 443 port on NSG for kubernetes api"
az network nsg rule create -n kubernetesAPIAccess -g $resourceGroup --nsg-name $name-cpNSG  --priority 101 --destination-port-ranges 443 > /dev/null
