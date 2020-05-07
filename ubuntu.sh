#!/bin/bash

# Author: liwenfeng
# Date: 2019-09-02
# Desc: Install basic commands in ubuntu_1804

#才安装ubuntu时，系统是直接进入普通用户的模式，这时是不能登录root用户的
#设置root用户的密码
sudo passwd root
#会有连个弹窗告诉你输入新的密码，这个就是要输入你要设置的root用户的密码
#设置好以后就可以使用'su - root'输入你刚才设置的密码进入root用户下

#创建常用目录
mkdir -p ~/scripts
mkdir -p ~/tools
mkdir -p ~/application

#配置阿里源
sudo cp -p /etc/apt/sources.list /etc/apt/sources.list_bak
echo "deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse" | sudo tee /etc/apt/sources.list

sudo apt-get update

#配置好后可以查看一下配置信息
grep -Ev '^$|#' /etc/apt/sources.list

#安装基础命令
sudo apt-get install -y vim net-tools tree htop screen dos2unix lsof tcpdump bash-completion wget

#关闭防火墙
sudo ufw disable
sudo systemctl stop ufw
sudo systemctl disable ufw
sudo systemctl status ufw

#更改时区(ubuntu18.04自带的时区软件timedatectl)
#查看有哪些时区,并记录你所需要的时区
timedatectl list-timezones

#就行修改时区,我选择的时区是上海,如下
sudo timedatectl set-timezone Asia/Shanghai


#========时间同步==========
#方法1、
#上面修改的是时区的信息,有些时候时区是对的,但时间并没有同步,造成时间不准确
#所以当我们时区是对的,时间没有同步时,我们使用以下命令进行时间同步
#运行timedatectl来查询timesyncd的状态
timedatectl
#System clock synchronized: yes表示时间已成功同步,systemd-timesyncd.service active: yes表示已启用并运行timesyncd
#如果timesyncd未激活,请使用timedatectl将其打开:
sudo timedatectl set-ntp on
#这样时间就同步了

#方法2、
#对于即使是最轻微的时间扰动非常敏感的一些应用程序可以通过ntpd更好地服务,因为它使用更复杂的技术来不断地逐步保持系统时间的正常运行。
#在安装ntpd之前,我们应该关闭timesyncd：
sudo timedatectl set-ntp no
#验证timesyncd是否已关闭：
timedatectl
#如果关闭了timesyncd,使用一下命令安装ntpd
sudo apt-get update
sudo apt-get -y install ntp
#在ntpd中查询状态信息
ntpq -p
#查看时间
date

#给普通用户ubuntu设置sudo权限,将文件的权限设置为0400,并设置免密使用sudo执行命令
#修改/etc/sudoers配置文件,直接使用下面这一行命令,官方说明,必选使用"sudo visudo"这个命令
sudo visudo

#在文件最后一行写入以下命令
ubuntu   ALL=(ALL)  NOPASSWD: ALL

注意: 一定要在最后一行添加 "your_user_name ALL=(ALL)  NOPASSWD: ALL",这个文件是有读取配置的顺序的


#设置主机名的方法
#修改hostname文件
sudo vim /etc/hostname
liwenfeng
#修改hosts文件
sudo vim /etc/hosts
127.0.0.1    liwenfeng

#命令行修改或者重启服务器(生产环境不建议重启)
hostname liwenfneg


#==========ubuntu18.04设置开机自启动脚本==========
#!/bin/bash
#进入root用户进行操作，快捷一点儿，当然也可以在普通用户中操作，在普通用户中所有操作都要加sudo
echo '
[Install]
WantedBy=multi-user.target
Alias=rc-local.service' | sudo tee /lib/systemd/system/rc.local.service

#创建文件rc.local
sudo touch /etc/rc.local
echo '#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

exit 0 ' | sudo tee /etc/rc.local

#给rc.local加上权限
sudo chmod +x /etc/rc.local

#systemd 默认读取 /etc/systemd/system 下的配置文件,,所以还需要在 /etc/systemd/system 目录下创建软链接
ln -s /lib/systemd/system/rc.local.service /etc/systemd/system/

#说明: 如果要在开机执行某条命令和开机时执行某个脚本，在新建的rc.local文件中添加命令和执行脚本的命令即可
#重要: 一定要将命令添加在 exit 0 之前


#删除文件最后一行的命令
sed -i '$d' filename
