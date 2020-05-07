#!/bin/bash
# Author: liwenfeng
# date:2019-09-02
# desc:install nginx mysql php

# install laster nginx
sudo apt install curl gnupg2 ca-certificates lsb-release
echo "deb http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
sudo apt update
sudo apt install nginx

#install php-fpm

sudo apt install php-fpm php-mysql

#安装完后需要设置php-fpm的用户名与nginx用户名一样，并且server里需要增加入下配置,并编写PHP测试文件测试是否成功

# location ~ .*\.(php|php5)?$
#    {      
#      fastcgi_pass  unix:/run/php/php7.2-fpm.sock;
#      #fastcgi_pass  127.0.0.1:9000;
#      fastcgi_index index.php;
#      fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
#      include        fastcgi_params;
#    }

# 安装PHP扩展插件(pdo_pgql)

# 1.查看当前php安装版本(PHP -v),下载源码安装文件（大于等当前版本）
# 2.解压源码文件，复制里边的扩展包文件夹（cp -r php-7.2.22/ext/pdo_pgsql .）
# 3.安装postgresql-server-dev (sudo apt-get install postgresql-server-dev-*)
# 4.找到phpize7.2（whereis phpize7.2）
# 5.找到php-config（/usr/bin/php-config）
# 6.进入复制出来扩展包文件夹，用phpize生成configure配置文件（/usr/bin/phpize7.2）
# 7.配置（./configure --with-php-config=/usr/bin/php-config）
# 8.编译和安装（make && sudo make install）
# 9.取消php.ini里的pdo_pgql注释选项
# 10.重启PHP（sudo systemctl restart php7.2-fpm.service）
# 11.查看模块是否安装成功（php -m|grep pdo_pgql）

#install mysql-server-5.7

sudo apt-get install mysql-server-5.7

#安装完后需切换到root用户下直接输入mysql登陆后修改密码
#grant all on *.* to jiayi@'%' identified by 'jiayi'; 
#flush privileges;

#如果忘记密码了，可以先跳过密码登录进去，然后重新设置
#编辑mysql的配置文件/etc/my.cnf，在[mysqld]段下加入一行“skip-grant-tables”。
#重启mysql服务,systemctl restart mysql.service
#update mysql.user set authentication_string=password('123456') where user='root' and Host ='localhost';
#flush privileges;
#退出后，修改my.cnf文件
#把刚才加入的那一行“skip-grant-tables”注释或删除掉
#再次重启mysql服务systemctl restart mysql.service，使用新的密码登陆，修改成功
