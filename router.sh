#!/bin/bash
set -e

# ============================================================
#  Script   : Setup Router
#  Author   : Adit Setya Nugroho
#
#  Description:
#     Script otomatis konfigurasi Ubuntu sebagai Router Gateway
#     dengan interface:
#          - WAN : ens33 (DHCP)
#          - LAN : ens34 (Static 192.168.5.1/24)
#
#     Fitur script:
#        - Netplan auto apply
#        - Enable IPv4 Forwarding
#        - NAT Masquerading (iptables)
#        - DHCP Server otomatis (range 192.168.5.100–200)
#        - Persistent iptables
#
# ============================================================

# update sistem
sudo apt update && sudo apt upgrade -y

# konfigurasi netplan
sudo tee /etc/netplan/50-gateway.yaml > /dev/null <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: true
    ens34:
      dhcp4: false
      addresses:
        - 192.168.5.1/24
EOF

sudo netplan apply

# mengaktifkan ip forwarding
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p

# iptables
sudo iptables -t nat -A POSTROUTING -o ens33 -j MASQUERADE
sudo iptables -A FORWARD -i ens33 -o ens34 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i ens34 -o ens33 -j ACCEPT

sudo apt install -y iptables-persistent
sudo netfilter-persistent save

# DHCP server
sudo tee /etc/dhcp/dhcpd.conf > /dev/null <<EOF
default-lease-time 600;
max-lease-time 7200;
authoritative;

subnet 192.168.5.0 netmask 255.255.255.0 {
    range 192.168.5.100 192.168.5.200;
    option routers 192.168.5.1;
    option domain-name-servers 8.8.8.8, 1.1.1.1;
}
EOF

echo 'INTERFACESv4="ens34"' | sudo tee /etc/default/isc-dhcp-server > /dev/null

sudo systemctl restart isc-dhcp-server
sudo systemctl enable isc-dhcp-server

# verivikasi
ip a
ip route
iptables -t nat -L -n
