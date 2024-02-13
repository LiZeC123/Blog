#! /bin/bash

# 此脚本用于在新的服务器中安装必要的组件

function initVirtualMemory {
    # 配置虚拟内存
    mkdir /swap
    cd /swap
    # 分配1GB的虚拟内存
    dd if=/dev/zero of=swapfile bs=1024 count=1048576
    mkswap swapfile
    chmod 0600 swapfile
    swapon swapfile
}

function installBase {
    # 安装必要的组件
    apt update
    apt upgrade  
    apt install git nginx tmux htop tldr snapd 
}

function installCerbot {
    # 安装cerbot
    snap install core; snap refresh core
    snap install --classic certbot
}

function installDocker {
    # 安装docker
    apt install docker.io
    systemctl start docker
    systemctl enable docker
    apt install docker-compose
}



function installBBR {
    # 安装BBR算法
    cd /
    wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh
    chmod +x bbr.sh
    ./bbr.sh
    echo "如果下面的列表中包含 tcp_bbr 则安装成功"
    lsmod | grep bbr
}


function renew {
    # 证书续期
    echo "Windows平台使用如下的指令检查DNS配置是否生效"
    echo "nslookup.exe -qt=txt _acme-challenge.lizec.top"
    echo "Linux平台使用如下指令检查DNS配置是否生效"
    echo "nslookup -type=txt _acme-challenge.lizec.top"

    certbot certonly --manual \
    -d *.lizec.top \
    -d lizec.top --agree-tos \
    --manual-public-ip-logging-ok --preferred-challenges \
    dns-01 --server https://acme-v02.api.letsencrypt.org/directory
    
    echo "Reload Nginx"
    nginx -s reload
}


case $1 in
    renew)
        renew
        ;;
    initVM)
        initVirtualMemory
        ;;
    base)
        initVirtualMemory
        installBase
        installCerbot
        installDocker
        installBBR
        ;;
    *)
        echo "无效的指令：$1"
        echo "./installTools.sh <command>"
        echo "renew         执行证书续期操作"
        echo "initVM        设置虚拟内存"
        echo "base          执行全部的安装操作"
        ;;
esac