#!/bin/bash

#NAME: liwenfeng
#DATE: 2019-09-28
#FUNCTION: Install outline in ubuntu18.04

#VPN5--中国区aws服务器
#IP: 161.189.22.22
#outline_key: {"apiUrl":"https://161.189.22.22:46944/KzBDoiboj33BBRSORRM3iA","certSha256":"BF1D27D86ED3D2B566BD21BA2311D15D7C0273FF75E1AB39C6C117B60CB2567E"}

#install Outline in Ubuntu18.04(国内源)
sudo apt update
sudo apt-get -y install curl
sudo apt-get remove docker docker-engine docker.io
sudo apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt -y install docker-ce
#install Outline manager
wget -qO- https://raw.githubusercontent.com/Jigsaw-Code/outline-server/master/src/server_manager/install_scripts/install_server.sh | sudo bash






















