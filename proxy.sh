# note : change 192.168.0.1 to your global ip address

# allow forward
sudo sysctl -w net.ipv4.ip_forward=1
sudo nft insert rule filter FORWARD ip saddr 192.168.0.1 accept
sudo nft insert rule filter FORWARD ip daddr 192.168.0.1 accept
# palworld nat
sudo nft add rule nat PREROUTING udp dport 8211 dnat to 192.168.0.1:8211
sudo nft add rule nat POSTROUTING ip daddr 192.168.0.1 udp dport 8211 masquerade
