#!/bin/sh

# 切换国内源
#sed -i 's/archive.ubuntu/cn.archive.ubuntu/g' /etc/apt/sources.list
#sed -i 's/security.ubuntu/cn.archive.ubuntu/g' /etc/apt/sources.list

# 安装依赖包
export DEBIAN_FRONTEND=noninteractive
apt-get update && \
apt-get -y --no-install-recommends install libtool libxmlrpc-c++8-dev \
		libsigc++-2.0-dev libcppunit-dev libncurses5-dev libc-ares-dev\
		libcrypto++-dev libssl-dev g++ automake autoconf make nginx php-fpm \
		php-cli php-geoip geoip-database screen wget patch ca-certificates \
		unrar unzip mediainfo ffmpeg tzdata libcppunit-dev

ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

# 下载源码, 非最新版本
cd /opt
wget -c --no-check-certificate https://curl.haxx.se/download/curl-7.64.1.tar.gz && \
wget -c --no-check-certificate http://rtorrent.net/downloads/libtorrent-0.13.4.tar.gz && \
wget -c --no-check-certificate http://rtorrent.net/downloads/rtorrent-0.9.4.tar.gz && \
wget -c --no-check-certificate https://github.com/Novik/ruTorrent/archive/v3.8.tar.gz -O ruTorrent-3.8.tar.gz

# 编译安装 curl, 启用 c-ares
cd /opt
tar -zxf curl-7.64.1.tar.gz
cd curl-7.64.1
./configure --enable-ares && \
make && \
make install

# 编译安装 libtorrent
cd /opt
tar -zxf libtorrent-0.13.4.tar.gz
patch -p0 -d libtorrent-0.13.4/ < /opt/patch/libtorrent.patch
cd libtorrent-0.13.4
./autogen.sh && \
./configure --prefix=/usr && \
make && \
make install

# 编译安装 rtorrent
cd /opt
tar -zxf rtorrent-0.9.4.tar.gz
patch -p0 -d rtorrent-0.9.4/ < /opt/patch/rtorrent.patch
cd rtorrent-0.9.4
./autogen.sh && \
./configure --prefix=/usr --with-xmlrpc-c && \
make && \
make install

# 安装 rutorrent
cd /opt
tar -zxf ruTorrent-3.8.tar.gz
patch -p0 -d ruTorrent-3.8/ < /opt/patch/rutorrent.patch
mkdir /app; mv /opt/ruTorrent-3.8 /app/ruTorrent
sed -i "s/^post_max_size.*$/post_max_size = 100M/" /etc/php/7.0/fpm/php.ini
sed -i "s/^upload_max_filesize.*$/upload_max_filesize = 100M/" /etc/php/7.0/fpm/php.ini
sed -i "s/^max_execution_time.*$/max_execution_time = 300/" /etc/php/7.0/fpm/php.ini

# 配置 geoip
cp -r /opt/patch/qqwry.* /app/ruTorrent/plugins/geoip/

# 配置 nginx
cp /opt/conf/rutorrent.conf /etc/nginx/sites-available
unlink /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/rutorrent.conf /etc/nginx/sites-enabled

# 清理
apt-get autoremove -y g++ automake autoconf make wget patch libtool
dpkg -l|grep ^rc|awk '{print $2}'|xargs dpkg -P
rm -rf /var/lib/apt/lists/*
rm -rf /opt/libtorrent-*
rm -rf /opt/ruTorrent-*
rm -rf /opt/rtorrent-*
rm -rf /opt/curl-*
rm -rf /root/.cache 
rm -rf /root/.npm 
rm -rf /root/.pip 
rm -rf /usr/local/share/doc 
rm -rf /usr/share/doc 
rm -rf /usr/share/man 
rm -rf /usr/share/vim/vim74/doc 
rm -rf /usr/share/vim/vim74/lang 
rm -rf /usr/share/vim/vim74/spell/en* 
rm -rf /usr/share/vim/vim74/tutor 
rm -rf /var/lib/apt/lists/* 
rm -rf /tmp/*

# 运行时目录
mkdir /app/conf
mkdir /app/watch
mkdir /app/share
mkdir /app/sessions
mkdir /app/downloads
mkdir /run/php
