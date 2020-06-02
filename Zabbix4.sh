#!/bin/bash

# Author: liwenfeng
# Date: 2020-06-02
# Desc: Install Zabbix4 in ubuntu18.04

#版本信息：
echo '
Ubuntu: 18.04
MySQL: 5.7.30
Zabbix: 4.0.21
Apache: 2
PHP: 7.2
'

#============安装MySQL============
sudo apt-get update
sudo apt-get install -y mysql-server
sudo apt-get install -y mysql-client
sudo apt-get install -y libmysqlclient-dev

#设置 root@localhost 密码,做以下操作
ROOT_PASSWORD=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 8`
echo "ROOT_PASSWORD = ${ROOT_PASSWORD}" >> ~/mysql-passwd
sudo mysql -e "update mysql.user set authentication_string=PASSWORD('${ROOT_PASSWORD}'), plugin='mysql_native_password' where user='root';"
sudo mysql -e "flush privileges;"

#配置mysql远程登录
#修改配置文件/etc/mysql/mysql.conf.d/mysqld.cnf，注释掉bind-address = 127.0.0.1
sudo sed -i 's/bind-address/#bind-address/g' /etc/mysql/mysql.conf.d/mysqld.cnf

#保存退出，然后进入mysql服务，执行授权命令,给予 root@'%' 添加权限--远程登录用户和密码
longrange_passwd=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 8`
echo "longrange_passwd = ${longrange_passwd}" >> ~/mysql-passwd
mysql -uroot -p"${ROOT_PASSWORD}"  -e "grant all on *.* to root@'%' identified by '${longrange_passwd}' with grant option;"
mysql -uroot -p"${ROOT_PASSWORD}"  -e "flush privileges;"

#修改数据库编码为utf-8
echo 'default-character-set=utf8' | sudo tee -a /etc/mysql/conf.d/mysql.cnf
echo 'character-set-server=utf8' | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf

#重启mysql服务
sudo systemctl restart mysql.service 

#设置mysql开机自启动
sudo update-rc.d mysql defaults
#取消开机自启动: update-rc.d -f mysql remove

#============安装配置Zabbix-server============
#创建目录
mkdir -p ~/download
mkdir -p ~/application
mkdir -p ~/scripts

#创建zabbix数据库
cd
ROOT_PASSWORD=`cat  ~/mysql-passwd|grep 'ROOT_PASSWORD'|awk -F '[ ]' '{print $3}'`
zabbix_passwd=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 8`
echo "zabbix_passwd = ${zabbix_passwd}" >> ~/mysql-passwd
mysql -uroot -p"${ROOT_PASSWORD}" -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -uroot -p"${ROOT_PASSWORD}" -e "grant all privileges on zabbix.* to zabbix@localhost identified by '${zabbix_passwd}';"
mysql -uroot -p"${ROOT_PASSWORD}" -e "flush privileges;"

#安装zabbix
cd ~/download
wget https://repo.zabbix.com/zabbix/4.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.0-2+bionic_all.deb
sudo dpkg -i zabbix-release_4.0-2+bionic_all.deb
sudo apt-get update

#安装 Server/proxy/前端
sudo apt-get install -y zabbix-server-mysql    #安装 Zabbix server 并使用 MySQL 数据库
sudo apt-get install -y zabbix-frontend-php    #安装 Zabbix 前端
sudo apt-get install -y zabbix-agent
#==sudo apt-get install -y zabbix-proxy-mysql     #安装 Zabbix proxy 并使用 MySQL 数据库

#导入数据库数据--初始数据库 schema 和数据
zabbix_passwd=`cat  ~/mysql-passwd|grep 'zabbix_passwd'|awk -F '[ ]' '{print $3}'`
zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -uzabbix -p${zabbix_passwd} zabbix

#Zabbix proxy,导入初始的数据库 schema
#==zcat /usr/share/doc/zabbix-proxy-mysql/schema.sql.gz | mysql -uzabbix -p${zabbix_passwd} zabbix

# Zabbix server/proxy 配置数据库
sudo sed -i 's/# DBHost=localhost/DBHost=localhost/g' /etc/zabbix/zabbix_server.conf
sudo sed -i 's/# DBUser=/DBUser=zabbix/g' /etc/zabbix/zabbix_server.conf
zabbix_passwd=`cat  ~/mysql-passwd|grep 'zabbix_passwd'|awk -F '[ ]' '{print $3}'`
sudo sed -i "s/# DBPassword=/DBPassword=${zabbix_passwd}/g" /etc/zabbix/zabbix_server.conf

#启动 Zabbix server 进程,并使其开机自启
sudo service zabbix-server start
sudo update-rc.d zabbix-server enable

#Zabbix 前端配置,配置时区
sudo sed -i "s/# php_value date.timezone Europe\/Riga/php_value date.timezone Asia\/Shanghai/g" /etc/apache2/conf-enabled/zabbix.conf

#重启apache服务
sudo service apache2 restart

#============安装配置Zabbix-agent============
#安装 Agent
sudo apt-get install -y zabbix-agent

#启动zabbix-agent,并使其开机自启
sudo service zabbix-agent start
sudo update-rc.d zabbix-agent enable

#Zabbix初始登录用户和密码为 Admin 和 zabbix
#数据库密码在当前用户的 mysql-passwd 文件中


#============Zabbix4.0设置中文界面和图形乱码============
#设置中文界面
sudo apt-get install language-pack-zh*

sudo vim /etc/environment  ##在/etc/environment文件中加入以下两行内容
LANG="ch_CN.UTF-8"
LANGUAGE="ch_CN:zh:en_US:en"

sudo dpkg-reconfigure locales
选择 zh_CN.UTF-8 UTF-8
选择 zh_CN.UTF-8

重启服务：
sudo systemctl restart zabbix-server.service zabbix-agent.service apache2

#设置图形乱码
sudo grep -i graphfont /usr/share/zabbix/include/defines.inc.php
ll /usr/share/zabbix/assets/fonts/
cd /usr/share/zabbix/assets/fonts/   ----上传下载好的字体文件
#==本地上传到远程服务器的命令: scp -i gitlab/keys/cn-keys/letter-war.pem Downloads/install_pkg/simkai.ttf ubuntu@52.82.108.32:~/download
sudo mv ~/download/simkai.ttf  /usr/share/zabbix/assets/fonts
ll /usr/share/zabbix/assets/fonts
sudo cp /usr/share/zabbix/include/defines.inc.php /usr/share/zabbix/include/defines.inc.php-`date +%F`
sudo sed -r -i 's#graphfont#simkai#' /usr/share/zabbix/include/defines.inc.php
grep -i simkai /usr/share/zabbix/include/defines.inc.php
