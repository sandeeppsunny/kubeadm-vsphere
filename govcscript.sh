#!/bin/bash
# Test VC connection
govc about

echo "Creating a cluster of $N worker nodes!"

# Import k8s-node-template ova
echo "Importing node template..."

KUBERNETES_OVA=`govc vm.info k8s-node-template`

if [[ -z $KUBERNETES_OVA ]]; then
   govc import.ova http://pa-dbc1110.eng.vmware.com/sandeepsunny/ovftool/ovftool/k8s-node-template.ova
fi

for (( c=0; c<=N; c++ ))
do
   if [ "$c" == "0" ]; then
      echo "Creating master node..."
      govc vm.clone -vm k8s-node-template master &
   else
      echo "Creating worker-$c node..."
      govc vm.clone -vm k8s-node-template worker-$c &
   fi
done

wait

sleep 2m

echo "Getting master node IP address..."
MASTER=$(govc find / -type m -name 'master' | xargs govc vm.info | grep 'Name:\|IP' | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

echo "Getting worker node IP addresses..."
WORKERS=$(govc find / -type m -name 'worker-*' | xargs govc vm.info | grep 'Name:\|IP' | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

echo "[master]" >> /etc/ansible/hosts
echo "$MASTER" >> /etc/ansible/hosts

export MASTER_IP="$MASTER"

echo "[workers]" >> /etc/ansible/hosts

for worker in "${WORKERS[@]}"
do
   echo "$worker" >> /etc/ansible/hosts
done

cat /etc/ansible/hosts

sed -i 's/#host_key_checking/host_key_checking/g' /etc/ansible/ansible.cfg
sed -i 's/#remote_user = root/remote_user = ubuntu/g' /etc/ansible/ansible.cfg

ansible -m ping all
ansible-playbook /master-playbook.yaml
ansible-playbook /worker-playbook.yaml
