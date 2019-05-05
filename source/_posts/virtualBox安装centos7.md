---
title: virtualBox安装centos7
date: 2019-04-25 09:25:32
tags: JavaScript 
top: false
---
# virtualBox 安装 centOS7
最近一直在搞linux相关部署，搭建相关服务等。一直在公司服务器上操作，因为上面有部署服务，一直感觉玩的不好，就要玩出事。就想着在内网机上面搭建一个虚拟机装个centOS，学习一下相关知识，并且在上面试错。于是就有了下面这个在virtualBox上面搭建centOS7

# 下载 安装 virtualBox 
这一步相信也不需要咋写了，直接去官网下载安装就是了，特别是Windows安装，下一步就好了

# 在virtualBox 中安装 centOS 镜像
### 第一步新建，因为选项中没有 centOS，但是Redhat是centOS的发行版本，选Redhat就好了
{% asset_img virtualboxSet.jpg 新建一台虚拟机 %}

# 设置系统
### 因为我们使用的是iso镜像，所以要将光驱放在最上面用光驱驱动的方式来安装
{% asset_img setSystem.jpg 设置系统 %}

{% asset_img setSystemIso.jpg 设置系统存储 %}

{% asset_img centosversion.jpg 系统版本 %}

# 设置 virtualBox 网卡
### 因为我们想做到虚拟机和本机能互联，本机也可以和虚拟机互联，同时，虚拟机也可以访问内网搭建的镜像源，所以我们设置了两张网卡，要用桥接的方式来做到
{% asset_img network1.jpg 设置网络 %}
{% asset_img network2.jpg 设置桥接网络 %}

# 启动 centOS
### 现在virtualBox中的工作已经配置完成，现在启动，就可以进入系统安装了，同时可以在安装过程中可以设置下root用户的密码

# 配置系统中网络
两张网卡所在路径 /etc/sysconfig/network-scripts/
{% asset_img eth0.jpg 设置第一张网卡 %}

### 注意第二章网卡中 BOOTPROTO=static 注意设置成静态
{% asset_img eth1.jpg 设置第二张网卡 %}

### 重启网络
    service network restart

### 关闭防火墙
#### 查看防火墙状态

    firewall-cmd --state

#### 停止firewall

    systemctl stop firewalld.service

#### 禁止firewall 开机启动

    systemctl disable firewalld.service

现在大家可以尝试ping一下网络，看看是否成功了

### 开启ssh

因为我们一般不想直接在虚拟机中操作命令行，因为界面什么的看上去都不如xshell或者putty用起来舒服，于是我们就要开启 ssh 服务

    service sshd restart

    service sshd status

现在我们就可以用 xshell 连接服务器，开启linux了
