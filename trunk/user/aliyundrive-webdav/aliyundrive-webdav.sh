#!/bin/sh

NAME=aliyundrive-webdav
ald_port=$(nvram get ald_port)

start_ald() {
	/etc/storage/aliyundrive_script.sh
	if [ $? -ne 0 ]; then
		logger -t "【阿里云webdav】" "启动失败，可能是网络连接受阻！"
		nvram set aliyundrive_enable=0
		stop_ald
	else
		aliyun_process=$(pidof $NAME)
		if [ -n "$aliyun_process" ]; then
			wport=$(iptables -t filter -L INPUT -v -n --line-numbers | grep dpt:$ald_port | cut -d " " -f 1 | sort -nr | wc -l)
			if [ "$wport" = 0 ]; then
				iptables -t filter -I INPUT -p tcp --dport $ald_port -j ACCEPT
				ip6tables -t filter -I INPUT -p tcp --dport $ald_port -j ACCEPT
			fi
			echo $aliyun_process > /var/run/aliyun.pid 2>&1 && logger -t "【阿里云webdav】" "启动成功!"
		fi
	fi
}

stop_ald() {
	aliyun_process=$(pidof $NAME)
	if [ -n "$aliyun_process" ]; then
		iptables -t filter -D INPUT -p tcp --dport $ald_port -j ACCEPT
		ip6tables -t filter -D INPUT -p tcp --dport $ald_port -j ACCEPT
		logger -t "【阿里云webdav】" "关闭进程..."
		killall -q $NAME >/dev/null 2>&1
		kill -9 "$aliyun_process" >/dev/null 2>&1
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
