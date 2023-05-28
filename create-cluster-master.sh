sudo su -

kubeadm init --config=/vagrant/kubernetes/kubeadm-config.yaml --upload-certs --ignore-preflight-errors ExternalEtcdVersion || true

yq '. *+ load("/vagrant/kubernetes/apiserver-patch.yaml")' /vagrant/kubernetes/kube-apiserver.yaml > /etc/kubernetes/manifests/kube-apiserver.yaml

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

systemctl restart kubelet