---
title: GitHub Action记录
date: 2022-06-15 09:48:49
tags: 笔记
---

最近又被备案号发邮件通知，我的个站备案有问题了，才想起来好久没有折腾这个玩意了，也没有写东西了。这两天就不想用 Typecho ，就想写记录的方式都是形式，还是回归最朴实的方式吧。然后就准备还是继续在hexo上写东西了，然后用 GitHub Action 来进行个推送，保证 GitHub Pages还能正常使用，然后在增加小shell，来给我个人服务器上推送一份，本来好好的使用的 travisCI，那天看了下，好像更新了，又要重新申请，免费版本还要限制，那就 GitHub Action 了

<!-- more -->

# hexo 使用GitHub Action 进行部署

Hexo 使用的是 GitHub Pages，我选择了 dev 分支进行笔记记录，然后 push 到 dev 分支，然后 master 分支作为主分支，用于发布页面。