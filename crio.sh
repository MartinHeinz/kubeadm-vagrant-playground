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

curl -OLs https://golang.org/dl/go1.19.linux-amd64.tar.gz
sudo tar -C /usr/local -xvf go1.19.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
source ~/.profile

git clone https://github.com/adrianreber/cri-o.git
cd cri-o
git checkout checkpoint-restore-support-oci
make
make install
make install.config
make install.systemd

sudo mkdir -p /etc/cni/net.d
sudo cp contrib/cni/10-crio-bridge.conf /etc/cni/net.d
cd ..

git clone https://github.com/containernetworking/plugins
cd plugins
git checkout v1.1.1
./build_linux.sh
mkdir -p /opt/cni/bin
cp bin/* /opt/cni/bin/
cd ..

git clone https://github.com/containers/conmon
cd conmon
make
make install
cd ..

# Enable CRIU support in /etc/crio/crio.conf (enable_criu_support = true)
sed -i -e 's/# enable_criu_support = false/enable_criu_support = true/g' /etc/crio/crio.conf

sudo apt install criu

sudo systemctl daemon-reload
sudo systemctl enable crio
sudo systemctl start crio