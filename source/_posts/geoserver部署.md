---
title: geoserver部署
date: 2019-04-29 16:43:09
categories: 地图可视化
tags: 笔记
top: false
---

Geoserver 地图服务部署，使用的打包后jar包，用tomcat的方式部署

<!-- more -->

# Tomcat部署 geoserver 服务

## 搭建 jdk Tomcat 等环境
此处我已有了一套一键式在服务器上搭建jdk以及Tomcat环境的软件包，直接解压文件包，执行shell脚本即可。

此处网上 linux 上搭建 Tomcat 教程很多，我就不写了，大家可以自己配置一下。

## 下载 Geoserver war包
此处我们采用 war 包的方式部署 Geoserver，去官网上面可以下载 war 包

## 然后启动 Tomcat 服务
Tomcat会自动帮我们解压war包，然后我们将war包删除，开始修改解压后war包内的配置，来修改跨域问题

## 修改跨域问题

### 将cors-filter-2.4.jar和java-property-utils-1.9.1.jar，两个jar包文件放入geoserver目录下webapps\geoserver\web-inf\lib中

### 打开geoserver目录下webapps\geoserver\web-inf中的web.xml

### 添加过滤器代码
```xml
    <filter>
	    <filter-name>CORS</filter-name>
	    <filter-class>com.thetransactioncompany.cors.CORSFilter</filter-class>
    </filter>
```
### 添加过滤器路由代码：

    <filter-mapping>
        <filter-name>CORS</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>

### 添加完毕后，重启geoserver

### 如果目录中存在maven，需要在pom.xml中，添加

    <dependency>
	    <groupId>com.thetransactioncompany</groupId>
	    <artifactId>cors-filter</artifactId>
	    <version>[ version ]</version>
    </dependency>

这里我设置的Tomcat 端口号为 8088

![tomcat端口号](tomcatport.jpg)

最后直接访问地址，Geoserver 默认账号admin 密码是geoserver

![geoserver](geoserver.jpg)

这样，Geoserver 服务搭建就完成了

### Geoserver 连接 postgis

![setData](setData.jpg)

设置 Geoserver 连接数据库 postgis