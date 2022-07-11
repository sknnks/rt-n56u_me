#!/bin/sh

NAME=aliyundrive-webdav

start_ald() {
	/etc/storage/aliyundrive_script.sh
	if [ $? -ne 0 ]; then
		logger -t "【阿里云webdav】" "启动失败，可能是网络连接受阻！"
		nvram set aliyundrive_enable=0
		stop_ald
	else
		aliyun_process=$(pidof $NAME)
		if [ -n "$aliyun_process" ]; then
			echo $aliyun_process > /var/run/aliyun.pid 2>&1 && logger -t "【阿里云webdav】" "启动成功!"
		fi
	fi

}

stop_ald() {
	aliyun_process=$(pidof $NAME)
	if [ -n "$aliyun_process" ]; then
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
