
#!/bin/bash

#NAME: liwenfeng
#DATE: 2019-09-09
#FUNCTION: Install Docker in ubuntu18.04

#==========安装Docker==========
cat << choose
请选择docker安装源的地址:
A:china
B:foreign
choose

read -p 'Please choose:>' item
case $item in
a|A)
echo "使用中国区的docker安装源"
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
;;
b|B)
echo "使用外国区的docker安装源"
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
;;
esac

#更新apt源索引
sudo apt-get update

#安装最新版本的docker(社区版)-稳定版
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

#创建docker组并添加用户
user=`whoami`
sudo groupadd docker
sudo usermod -aG docker ${user}

#配置开机自启动
sudo systemctl enable docker
