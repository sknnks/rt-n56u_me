#!/bin/sh

NAME=aliyundrive-webdav
app_dir=$(nvram get aliyundrive_dir)
alibin="$app_dir/$NAME"

check() {
	[ ! -f $alibin ] && {
		[ ! -d "$app_dir" ] && mkdir -p $app_dir
		logger -t "【阿里云webdav】" "未发现程序，稍后自动下载，不同网络情况所需时长不同，请耐心等待!"
		if [ "$(ping 114.114.114.114 -c 1 -w 10 | grep -o ttl)" ] || [ "$(ping 114.114.115.115 -c 1 -w 10 | grep -o ttl)" ];then
			logger -t "【阿里云webdav】" "检测设备联网成功，正在下载程序，请稍后..."
			ver="v1.7.1"
			url="https://github.com/messense/$NAME/releases/download/$ver/$NAME-$ver.mipsel-unknown-linux-musl.tar.gz"
			wget --no-check-certificate $url -O ald_webdav.tar.gz && tar -zxvf ald_webdav.tar.gz -C $app_dir && rm -f ald_webdav.tar.gz
			[ -f $alibin ] && [ ! -x $alibin ] &&  chmod +x $alibin	
			[ -x $alibin ] && logger -t "【阿里云webdav】" "程序下载完成，保存程序文件..."
		else
			logger -t "【阿里云webdav】" "设备未联网，无法下载程序,请检查网络连接后再尝试!" && exit
		fi
	}
}

start_ald() {
	/etc/storage/aliyundrive_script.sh
	[ -n "`pgrep aliyundrive`" ] && logger -t "【阿里云webdav】" "启动成功!"
}

kill_ald() {
	aliyun_process=$(pidof $NAME)
	if [ -n "$aliyun_process" ]; then
		logger -t "阿里云盘" "关闭进程..."
		killall -q $NAME >/dev/null 2>&1
		kill -9 "$aliyun_process" >/dev/null 2>&1
	fi
}

stop_ald() {
	kill_ald
}


case $1 in
start)
	check
	start_ald
	;;
stop)
	stop_ald
	;;
*)
	echo "check"
	#exit 0
	;;
esac
