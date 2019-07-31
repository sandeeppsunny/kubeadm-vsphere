# Setting up a k8s cluster on vsphere with kubeadm

This project follows the steps from the following blog to create a k8s cluster on vsphere.
- https://blah.cloud/kubernetes/creating-an-ubuntu-18-04-lts-cloud-image-for-cloning-on-vmware/
- https://blah.cloud/kubernetes/setting-up-k8s-and-the-vsphere-cloud-provider-using-kubeadm/

# Steps to run
1. git clone this repository
2. docker build .
3. modify env.list file accordingly
4. docker run --env-file env.list <image-id>

This project uses ansible to execute the kube-adm commands on all the nodes.
