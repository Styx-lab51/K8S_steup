hostnamectl hostname node01

cat <<EOF | sudo tee /etc/NetworkManager/system-connections/enp1s0.nmconnection
[connection]
id=enp1s0
uuid=09ff4a39-20f5-3017-9dba-6adff5ca8a5f
type=ethernet
autoconnect-priority=-999
interface-name=enp1s0
timestamp=1705234019

[ethernet]

[ipv4]
address1=192.168.0.210/24,192.168.0.1
dns=8.8.8.8;
ignore-auto-dns=true
method=manual

[ipv6]
addr-gen-mode=eui64
method=disabled

[proxy]
EOF
