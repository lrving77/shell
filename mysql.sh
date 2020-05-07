#!/bin/bash

# Author: liwenfeng
# Date: 2019-11-11
# Desc: Install MySQL in ubuntu18.04

sudo apt-get update
sudo apt-get install -y mysql-server
sudo apt-get install -y mysql-client
sudo apt-get install -y libmysqlclient-dev

#设置root密码,做以下操作
sudo mysql -e "update mysql.user set authentication_string=PASSWORD('joyient'), plugin='mysql_native_password' where user='root';"
sudo mysql -e "flush privileges;"

#配置mysql远程登录
#修改配置文件/etc/mysql/mysql.conf.d/mysqld.cnf，注释掉bind-address = 127.0.0.1
sudo sed -i 's/bind-address/#bind-address/g' /etc/mysql/mysql.conf.d/mysqld.cnf

#保存退出，然后进入mysql服务，执行授权命令
mysql -uroot -p'joyient'  -e "grant all on *.* to root@'%' identified by 'joyient' with grant option;"
mysql -uroot -p'joyient'  -e "flush privileges;"

#修改数据库编码为utf-8
echo 'default-character-set=utf8' | sudo tee -a /etc/mysql/conf.d/mysql.cnf
echo 'character-set-server=utf8' | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf

#重启mysql服务
sudo systemctl restart mysql.service 

#设置mysql开机自启动
sudo update-rc.d mysql defaults
#取消开机自启动: update-rc.d -f mysql remove
