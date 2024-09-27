# k8s-provisioning-script
Just a bunch of bash lines to create kubernetes cluster, pliz don't use in production )

## Tools used
* kubeadm
* kubectl
* kubelet
* cni + cilium
* cri + runc + containerd
* k9s


## Reference
https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd
https://github.com/containerd/containerd/releases
https://github.com/containerd/containerd/blob/main/docs/getting-started.md
https://github.com/containerd/containerd/tree/main/script/setup
https://github.com/containerd/containerd/blob/main/docs/getting-started.md#step-2-installing-runc
https://github.com/opencontainers/runc/releases
https://github.com/containerd/containerd/blob/main/docs/getting-started.md#step-3-installing-cni-plugins
https://github.com/containernetworking/plugins/releases
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#swap-configuration
https://superuser.com/a/1745419
https://devops-journey.uz/guides/k8s/k8s-architecture
https://forum.linuxfoundation.org/discussion/863834/error-when-trying-to-run-kubeadm-join
https://medium.com/@mrdevsecops/set-up-a-kubernetes-cluster-with-kubeadm-508db74028ce
https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#install-the-cilium-cli
https://github.com/derailed/k9s/releases