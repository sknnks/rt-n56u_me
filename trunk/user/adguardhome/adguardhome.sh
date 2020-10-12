#!/bin/sh

change_dns() {
if [ "$(nvram get adg_redirect)" = 1 ]; then
sed -i '/no-resolv/d' /etc/storage/dnsmasq/dnsmasq.conf
sed -i '/server=127.0.0.1/d' /etc/storage/dnsmasq/dnsmasq.conf
cat >> /etc/storage/dnsmasq/dnsmasq.conf << EOF
no-resolv
server=127.0.0.1#5335
EOF
/sbin/restart_dhcpd
logger -t "AdGuardHome" "添加DNS转发到5335端口"
fi
}
del_dns() {
sed -i '/no-resolv/d' /etc/storage/dnsmasq/dnsmasq.conf
sed -i '/server=127.0.0.1#5335/d' /etc/storage/dnsmasq/dnsmasq.conf
/sbin/restart_dhcpd
}

set_iptable()
{
    if [ "$(nvram get adg_redirect)" = 2 ]; then
	IPS="`ifconfig | grep "inet addr" | grep -v ":127" | grep "Bcast" | awk '{print $2}' | awk -F : '{print $2}'`"
	for IP in $IPS
	do
		iptables -t nat -A PREROUTING -p tcp -d $IP --dport 53 -j REDIRECT --to-ports 5335 >/dev/null 2>&1
		iptables -t nat -A PREROUTING -p udp -d $IP --dport 53 -j REDIRECT --to-ports 5335>/dev/null 2>&1
	done

	IPS="`ifconfig | grep "inet6 addr" | grep -v " fe80::" | grep -v " ::1" | grep "Global" | awk '{print $3}'`"
	for IP in $IPS
	do
		ip6tables -t nat -A PREROUTING -p tcp -d $IP --dport 53 -j REDIRECT --to-ports 5335 >/dev/null 2>&1
		ip6tables -t nat -A PREROUTING -p udp -d $IP --dport 53 -j REDIRECT --to-ports 5335 >/dev/null 2>&1
	done
    logger -t "AdGuardHome" "重定向53端口"
    fi
}

clear_iptable()
{
	OLD_PORT="5335"
	IPS="`ifconfig | grep "inet addr" | grep -v ":127" | grep "Bcast" | awk '{print $2}' | awk -F : '{print $2}'`"
	for IP in $IPS
	do
		iptables -t nat -D PREROUTING -p udp -d $IP --dport 53 -j REDIRECT --to-ports $OLD_PORT >/dev/null 2>&1
		iptables -t nat -D PREROUTING -p tcp -d $IP --dport 53 -j REDIRECT --to-ports $OLD_PORT >/dev/null 2>&1
	done

	IPS="`ifconfig | grep "inet6 addr" | grep -v " fe80::" | grep -v " ::1" | grep "Global" | awk '{print $3}'`"
	for IP in $IPS
	do
		ip6tables -t nat -D PREROUTING -p udp -d $IP --dport 53 -j REDIRECT --to-ports $OLD_PORT >/dev/null 2>&1
		ip6tables -t nat -D PREROUTING -p tcp -d $IP --dport 53 -j REDIRECT --to-ports $OLD_PORT >/dev/null 2>&1
	done
	
}

