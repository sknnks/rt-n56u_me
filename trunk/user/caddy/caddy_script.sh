#!/bin/sh
caddy_storage=`nvram get caddy_storage`
caddy_dir=`nvram get caddy_dir`
caddyf_wan_port=`nvram get caddyf_wan_port`

caddybin="/usr/bin/filebrowser"
if [ ! -f "$caddybin" ]; then
caddybin="$caddy_dir/caddy/filebrowser"
fi

if [ ! -e /etc/storage/filebrowser.db ]; then
 $caddybin -d /etc/storage/filebrowser.db config init
 $caddybin -d /etc/storage/filebrowser.db users add admin admin --perm.admin
 $caddybin -d /etc/storage/filebrowser.db config set --address 0.0.0.0 --locale zh-cn
 [ ! -d "$caddy_dir/caddy/cache" ] && mkdir 777 "$caddy_dir/caddy/cache"
fi

$caddybin -d /etc/storage/filebrowser.db config set \
 --port $caddyf_wan_port \
 --root $caddy_storage
 
$caddybin -d /etc/storage/filebrowser.db --disable-preview-resize --disable-type-detection-by-header --cache-dir $caddy_dir/caddy/cache &
