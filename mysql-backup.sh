#!/bin/bash

# Author: liwenfeng
# Date: 2019-11-11
# Desc: install Zabbix4.4 in ubuntu18.04

#MySQL官网: https://www.mysql.com
#Percona官网(下载Xtrabackup): https://www.percona.com

#可以先查看当前MySQL的默认引擎
show variables like '%storage_engine%';
#查看当前MySQL提供哪些存储引擎
show engines;

#使用Xtrabackup热备份(存储库安装)----备份的同时,业务不受影响
#从Percona存储库安装Percona XtraBackup apt
#从Percona网站获取存储库软件包
wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
#使用dpkg安装下载的软件包
sudo dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
#更新本地缓存
sudo apt-get update
#安装软件包
sudo apt-get install -y percona-xtrabackup-24

#避免从发行版本存储库升级
sudo touch /etc/apt/preferences.d/00percona.pref
echo 'Package: *
Pin: release o=Percona Development Team
Pin-Priority: 1001' | sudo tee /etc/apt/preferences.d/00percona.pref

#卸载Percona XtraBackup
sudo apt-get remove percona-xtrabackup-24

#备份MySQL
#完全备份所需的最低特权创建数据库用户
mysql> CREATE USER 'jiayi'@'localhost' IDENTIFIED BY 'jiayi';
mysql> GRANT RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT ON *.* TO
       'jiayi'@'jiayi';
mysql> FLUSH PRIVILEGES;

#======开始备份======
#!/bin/bash

#NAME: liwenfeng
#DATE: 2019-10-23
#FUNCTION: Backup MySQL

shijian=`date +'%Y%m%d'`
path=/home/ttg/backup
#全备
innobackupex --defaults-file=/etc/mysql/my.cnf  --user=jiayi --password=jiayi --no-timestamp  --parallel=4  \
${path}/mysql/mysql_full_${shijian}
#备份打包并发送到远程服务器
tar -zcf mysql_full_${shijian}.tar.gz /home/ttg/backup/mysql/mysql_full_${shijian}
scp -p mysql_full_${shijian}.tar.gz ttg@10.10.10.14:~/backup/mysql/
rm -f mysql_full_${shijian}.tar.gz
#删除30天以前的备份
find ${path}/mysql -mindepth 2 -type d -mtime +30 -exec rm -rf {} \;


#======备份策略加入定时任务======
#加入到root用户的定时任务
crontab -e

#写入以下内容
#Backup MySQL
00 3 * * *    /bin/bash  /home/ttg/scripts/mysql_backup.sh
