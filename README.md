# Kubernetes Cluster Playground Environment

Kubernetes playground cluster based on Vagrant, `kubeadm`, `containerd` and Calico

## Setup

```shell
vagrant up
vagrant ssh kubemaster
```

## Customization

To change feature flags, modify `./kubernetes/kubeadm-config.yaml`

- Update `KubeletConfiguration.featureGates` stanza
- Update `extraArgs.feature-flags` in `ClusterConfiguration` for each component

## Other

View containers:

```shell
crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock ps
```