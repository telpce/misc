# CaddyとCloudflareを共存させる作戦は2つ
# 1. Cloudflareで証明書を作成し、それをCaddyで使う作戦
# 2. CloudflareのDNSを認識できるモジュール適用したCaddyを用いる作戦
#
# 1は、それならCloudflaredを使う方が良さそうなので却下
# 2を試す。apt updateできないのは難点
#

# アーキテクチャ確認
dpkg --print-architecture

# 適切なバイナリを落とす
# wgetの仕方がわからなかったが、以下のウェブサイトから落とせる
# https://caddyserver.com/download

# 落としたcaddyを移動
sudo mv caddy /usr/local/bin
sudo chmod +x /usr/local/bin/caddy

# 以下はマニュアル通り
# https://caddyserver.com/docs/running#manual-installation
sudo groupadd --system caddy
sudo useradd --system \
    --gid caddy \
    --create-home \
    --home-dir /var/lib/caddy \
    --shell /usr/sbin/nologin \
    --comment "Caddy web server" \
    caddy

wget https://raw.githubusercontent.com/caddyserver/dist/master/init/caddy.service
# パスがおかしいので修正
sed -i -e "s#/usr/bin/caddy#/usr/local/bin/caddy#g" caddy.service
# 移動
sudo mv caddy.service /etc/systemd/system/

# Caddyfileを作る工程がないので作る(サンプルは同梱している)
sudo mkdir /etc/caddy
sudo touch /etc/caddy/Caddyfile
# ln -s /etc/caddy/Caddyfile Caddyfile
# unlink Caddyfile

# cloudflareのAPIトークン取得
# https://roelofjanelsinga.com/articles/using-caddy-ssl-with-cloudflare/

# 以下はCaddyfileが整っていないと動かない
sudo systemctl daemon-reload
sudo systemctl enable --now caddy

# ポート開放 nftableじゃないけど許して
sudo iptables -I INPUT 5 -p tcp --dport 80 -j ACCEPT 
sudo iptables -I INPUT 5 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 5 -p udp --dport 443 -j ACCEPT