getconfig(){
adg_file="/etc/storage/adg.sh"
if [ ! -f "$adg_file" ] || [ ! -s "$adg_file" ] ; then
	cat > "$adg_file" <<-\EEE
bind_host: 0.0.0.0
bind_port: 3333
users: []
#auth_name: admin
#auth_pass: admin
language: zh-cn
rlimit_nofile: 0
dns:
  bind_host: 0.0.0.0
  port: 5335
  protection_enabled: true
  filtering_enabled: true
  blocking_mode: nxdomain
  blocked_response_ttl: 10
  querylog_enabled: true
  ratelimit: 20
  ratelimit_whitelist: []
  refuse_any: true
  bootstrap_dns:
  - 127.0.0.1:6053
  all_servers: true
  allowed_clients: []
  disallowed_clients: []
  blocked_hosts: []
  parental_sensitivity: 0
  parental_enabled: false
  safesearch_enabled: false
  safebrowsing_enabled: false
  resolveraddress: ""
  upstream_dns:
  - 127.0.0.1:6053
tls:
  enabled: false
  server_name: ""
  force_https: false
  port_https: 443
  port_dns_over_tls: 853
  certificate_chain: ""
  private_key: ""
filters:
- enabled: true
  url: https://anti-ad.net/easylist.txt
  name: anti-ad-easylist默认开第1个
  id: 1581953052
- enabled: true
  url: https://halflife.coding.net/p/list/d/list/git/raw/master/ad.txt
  name: AdFilters默认开第2个
  id: 1593095159
- enabled: false
  url: https://raw.githubusercontent.com/googlehosts/hosts/master/hosts-files/hosts
  name: googlehosts(正确出墙IP)
  id: 1594487153
- enabled: false
  url: https://gitlab.com/xuhaiyang1234/AAK-Cont/raw/master/FINAL_BUILD/aak-cont-list-notubo.txt
  name: AAK-Cont Filter For AdBlock, Adblock Plus, etc
  id: 1565484163
- enabled: false
  url: https://raw.githubusercontent.com/reek/anti-adblock-killer/master/anti-adblock-killer-filters.txt
  name: AakList (Anti-Adblock Killer)
  id: 1565484164
- enabled: false
  url: https://raw.githubusercontent.com/cjx82630/cjxlist/master/cjxlist.txt
  name: CJX's EasyList Lite
  id: 1565484165
- enabled: false
  url: https://easylist-downloads.adblockplus.org/easylistchina.txt
  name: EasyList China
  id: 1565484166
- enabled: false
  url: https://hosts-file.net/.%5Cad_servers.txt
  name: hpHosts’ Ad and tracking servers
  id: 1565484167
- enabled: false
  url: https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=1&mimetype=plaintext
  name: Peter Lowe’s Ad and tracking server list​
  id: 1565484168
- enabled: false
  url: https://easylist.to/easylist/fanboy-social.txt
  name: Fanboy's Social Blocking List
  id: 1565484169
- enabled: false
  url: https://easylist.to/easylist/fanboy-annoyance.txt
  name: Fanboy's Annoyance List
  id: 1565484170
- enabled: false
  url: https://secure.fanboy.co.nz/fanboy-cookiemonster.txt
  name: Fanboy's Cookie List
  id: 1565484171
- enabled: false
  url: https://fanboy.co.nz/fanboy-antifacebook.txt
  name: Anti-Facebook List
  id: 1565484172
- enabled: false
  url: https://filters.adtidy.org/extension/ublock/filters/14.txt
  name: AdGuard Annoyances filter
  id: 1565484173
- enabled: false
  url: https://raw.githubusercontent.com/Spam404/lists/master/adblock-list.txt
  name: Spam404
  id: 1565484174
- enabled: false
  url: https://gitcdn.xyz/repo/NanoMeow/MDLMirror/master/hosts.txt
  name: Malware Domain List
  id: 1565484176
- enabled: false
  url: https://www.fanboy.co.nz/enhancedstats.txt
  name: Fanboy's Enhanced Tracking List
  id: 1565484178
- enabled: false
  url: https://easylist.to/easylist/easyprivacy.txt
  name: EasyPrivacy
  id: 1565484179
- enabled: false
  url: https://filters.adtidy.org/extension/ublock/filters/3.txt
  name: AdGuard Tracking Protection filter
  id: 1565484180
- enabled: false
  url: https://easylist.to/easylist/easylist.txt
  name: EasyList
  id: 1565484181
- enabled: false
  url: https://filters.adtidy.org/extension/ublock/filters/11.txt
  name: AdGuard Mobile Ads filter
  id: 1565484182
- enabled: false
  url: https://filters.adtidy.org/extension/ublock/filters/2_without_easylist.txt
  name: AdGuard Base filter
  id: 1565484183
- enabled: false
  url: https://easylist-downloads.adblockplus.org/antiadblockfilters.txt
  name: Adblock Warning Removal List
  id: 1565484184
- enabled: false
  url: https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt
  name: AdGuard Simplified Domain Names filter
  id: 1565484185
- enabled: false
  url: http://tools.yiclear.com/ChinaList2.0.txt
  name: ChinaListV2.0[20190801000]
  id: 1565484186
- enabled: false
  url: https://fanboy.co.nz/fanboy-problematic-sites.txt
  name: Fanboy's problematic-sites
  id: 1565484187
- enabled: false
  url: http://sub.adtchrome.com/adt-chinalist-easylist.txt
  name: ChinaList+EasyList(修正)
  id: 1565484188
- enabled: false
  url: https://hosts.nfz.moe/127.0.0.1/full/hosts
  name: NeoFelhz Hosts
  id: 1565484189
- enabled: false
  url: https://raw.githubusercontent.com/adbyby/xwhyc-rules/master/lazy.txt
  name: Adbyby Lazy Rule
  id: 1565484190
- enabled: false
  url: https://raw.githubusercontent.com/adbyby/xwhyc-rules/master/video.txt
  name: Adbyby Video Rule
  id: 1565484191
- enabled: false
  url: https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/resource-abuse.txt
  name: uBlock filters – Resource abuse
  id: 1565486406
- enabled: false
  url: https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt
  name: uBlock filters
  id: 1565486407
- enabled: false
  url: https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/badware.txt
  name: uBlock filters – Badware risks
  id: 1565486408
- enabled: false
  url: https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/experimental.txt
  name: uBlock filters – Experimental
  id: 1565486409
- enabled: false
  url: https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt
  name: uBlock filters – Privacy
  id: 1565486410
- enabled: false
  url: https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/unbreak.txt
  name: uBlock filters -- Unbreak
  id: 1565486411
user_rules: 
- '||t7z.cupid.ptqy.gitv.tv^$important'
- '@@||g.live.com^$important'
- '@@||s.click.taobao.com^$important'
- '@@||b1-data.ads.heytapmobi.com^$important'
- '@@||stg-data.ads.heytapmobi.com^$important'
- '@@||mar.vip.com^$important'
- '@@||exp.sug.browser.miui.com^$important'
- '@@||dj.1688.com^$important'
- '@@||click.simba.taobao.com^$important'
- '@@||appsupport.qq.com^$important'
- '@@||data.bilibili.com^$important'
- '@@||jumpluna.58.com^$important'
- '@@||oss-asq-static.11222.cn^$important'
- '@@||unet.ucweb.com^$important'
- '@@||kiees.com'
- '@@||alimama.com'
- '@@||pingma.qq.com^$important'
- '@@||wl.jd.com^$important'
- '@@||ipassport.ele.me^$important'
- '@@||mark.l.qq.com^$important'
- '@@||union.video.qq.com^$important'
- '@@||vd.l.qq.com^$important'
- '@@||tj.video.qq.com^$important'
- '@@||trace.qq.com^$important'
- '@@||im-x.jd.com^$important'
- '@@||act.vip.iqiyi.com^$important'
- '@@||paopao.iqiyi.com^$important'
- '@@||hotchat-im.iqiyi.com^$important'
- '@@||t7z.cupid.iqiyi.com^$important'
- '@@||nl-rcd.iqiyi.com^$important'
- '@@||btrace.video.qq.com^$important'
- '@@||btrace.qq.com^$important'
- '@@||livep.l.qq.com^$important'
- '@@||oth.eve.mdt.qq.com^$important'
- '@@||ms.vipstatic.com^$important'
- '@@||click.union.vip.com^$important'
- '@@||a.union.mi.com^$important'
- ""
dhcp:
  enabled: false
  interface_name: ""
  gateway_ip: ""
  subnet_mask: ""
  range_start: ""
  range_end: ""
  lease_duration: 86400
  icmp_timeout_msec: 1000
clients: []
log_file: ""
verbose: false
schema_version: 3

EEE
	chmod 755 "$adg_file"
fi
}

