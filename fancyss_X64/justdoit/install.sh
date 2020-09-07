#! /bin/sh
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval `dbus export ss`
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
fwlocal=`cat /etc/openwrt_release|grep DISTRIB_RELEASE|cut -d "'" -f 2|cut -d "V" -f 2`
checkversion=`versioncmp $fwlocal 2.30`

# 判断路由架构和平台
case $(uname -m) in
	armv7l)
		logger "本justdoit插件用于koolshare OpenWRT/LEDE x86_64固件平台，arm平台不能安装！！！"
		logger "退出justdoit安装！"
		exit 1
	;;
	mips)
		logger "本justdoit插件用于koolshare OpenWRT/LEDE x86_64固件平台，mips平台不能安装！！！"
		logger "退出justdoit安装！"！
		exit 1
	;;
	x86_64)
		fw867=`cat /etc/banner|grep fw867`
		if [ -d "/koolshare" ] && [ -n "$fw867" ];then
			logger "固件平台【koolshare OpenWRT/LEDE x86_64】符合安装要求，开始安装插件！"
		else
			logger "本justdoit插件用于koolshare OpenWRT/LEDE x86_64固件平台，其它x86_64固件平台不能安装！！！"
			logger "退出justdoit安装！"
			exit 1
		fi
	;;
  *)
		logger 本justdoit插件用于koolshare OpenWRT/LEDE x86_64固件平台，其它平台不能安装！！！
  		logger "退出justdoit安装！"
		exit 1
	;;
esac

#校验固件版本
logger "开始检测固件版本..."
version_local=`cat /etc/openwrt_release|grep DISTRIB_RELEASE|cut -d "'" -f 2|cut -d "V" -f 2`
check_version=`versioncmp $version_local 2.12`
if [ "$check_version" == "1" ];then
	logger "当前固件版本太低，不支持最新版插件，请将固件升级到2.12以上版本"
	logger "退出justdoit安装！"
	exit 1
else
	logger "检测通过，justdoit符合安装条件！"
fi

# 准备
logger "justdoit: 创建相关文件夹..."
mkdir -p $KSROOT/ss
mkdir -p $KSROOT/init.d

# 关闭ss
if [ "$ss_basic_enable" == "1" ];then
	logger "先关闭ss，保证文件更新成功!"
	[ -f "$KSROOT/ss/ssstart.sh" ] && sh $KSROOT/ss/ssstart.sh stop
fi

