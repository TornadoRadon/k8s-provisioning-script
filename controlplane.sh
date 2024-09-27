##########################################################
##                 systemconfiguration                  ##
##########################################################


## check if swap disabled. if result empty then disabled.
swapon --show
## disable
swapoff -a
# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF
# Apply sysctl params without reboot
sudo sysctl --system
## Verify that net.ipv4.ip_forward is set to 1 with:
sysctl net.ipv4.ip_forward


##########################################################
##                  containerd                          ##
##########################################################


## Download containerd
curl -LO https://github.com/containerd/containerd/releases/download/v1.7.22/containerd-1.7.22-linux-amd64.tar.gz
## Extract
tar Cxzvf /usr/local containerd-1.7.22-linux-amd64.tar.gz
## Download service file
curl -LO https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
mv containerd.service /etc/systemd/system/containerd.service
## Enable
systemctl daemon-reload
systemctl enable --now containerd

## containerd configure
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml


## To use the systemd cgroup driver in /etc/containerd/config.toml with runc, set
## 
## [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
##   ...
##   [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
##     SystemdCgroup = true
sed -i "s/\bSystemdCgroup = false\b/SystemdCgroup = true/g" /etc/containerd/config.toml 

## restart containerd
systemctl restart containerd


##########################################################
##                      runc                            ##
##########################################################


## download runC
curl -LO https://github.com/opencontainers/runc/releases/download/v1.1.14/runc.amd64
## install
install -m 755 runc.amd64 /usr/local/sbin/runc


##########################################################
##                      cni                             ##
##########################################################


## download CNI
curl -LO https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-amd64-v1.5.1.tgz
## install
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.5.1.tgz

## change ownership
chown root:root /opt/cni -R


##########################################################
##              kubelet,kubeadm,kubectl                 ##
##########################################################


sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
## install
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
## enable
sudo systemctl enable --now kubelet

## initialize kubernetes control plane
kubeadm init

: '

#### EXAMPLE OUTPUT ####

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

	kubeadm join 10.12.0.24:6443 --token 62ef99.fzsdc4xjnggc8cbh \
        --discovery-token-ca-cert-hash sha256:5b8e1d07e448131d01928cd1d9e7f6a9b5255a196b 
        
You can regenarate token with:
	kubeadm token create --print-join-command
'

export KUBECONFIG=/etc/kubernetes/admin.conf


##########################################################
##                      cilium                          ##
##########################################################


CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

## install
## for tighter integration use: cilium install --set kubeProxyReplacement=true
cilium install

## wait
cilium status --wait


##########################################################
##                      k9s                             ##
##########################################################

## https://github.com/derailed/k9s/releases
curl -LO https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_linux_amd64.deb
dpkg -i k9s_linux_amd64.deb