dl_adg(){
logger -t "AdGuardHome" "下载AdGuardHome"
#wget --no-check-certificate -O /tmp/AdGuardHome.tar.gz https://github.com/AdguardTeam/AdGuardHome/releases/download/v0.101.0/AdGuardHome_linux_mipsle.tar.gz
curl -k -s -o /tmp/AdGuardHome/AdGuardHome --connect-timeout 10 --retry 3 https://cdn.jsdelivr.net/gh/liuyuan29/rt-n56u/trunk/user/adguardhome/AdGuardHome
if [ ! -f "/tmp/AdGuardHome/AdGuardHome" ]; then
logger -t "AdGuardHome" "AdGuardHome下载失败，请检查是否能正常访问github!程序将退出。"
nvram set adg_enable=0
exit 0
else
logger -t "AdGuardHome" "AdGuardHome下载成功。"
chmod 777 /tmp/AdGuardHome/AdGuardHome
fi
}

start_adg(){
    mkdir -p /tmp/AdGuardHome
	mkdir -p /etc/storage/AdGuardHome
	if [ ! -f "/tmp/AdGuardHome/AdGuardHome" ]; then
	dl_adg
	fi
	getconfig
	change_dns
	set_iptable
	logger -t "AdGuardHome" "运行AdGuardHome"
	eval "/tmp/AdGuardHome/AdGuardHome -c $adg_file -w /tmp/AdGuardHome -v" &

}
stop_adg(){
rm -rf /tmp/AdGuardHome
killall -9 AdGuardHome
del_dns
clear_iptable
}


case $1 in
start)
	start_adg
	;;
stop)
	stop_adg
	;;
*)
	echo "check"
	;;
esac
