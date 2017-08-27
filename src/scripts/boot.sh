#!/bin/sh

# 默认配置文件
if [ ! -f "/app/conf/rtorrent.rc" ];then
    cp /opt/conf/rtorrent.rc /app/conf/
fi

if [ ! -f "/app/conf/rutorrent.php" ];then
    cp /opt/conf/rutorrent.php /app/conf/
fi

# 默认密码 123456
if [ ! -f "/app/conf/httpPassword" ];then
    echo "admin:zOfptPkebiKR." > /app/conf/httpPassword
fi

# 每次运行都是用用户配置覆盖
cp -f /app/conf/rtorrent.rc /root/.rtorrent.rc
cp -f /app/conf/rutorrent.php /usr/share/nginx/ruTorrent/conf/config.php
cp -f /app/conf/httpPassword /etc/nginx/httpPassword

# 权限修正
chmod 644 /etc/nginx/httpPassword /root/.rtorrent.rc /usr/share/nginx/ruTorrent/conf/config.php
chmod -R 777 /app/*

# 解锁
rm -rf /app/sessions/rtorrent.lock

# 启动程序
/etc/init.d/php5-fpm start
/etc/init.d/rtorrent start
/usr/sbin/nginx -g "daemon off;"
