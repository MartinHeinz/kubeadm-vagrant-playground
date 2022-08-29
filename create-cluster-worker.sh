cat << EOF
Setup worker using:

vagrant ssh kubemaster
sudo su -
kubeadm token create --print-join-command
exit

vagrant ssh kubenode0X
sudo su -
kubeadm join ...
exit
EOF