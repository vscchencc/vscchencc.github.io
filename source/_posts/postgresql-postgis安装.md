---
title: postgresql+postgis安装
date: 2019-04-25 15:28:08
categories: 地图可视化
tags: 笔记
top: false
---

对于在 linux 系统机器上手动一步步安装 postgresql ，以及安装postgis，折腾了好久。对于整改过程，做了一个完整的记录。

<!-- more -->

# 离线安装 postgresql 和配置 postgis 插件 在 redhat 7.3

## 安装postgresql

### 下载 postgresql

```
    可以去官方网站下载 postgresql，我这里使用的是postgresql-9.3.2.tar.gz
```

## 解压文件
```
    tar -zxvf postgresql-9.3.2.tar.gz
```

### 进入解压目录并配置参数
```
    进入解压目录    cd postgresql-9.3.2
    
    配置安装参数    ./configure --prefix=/opt/postgresql-9.3.2
```

** 注：这一步可能会发生一些错误，如果发生了，请参考下面的常见错误说明 **

### 编译
```
    make
```

### 安装

```
    make install
```

### 创建用户
```
    sudo useradd postgresql
```

### 创建数据库文件存储目录并给postgresql用户富裕权限

进入数据库安装目录        cd /opt/postgresql-9.3.2

创建data目录             sudo mkdir data

给postgresql用户赋予权限  sudo chown -R postgresql data

### 创建log文件

创建log目录             sudo mkdir log

创建pg_server.log文件   vi pg_server.log :wq

给postgresql用户权限    sudo chown -R postgresql log

### 添加环境变量

在**/etc/profile**中添加环境变量

```
    #postgresql
    export PGHOME=/opt/postgresql-9.3.2
    export PGDATA=/opt/postgresql-9.3.2/data
    export PATH=$PATH:$PGHOME/bin:$PGDATA
    LD_LIBRARY=/opt/postgresql-9.3.2/lib
    export LD_LIBRARY

    source /etc/profile
```

### 初始化数据目录

切换用户        su postgresql

初始化数据库    initdb -D data  

{% asset_img pg-initdb.jpg 设置桥接网络 %}

### 启动数据库，设置psql命令

先切换到root目录下  su root

执行这句命令   ** /sbin/ldconfig   /opt/postgresql-9.3.2/lib **

然后切换到  postgresql 用户下

启动数据库服务  pg_ctl -D data -l /opt/postgresql-9.3.2/log/pg_server.log start

这里直接可以执行 psql 以 postgresql 用户的身份进入测试一下

但是目前为止，该数据库只允许本地访问，如果运行其他用户访问的话还需要进行如下配置

### 配置监听地址和端口，并允许远程主机连接
```
    vi /opt/postgresql-9.3.2/data/postgresql.conf

    修改如下配置：
        
        listen_addresses = '*'
        port = 5432 

    vim /opt/postgresql-9.3.2/data/pg_hba.conf

    修改配置如下：

        # chencc add
        host    all             all             0.0.0.0/0               password

    ![设置远程主机](pg_hbf.jpg)
```

### 修改防火墙，开发5432端口

我在这里是直接将防火墙关闭，并且禁止使用了防火墙，实际操作，可能需要在设置开放5432端口

```
    sudo vim /etc/sysconfig/iptables
    加上 -A INPUT -p tcp -m tcp -dport 5432 -j ACCEPT
    重启防火墙 sudo service iptables restart
```

### 在postgresql数据库中为之前创建的postgresql用户增加密码
```
    psql template1

    修改postgresql用户密码：    ALTER USER postgresql PASSWORD '123456';

    ERROR: role "postgresql" dose not exist

    如不存在 postgresql 用户则新建该用户

    CREATE USER postgresql WITH PASSWORD '123456';
```

注：此时 postgresql 用户为数据用户

这时，postgresql 用户就可以作为数据库的使用用户了，可以打开一个postgresql客户端，如 Navicat，尝试连接一下了

### 关闭postgresql数据库，并重新启动，使更改后的配置生效

下面是通过postgresql的pg_ctl工具操作的

关闭数据库 pg_ctl stop -m fast
启动数据库 pg_ctl -D data -l /opt/postgresql-9.3.2/log/pg_server.log start

## 常见错误

### 安装常见错误
```
    readline libray not found
```
如果出现以上错误，说明你的系统缺少 readline库
```
    rpm -qa | grep readline
```
zlib包同理 

## 安装postgis

### 安装 geos
```
    tar -jxvf geos-3.7.1.tar.bz2
    cd /geos-3.7.1
    ./configure --prefix=/opt/geos-3.7.1
    make
    make install
```

### 安装 proj
```
    tar -zxvf proj-4.8.0.tar.gz
    cd /proj-4.8.0
    ./configure --prefix=/opt/proj-4.8.0
    make
    make install
```

### 安装 gdal
```
    tar -zxvf gdal-2.1.1.tar.gz
    cd /gdal-2.1.1
    ./configure --prefix=/opt/gdal-2.1.1
    make
    make install
```

### 执行postgis 安装
```
    tar -zxvf postgis-2.4.5.tar.gz
    
    ./configure --prefix=/opt/postgis-2.4.5 --with-pgconfig=/opt/postgresql-9.3.2/bin/pg_config  --with-projdir=/opt/proj  --with-geosconfig=/opt/geos-3.7.1/bin/geos-config  --with-gdalconfig=/opt/gdal-2.1.1/bin/gdal-config

    make
    make install
```

![设置postgis](configure.jpg)

登录psql，安装gis扩展
```
    psql test

    CREATE EXTENSION postgis
    CREATE EXTENSION postgis_topology
```

## 出错
![添加插件报错](postgisbug.jpg)
```
    cp /opt/geos-3.7.1/lib/libgeos_c.so.1    /lib64/
    cp /opt/proj/lib/libproj.so.0    /lib64/
    cp /opt/gdal-2.1.1/lib/libgdal.so.20     /lib64/
```

![完成](finish.jpg)
{% asset_img finish.jpg  完成%}

### 安装postgis2.0.1出错configure error: could not find gdal
```
    *checking for library containing GDALAllRegister... no*
    *configure: error: could not find gdal*
```

解决方法：
 编译时 完之后，修改下列文件

 1./etc/ld.so.conf
 ```
    include /etc/ld.so.conf.d/*.conf

    /usr/local/pgsql/lib
 ```

 2.执行指令
 ```
    /sbin/ldconfig –v
 ```

再执行postgis的编译