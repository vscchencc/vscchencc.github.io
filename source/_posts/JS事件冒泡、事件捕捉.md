---
title: 事件捕捉、 事件冒泡
date: 2019-3-11 14:54:25
categories: JavaScript 
top: true
---
# Javscript 事件捕捉、 事件冒泡

事件是监听在某个DOM元素上的，但是js的DOM事件有捕获和冒泡的机制，所以事件处理不是我们想的那样简单

由于存在捕获和冒泡，所以事件的触发元素（目标源）不一定是当前的监听元素。于是就有一些问题，本文要解决的就是将这些问题整理叙述清楚。

## 事件流
首先我们要理解事件流，即JavaScript中，事件触发的这一系列的流程

![事件流](../images/document/capture.png)

## 事件捕获 (event capturing)

事件捕获过程中，document 对象首先接收到click事件，然后事件沿DOM树依次向下，一直到事件的实际目标，既div元素

### Html

    <body>
        <ul id="parent">
            <li id="child">Test1</li>
        </ul>
    </body>

### Js

    var parent = document.getElementById('parent');
    var child = document.getElementById('child');
    parent.addEventListener('click',function(){
        console.log('parent')
    },true);
    child.addEventListener('click',function(){
        console.log('child')
    },true);

点击后打印结果为

    parent
    child
    

## 事件冒泡 (event bubbling)

事件冒泡，既事件开始时由最具体的元素(文档中嵌套层次最深的那个节点)接收，然后逐级向上传播到较为不具体的节点(文档)

### Html

    <body>
        <ul id="parent">
            <li id="child">Test1</li>
        </ul>
    </body>

### Js

    var parent = document.getElementById('parent');
    var child = document.getElementById('child');
    parent.addEventListener('click',function(){
        console.log('parent')
    },false);
    child.addEventListener('click',function(){
        console.log('child')
    },false);

点击后打印结果为

    child
    parent

一般我们都不会传入第三个参数，第三个参数默认一般也都是false，也就是事件冒泡

## 实践

实现将一个功能，点击按钮，就可以弹出一个选择框，在我点击非选择框区域的时候，选择框就会自动消失。

    <div id="wrapper" class="wrapper">
        <button id="button">点我</button>
        <div id="popover" class="popover">
            <input type="checkbox">浮层
        </div>
    </div>  

第一次可能我会这样实现

    button.addEventListener('click', function(e){
        popover.style.display = 'block'
    })
    document.addEventListener('click', function(){
        popover.style.display = 'none'
    })

这里当我们点击按钮之后，看上去什么都没有发生。这是为什么呢？那是因为在事件冒泡阶段，执行完第一个按钮点击事件后，继续向上冒泡，遇到了document的点击事件，于是又执行了，这样弹窗又再次隐藏了。

很简单的思路是，我们让执行完第一个事件之后，不再冒泡了，事件冒泡就此断开。

    button.addEventListener('click', function(e){
        popover.style.display = 'block'
    })
    button.addEventListener('click', function(e){
        window.event? window.event.cancelBubble = true : e.stopPropagation();  //停止冒泡
    })
    document.addEventListener('click', function(){
        popover.style.display = 'none'
    })