#!/bin/sh

NAME=aliyundrive-webdav
ald_port=$(nvram get ald_port)
ald_port=$(nvram get aliyun_wan)

start_ald() {
	if [ -z "$(pidof $NAME)" ]; then
		logger -t "【阿里云webdav】" "程序加载中，请稍等..."
		/etc/storage/aliyundrive_script.sh
		if [ $? -ne 0 ]; then
			logger -t "【阿里云webdav】" "启动失败，可能是网络连接受阻！"
			nvram set aliyundrive_enable=0
			stop_ald
			exit 1
		fi
	[ -n "$(pidof $NAME)" ] && echo "$(pidof $NAME)" > /var/run/aliyun.pid 2>&1 && logger -t "【阿里云webdav】" "启动成功!"
	fi
	
	if [ "$aliyun_wan" -eq 1 ]; then
		ip_rules "add" && logger -t "【阿里云webdav】" "WAN $ald_port 端口开放"
	else
		ip_rules "del" && logger -t "【阿里云webdav】" "WAN $ald_port 端口关闭"
	fi
}

stop_ald() {
	aliyun_process=$(pidof $NAME)
	if [ -n "$aliyun_process" ]; then
		logger -t "【阿里云webdav】" "关闭程序..."
		ip_rules "del"
		killall -q $NAME >/dev/null 2>&1
		kill -9 "$aliyun_process" >/dev/null 2>&1
	fi
}

ip_rules(){
	if [ "$1" = "add" ]; then
		if [ -z "$(iptables -t filter -L INPUT -v -n --line-numbers | grep "tcp dpt:$ald_port" ]; then
			iptables -t filter -I INPUT -p tcp --dport $ald_port -j ACCEPT
			ip6tables -t filter -I INPUT -p tcp --dport $ald_port -j ACCEPT
		fi
	elif [ "$1" = "del" ]; then 
		if [ -n "$(iptables -t filter -L INPUT -v -n --line-numbers | grep "tcp dpt:$ald_port" ]; then
			iptables -t filter -D INPUT -p tcp --dport $ald_port -j ACCEPT
			ip6tables -t filter -D INPUT -p tcp --dport $ald_port -j ACCEPT
		fi
	fi
}

case $1 in
start)
	start_ald
	;;
stop)
	stop_ald
	;;
*)
	echo "check"
	;;
esac
