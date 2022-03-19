#!/bin/sh
caddy_storage=`nvram get caddy_storage`
caddy_dir=`nvram get caddy_dir`
caddy_file=`nvram get caddy_file`
caddyf_wan_port=`nvram get caddyf_wan_port`
caddyw_wan_port=`nvram get caddyw_wan_port`
caddy_wname=`nvram get caddy_wname`
caddy_wpassword=`nvram get caddy_wpassword`
caddyfile="$caddy_dir/caddy/caddyfile"
rm -f $caddyfile

cat <<-EOF >/tmp/cf
:$caddyf_wan_port {
 root $caddy_storage
 timeouts none
 gzip
 filebrowser / $caddy_storage {
  database /etc/storage/filebrowser.db
 }
}
EOF

cat /tmp/cf > $caddyfile
rm -f /tmp/cf
caddybin="/usr/bin/filebrowser"
if [ ! -f "$caddybin" ]; then
caddybin="$caddy_dir/caddy/filebrowser"
fi
$caddybin -conf $caddyfile &
