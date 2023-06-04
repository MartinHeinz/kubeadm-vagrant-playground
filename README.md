# Kubernetes Cluster Playground Environment

Kubernetes playground cluster based on Vagrant, `kubeadm` and CRI-O

Branches:

- `master` - General purpose cluster
- `container-checkpoint-api` - Configuration that supports Kubernetes Checkpointing API ([more info](https://martinheinz.dev/blog/85))
- `k8s-without-etcd` - Cluster that uses PostgreSQL database instead of `etcd`

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
crictl ps
```

-----

If you find this useful, you can support me on Ko-Fi (Donations are always appreciated, but never required):

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/K3K6F4XN6)
