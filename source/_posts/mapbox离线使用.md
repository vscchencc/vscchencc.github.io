---
title: mapbox离线使用
date: 2019-05-05 10:37:59
categories: 地图可视化
top: false
---
# mapbox离线使用

## 一、mapbox-gl 介绍
mapbox是目前地图领域很领先的一家公司，已为 Foursquare、Pinterest、Evernote、金融时报、天气频道、优步科技 等公司的网站提供了订制在线地图服务。Mapbox 是一些开放源代码地图库及应用程序的创建者或最大的贡献者，其中包含了MBTiles 规范、TileMill 制图 IDE、Leaflet JavaScript 库，以及 CartoCSS 地图格式化语言与语法分析器等。对于web端前端 GIS渲染引擎是Mapbox GL JS。由于公司项目处于内网环境，无法访问mapbox的地图服务，因此需要对mapbox进行本地化，以满足公司项目的需求。

## 二、mapbox-gl 自定义样式

* mapbox样式主要包括以上几个参数：
* version：JS SDK对应版本必须为8，
* name：样式的命名，
* sprite：雪碧图，将一个地图涉及到的所有零星图标图片都包含到一张大图中。
* glyphs：.pbf格式的字体样式，例如微软雅黑等字体库。
* sources：图层的资源文件，可以支持矢量切片、栅格、dem栅格、图片、geojson、视频等格式
* layers：是对每个图层样式的描述，这里就是对地图样式渲染的关键，可以做定制化地图样式。
具体参数及其api可以参考mapbox官网。

## 三、离线部署

### 1、mapbox-gl.js，mapbox-gl.css离线部署

只需要从官网下载mapbox-gl.js，mapbox-gl.css到本地即可。

### 2、glyphs字体本地化

mapbox需要的字体为.pbf格式字体，可能很多人对于.pbf文件不太了解，在此介绍一下.pbf文件，.pbf文件的全称为Protocol Buffers，是Google公司开发的一种数据描述语言，类似于XML能够将结构化数据序列化，可用于数据存储、通信协议等方面。简单来说就是结构简单、速度快，和JSON之间的对比可以参考使用 Protocol Buffers 代替 JSON 的五个原因。

{% asset_img font.jpg 字体 %}

上面是微软雅黑的pbf字体库，如果想将把otf和ttf字体转换为Mapbox GL使用的protobuf格式的DF字体，可以使用mapbox开源的字体转换工具node-fontnik，具体使用方法可以参考官方文档

### 3.sprite本地化

访问mapbox地图服务我们可以从网络请求中查看官方样式中的sprite

{% asset_img spritepng.jpg sprite %}

同时还有一个sprite.json数据，用来描述sprite雪碧图

{% asset_img spritejson.jpg spriteJson %}

另外，需要更加地图zoom可能需要不同大小的sprite图片，为此mapbox用@2x,@3x等等分别表示2倍，3倍大小。

{% asset_img sprite@2json.jpg sprite@2xJson %}

了解了mapbox是sprite原理以后，其本地化所要做的工作是将小图标合成一张sprite大图并在sprite.json中记录生成的位置信息，这里最主要的就是图标的摆放规则。

## 四、地图样式编写

首先，将sprite，glyphs替换为本地环境。

    "version": 8,
    "sprite": "http://172.16.43.88:8082/sprites/sprite",
    "glyphs": "/assets/fonts/{fontstack}/{range}.pbf",

其中fontstack代表字体文件夹名称，range代表当前字体文件名称（mapbox会根据当前zoom和地图自自动匹配）

    "layout": {
        "text-field": "{name}",
        "text-font": [
            "Microsoft YaHei",
        ],
        "symbol-placement": "line",
        "text-pitch-alignment": "viewport",
        "text-max-angle": 30,
        "text-size": {
            "base": 1,
            "stops": [
                [
                    13,
                    12
                ],
                [
                    18,
                    16
                ]
            ]
        }
    },

text-font下的Microsoft YaHei 为字体文件夹名称

其次，需要添加sources,sources为geoserver返回的地图数据。


     "sources": {
        "waterways": {
            "type": "vector",
            "scheme": "tms",
            "tiles": [
                "http://172.16.43.88:8088/geoserver/gwc/service/tms/1.0.0/chinamap%3Agis_osm_waterways_free_1@EPSG%3A900913@pbf/{z}/{x}/{y}.pbf"
            ]
        }
        ```
    }

这里的 http://172.16.43.88:8088/geoserver/gwc/service/tms/1.0.0/chinamap%3Agis_osm_waterways_free_1@EPSG%3A900913@pbf 是Geoserver 发布的tms服务，获取的矢量切片
之前我们在geoserver中添加了waterways的图层，也介绍了geoserver服务能力及其tiles链接规范，我们就可以在sources中添加，type代表类型，我们是矢量切片选择vector，使用的是tms服务。下面我们看看如何编写waterways的样式。

    //waterway
    {
        "id": "waterway",
        "type": "line",
        "source": "waterways",
        "source-layer": "gis_osm_waterways_free_1",
        "filter": [
            "all",
            ["==", "$type", "LineString"],
            ["in", "fclass", "canal", "river"]
        ],
        "layout": {"line-join": "round", "line-cap": "round"},
        "paint": {
            "line-color": "hsl(209, 18%, 20%)",
            "line-width": [
                "interpolate",
                ["exponential", 1.3],
                ["zoom"],
                8.5,
                2,
                20,
                15
            ],
            "line-opacity": [
                "interpolate",
                ["linear"],
                ["zoom"],
                8,
                0,
                8.5,
                1
            ]
        }
    }

需要注意的是filter需要根据数据库字段进行筛选，其他具体可以看mapbox官方文档。
具体其他相关操作mapbox官网有相关的demo