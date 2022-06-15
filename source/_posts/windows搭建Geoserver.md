---
title: windows搭建Geoserver
date: 2019-04-30 09:18:30
tags: 笔记
categories: 地图可视化
---
windows 环境下搭建 Geoserver 和 postgis 环境，postgis是基于 postgresql 的一个扩展。整套环境安装后，是为地图数据切片发布坐准备的。下面详细记录了，我是如何在Windows环境下搭建整套环境的，大家可以做个参考。

<!-- more -->

## Windows搭建 Geoserver 和 postgis 环境

### 矢量切片与栅格切片

以fhgis为例我们发现请求的是一张张图片，最后通过将图片进行拼接形成一张完整的地图，首先图片的数据量较大，其次一旦生成的图片，那么所有的属性数据将不存在，图片修改起来麻烦，个性化定制也就很难实现，同时也无法进行交互。
对于矢量切片返回的是含有属性信息的地理数据，数据量较小，保留了地图属性数据，可以进行定制化，同时也很容易定制化，基于矢量切片地图可以对地图数据进行定制化和交互，同时基于现代设备的精细视网膜显示器和高性能的计算机图形使得应用具有身临其境的、可交互的效果以及处理大量数据的能力。这可以让我们持续的改进地图的设计和在web上2D和3D之间的转换。

### 相关软件安装

####  postgresql + postGis 安装

PostGIS是对象关系型数据库系统PostgreSQL的一个扩展，PostGIS提供如下空间信息服务功能:空间对象、空间索引、空间操作函数和空间操作符。同时，PostGIS遵循OpenGIS的规范。我们项目中主要使用它来保存原始矢量数据,后续可能需要通过PostGis对地理空间数据进行查找，筛选。
下载安装相应版本的postgresql和postgis(本次搭建采用的是postgresql-9.6.10-1-windows-x64.exe和postgis-bundle-pg96x64-setup-2.3.7-1.exe)。

####  geoserver + geoserver vectortiles插件安装

 GeoServer 是 OpenGIS Web 服务器规范的 J2EE 实现，利用 GeoServer 可以方便的发布地图数据，允许用户对特征数据进行更新、删除、插入操作，通过 GeoServer 可以比较容易的在用户之间迅速共享空间地理信息。我们在GeoServer的基础上添加vector Tiles插件可以进行矢量切片。
首先安装geoserver (本次安装的版本为geoserver-2.13.2.exe)，安装成功后打开geoserver web admin page（默认登录账户、密码为admin,geoserver），此时可以看到如下界面：

![Geoserver服务](Geoserver.png)

接下来还需要安装geoserver vectortiles插件，该插件主要用来对数据进行矢量切片。需要下载geoserver对于的插件（本次安装的版本为：geoserver-2.13-SNAPSHOT-vectortiles-plugin.zip）。下载地址为http://geoserver.org/release/stable/

![Geoserver服务插件](geoserver-plugin.png)

下载成功以后将该文件解压到GeoServer服务器下GeoServer文件夹的WEB-INF的lib文件夹下，重启geoserver，此时重新打开geoserver web admin page，

![Geoserver服务插件](geoser-plu-set.png)

此时，我们发现可以进行矢量切片的相关设置，将前四个vertor layers选项勾上。

### geoserver跨域设置

需要通过geoserver提高切片数据，需要进行跨域设置。找到GeoServer服务器下GeoServer文件夹的WEB-INF文件夹下的web.xml

![java跨域](xml.png)

找到上面显示的两个配置，并将注释去掉，下载对应的跨域jar包（本项目下载的是jetty-servlets-9.2.13.v20150730.jar），最后重启geoserver服务器。

### 数据导入

####  数据获取
1.基础地图数据：openstreetmap,其他地图厂商
2.建筑物轮廓数据（带高度）：淘宝，城市数据派等。

####  导入数据

打开shp2pgsql-gui

![postgis设置](postgis.jpg)

打开后点击view connection detail，输入postgresql数据库username,password，serverhost,Database名称后点击ok，此时数据库连接成功。

![postgis设置](postgis-set.jpg)

接下来导入.shp数据，点击add files，选择相应的.shp文件

![postgis导入数据](postgis-data.jpg)

点击import即可将数据导入到数据库，如果现实出现错误可能由于字符串编码的问题，此时可以通过option设置字符编码及其他设置。

### Geoserver发布

####  新建工作区

![新建工作区](geoserver-new.jpg)

####  新建数据源（postgresql数据源）

![新建数据源](geoserver-dta.jpg)

![新建数据源](geo-postgis.jpg)

![新建数据源](geoser-postgis-set.jpg)

填写相关参数后，点击保存按钮。

#### 添加图层

![添加图层](geoser-layer.jpg)

![添加图层](geoserver-layer-set.jpg)

![添加图层](geoserver-configure.jpg)

![添加图层](geoserver-configu.jpg)

![添加图层](geoser-configure1.jpg)

配置成功以后点击保存，此时重新点击图层以后，就好出现你已经发布的图层，如果需要对几个图层进行合并，可以建立一个图层组将几个图层进行合并。
最后可以通过layer preview查看图层是否发布成功。

![添加图层](layer-preview.jpg)

![添加图层](view-layer.jpg)

#### 为了加快地图访问速度，可以对矢量切片进行缓存。

![缓存](cache-layer.jpg)

![缓存](cachelayer1.jpg)

可以选择切片等级以及切片的线程数后，点击submit，就可以在切片文件夹下查看切片文件。

![缓存](cache-layer2.jpg)

注意，这里是在Windows上做缓存，问题影响不大，但是如果在linux做缓存，要注意如果切片文件夹过多，会有inode使用过多，会有inode占用100%，但是硬盘还有很大空间的情况

### geoserver服务能力

可以从geoserver admin page查看支持那几种服务能力

![服务能力](ability.jpg)

以TMS为例，点击TMS，可以查看该服务的链接规范，在mapbox-gl中我们将使用到。

![服务能力](ability2.jpg)