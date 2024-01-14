sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
swapoff -a

echo '192.168.0.210	node01' >> /etc/hosts
echo '192.168.0.220	node02' >> /etc/hosts
echo '192.168.0.230	master' >> /etc/hosts

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | sudo tee test.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

curl https://get.docker.com -o install_docker.sh
chmod +x install_docker.sh
./install_docker.sh

systemctl daemon-reload
systemctl enable docker --now
systemctl status docker

rm -f /etc/containerd/config.toml

systemctl restart containerd
systemctl status containerd

sed -i '/^ExecStart/ s/$/ --exec-opt native.cgroupdriver=systemd/' /usr/lib/systemd/system/docker.service

setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet
systemctl status kubelet

exit
