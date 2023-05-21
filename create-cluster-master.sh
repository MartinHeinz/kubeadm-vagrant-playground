sudo su -

kubeadm init --config=/vagrant/kubernetes/kubeadm-config.yaml --upload-certs --ignore-preflight-errors ExternalEtcdVersion | tee kubeadm-init.out

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
