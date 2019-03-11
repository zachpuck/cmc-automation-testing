# cmc automation testing

automates the creation of resource necessary to test a cluster manager cluster

this repo utilized [opctl](https://opctl.io/docs/) to run all steps. see [installation details](https://opctl.io/docs/getting-started/opctl.html)

# Prerequisites
1. Docker
2. opctl


## environment setup
create a .env folder and place the following files (TODO: generate these files)

`id_rsa.pub`

`id_rsa`

# Usage
list all available ops
```
opctl ls
```
to create the machines for testing: (this will ask for your azure ServicePrincipal ID and Secret, it will also ask for the prefix name for the vms)
```
opctl run create-azure-infra
```


# Todo:
1. make call to cma-vmware to create cluster
2. add aws cmc op
