#!/bin/bash

export scriptrun="sudo bash /tmp/tld-local.sh"

if ! grep -q "${TLD}" /opt/bitnami/tld-local.sh ; then
    ORG_TLD="customerdomain.local"
    sed -i -e "s~$ORG_TLD~$TLD~g" /opt/bitnami/tld-local.sh
fi

for CLUSTERNAME in $(KUBECONFIG=/.kube/config/admin.conf kubectl get tkc -o=json -n $NS|jq -r '.items[].metadata.name')
do
   echo "$CLUSTERNAME"
   export VMS=$(KUBECONFIG=/.kube/config/admin.conf kubectl get vm -n $NS|grep $CLUSTERNAME|awk '{print $1}')
   for VM in $(KUBECONFIG=/.kube/config/admin.conf kubectl get vm -n $NS|grep $CLUSTERNAME|awk '{print $1}')
   do
       export VM_IP=$(KUBECONFIG=/.kube/config/admin.conf kubectl get vm $VM -n $NS -o jsonpath='{.status.vmIp}')
       export VM_SECRET=$(KUBECONFIG=/.kube/config/admin.conf kubectl get secret $CLUSTERNAME-ssh-password -n $NS -o jsonpath='{.data.ssh-passwordkey}'|base64 -d)
       echo $VM " " $VM_IP " " $VM_SECRET
       go run /opt/bitnami/run-scp.go
       go run /opt/bitnami/run-remote.go
       echo " "
   done
done
exit 0