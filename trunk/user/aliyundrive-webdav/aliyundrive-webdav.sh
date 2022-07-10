#!/bin/sh

NAME=aliyundrive-webdav

start_ald() {
	/etc/storage/aliyundrive_script.sh
	[ -n "$(pidof $NAME)" ] && logger -t "【阿里云webdav】" "启动成功!"
}

stop_ald() {
	aliyun_process=$(pidof $NAME)
	if [ -n "$aliyun_process" ]; then
		logger -t "阿里云盘" "关闭进程..."
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
