#!/bin/sh
caddy_storage=`nvram get caddy_storage`
caddy_dir=`nvram get caddy_dir`
caddyf_wan_port=`nvram get caddyf_wan_port`
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