#升级前先删除无关文件
logger "justdoit: 清可能存在的理旧文件..."
rm -rf $KSROOT/ss/* >/dev/null 2>&1
rm -rf $KSROOT/init.d/S99shadowsocks.sh >/dev/null 2>&1
rm -rf $KSROOT/init.d/S99justdoit.sh >/dev/null 2>&1
rm -rf $KSROOT/scripts/ss_* >/dev/null 2>&1
rm -rf $KSROOT/webs/Module_shadowsocks.asp >/dev/null 2>&1
rm -rf $KSROOT/webs/Module_justdoit.asp  >/dev/null 2>&1
rm -rf $KSROOT/webs/res/icon-shadowsocks*
rm -rf $KSROOT/webs/res/icon-justdoit*
rm -rf $KSROOT/bin/ss-tunnel >/dev/null 2>&1
rm -rf $KSROOT/bin/ss-local >/dev/null 2>&1
rm -rf $KSROOT/bin/ss-redir >/dev/null 2>&1
rm -rf $KSROOT/bin/ssr* >/dev/null 2>&1
rm -rf $KSROOT/bin/pdnsd >/dev/null 2>&1
rm -rf $KSROOT/bin/Pcap_DNSProxy >/dev/null 2>&1
rm -rf $KSROOT/bin/dnscrypt-proxy >/dev/null 2>&1
rm -rf $KSROOT/bin/dns2socks >/dev/null 2>&1
rm -rf $KSROOT/bin/chinadns >/dev/null 2>&1
rm -rf $KSROOT/bin/v2ray-plugin >/dev/null 2>&1
rm -rf /usr/lib/lua/luci/controller/sadog.lua >/dev/null 2>&1
[ -f "/koolshare/webs/files/justdoit.tar.gz" ] && rm -rf /koolshare/webs/files/justdoit.tar.gz

# 清理一些不用的设置
sed -i '/sspcapupdate/d' /etc/crontabs/root >/dev/null 2>&1

# 复制文件
cd /tmp
logger "justdoit: 复制安装包内的文件到路由器..."
if [ "$checkversion" == "1" ]; then
	logger "justdoit: 安装旧版本插件..."
	cp -rf /tmp/justdoit/bin/cdns1 $KSROOT/bin/cdns
	cp -rf /tmp/justdoit/bin/chinadns1 $KSROOT/bin/chinadns
	cp -rf /tmp/justdoit/bin/dns2socks1 $KSROOT/bin/dns2socks
	cp -rf /tmp/justdoit/bin/ss-tunnel1 $KSROOT/bin/ss-tunnel
	cp -rf /tmp/justdoit/bin/ss-local1 $KSROOT/bin/ss-local
	cp -rf /tmp/justdoit/bin/ss-redir1 $KSROOT/bin/ss-redir
	cp -rf /tmp/justdoit/bin/ssr-local1 $KSROOT/bin/ssr-local
	cp -rf /tmp/justdoit/bin/ssr-redir1 $KSROOT/bin/ssr-redir
	cp -rf /tmp/justdoit/bin/Pcap_DNSProxy1 $KSROOT/bin/Pcap_DNSProxy
else
	logger "justdoit: 安装新版插件..."
	cp -rf /tmp/justdoit/bin/cdns $KSROOT/bin/cdns
	cp -rf /tmp/justdoit/bin/chinadns $KSROOT/bin/chinadns
	cp -rf /tmp/justdoit/bin/dns2socks $KSROOT/bin/dns2socks
	cp -rf /tmp/justdoit/bin/ss-tunnel $KSROOT/bin/ss-tunnel
	cp -rf /tmp/justdoit/bin/ss-local $KSROOT/bin/ss-local
	cp -rf /tmp/justdoit/bin/ss-redir $KSROOT/bin/ss-redir
	cp -rf /tmp/justdoit/bin/ssr-local $KSROOT/bin/ssr-local
	cp -rf /tmp/justdoit/bin/ssr-redir $KSROOT/bin/ssr-redir
	cp -rf /tmp/justdoit/bin/Pcap_DNSProxy $KSROOT/bin/
fi
cp -rf /tmp/justdoit/bin/chinadns2 $KSROOT/bin/
cp -rf /tmp/justdoit/bin/dnscrypt-proxy $KSROOT/bin/
cp -rf /tmp/justdoit/bin/haproxy $KSROOT/bin/
cp -rf /tmp/justdoit/bin/kcpclient $KSROOT/bin/
cp -rf /tmp/justdoit/bin/obfs-local $KSROOT/bin/
cp -rf /tmp/justdoit/bin/pdnsd $KSROOT/bin/
cp -rf /tmp/justdoit/bin/v2ray-plugin $KSROOT/bin/
cp -rf /tmp/justdoit/ss/* $KSROOT/ss/
cp -rf /tmp/justdoit/scripts/* $KSROOT/scripts/
cp -rf /tmp/justdoit/init.d/* $KSROOT/init.d/
cp -rf /tmp/justdoit/webs/* $KSROOT/webs/
cp /tmp/justdoit/install.sh $KSROOT/scripts/ss_install.sh
cp /tmp/justdoit/uninstall.sh $KSROOT/scripts/uninstall_justdoit.sh
[ ! -L "/koolshare/bin/ssr-tunnel" ] && ln -sf /koolshare/bin/ssr-local /koolshare/bin/ssr-tunnel
# delete luci cache
rm -rf /tmp/luci-*

# 为新安装文件赋予执行权限...
logger "justdoit: 为新安装文件赋予执行权限..."
chmod 755 $KSROOT/bin/*
chmod 755 $KSROOT/ss/ssstart.sh
chmod 755 $KSROOT/scripts/ss_*
chmod 755 $KSROOT/init.d/S99justdoit.sh


local_version=`cat $KSROOT/ss/version`
logger "justdoit: 设置版本号为$local_version..."
dbus set ss_version=$local_version

sleep 1
logger "justdoit: 删除相关安装包..."
rm -rf /tmp/justdoit* >/dev/null 2>&1

logger "justdoit: 设置一些安装信息..."

#remove old shadowsocks
dbus remove softcenter_module_shadowsocks_description
dbus remove softcenter_module_shadowsocks_install
dbus remove softcenter_module_shadowsocks_md5
dbus remove softcenter_module_shadowsocks_name
dbus remove softcenter_module_shadowsocks_title
dbus remove softcenter_module_shadowsocks_version

#install new justdoit
dbus set softcenter_module_justdoit_description="轻松科学上网~"
dbus set softcenter_module_justdoit_install=1
dbus set softcenter_module_justdoit_name=justdoit
dbus set softcenter_module_justdoit_title=justdoit
dbus set softcenter_module_justdoit_version=$local_version

if [ "$ss_basic_enable" == "1" ];then
	logger "justdoit: 重启justdoit！"
	sh $KSROOT/ss/ssstart.sh restart
fi

sleep 1
logger "justdoit: SS插件安装完成..."