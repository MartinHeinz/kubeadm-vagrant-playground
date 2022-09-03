cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_22.04/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.25:/1.25.0/xUbuntu_22.04/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:v1.25.0.list

curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_22.04/Release.key | apt-key add -

# https://github.com/cri-o/cri-o/blob/main/install.md#debian-bullseye-or-higher---ubuntu-2004-or-higher
apt-get update -qq && apt-get install -y \
  libbtrfs-dev \
  containers-common \
  git \
  golang-go \
  libassuan-dev \
  libdevmapper-dev \
  libglib2.0-dev \
  libc6-dev \
  libgpgme-dev \
  libgpg-error-dev \
  libseccomp-dev \
  libsystemd-dev \
  libselinux1-dev \
  pkg-config \
  go-md2man \
  cri-o-runc \
  libudev-dev \
  software-properties-common \
  gcc \
  make \
  runc

git clone https://github.com/adrianreber/cri-o.git
cd cri-o
make
sudo make install
sudo make install.config
sudo make install.systemd

sudo cp contrib/cni/10-crio-bridge.conf /etc/cni/net.d
cd ..

git clone https://github.com/containernetworking/plugins
cd plugins
git checkout v1.1.1
./build_linux.sh
sudo mkdir -p /opt/cni/bin
sudo cp bin/* /opt/cni/bin/
cd ..

git clone https://github.com/containers/conmon
cd conmon
make
sudo make install

sudo systemctl daemon-reload
sudo systemctl enable crio
sudo systemctl start crio