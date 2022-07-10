#!/bin/sh

enable=$(nvram get aliyundrive_enable)
refresh_token=$(nvram get ald_refresh_token)
app_dir=$(nvram get aliyundrive_dir)
read_buffer_size=$(nvram get ald_read_buffer_size)
cache_size=$(nvram get ald_cache_size)
cache_ttl=$(nvram get ald_cache_ttl)
host=$(nvram get ald_host)
port=$(nvram get ald_port)
root=$(nvram get ald_root)
domain_id=$(nvram get ald_domain_id)
auth_user=$(nvram get ald_auth_user)
auth_pswd=$(nvram get ald_auth_password)

if [ `echo -n $refresh_token | sed 's/^app://' | wc -c` = "32" ];then
	echo $refresh_token > $alirun/refresh_token
else
	logger -t "【阿里云webdav】" "错误提示" "refresh_token 参数有误，请检查后重启路由器！"
	exit 1
fi

extra_options="-I"
if [ "$domain_id" = "99999" ]; then
	extra_options="$extra_options --domain-id $domain_id"
else
	case "$(nvram get ald_no_trash)" in
	1|on|true|yes|enabled)
		extra_options="$extra_options --no-trash"
		;;
	*)	;;
	esac

        case "$(nvram get ald_read_only)" in
	1|on|true|yes|enabled)
		extra_options="$extra_options --read-only"
		;;
	*)	;;
        esac
fi

case "$enable" in
1|on|true|yes|enabled)
	alibin="$app_dir/aliyundrive-webdav"
	options="--host $host --port $port --root $root --refresh-token $refresh_token -S $read_buffer_size --cache-size $cache_size --cache-ttl $cache_ttl --workdir $app_dir"
	if [ -n $auth_user -a -n $auth_pswd ]; then
		$alibin $extra_options -U $auth_user -W $auth_pswd $options >/dev/null 2>&1 &
	else
		$alibin $extra_options $options >/dev/null 2>&1 &
	fi
	;;
*)	;;
esac

