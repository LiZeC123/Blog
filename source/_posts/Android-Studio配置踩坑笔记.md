---
title: Android Studio配置踩坑笔记
math: false
date: 2026-11-28 10:15:15
categories:
tags:
    - Android
cover_picture: images/android.jpg
---

阅读提醒: 参考解决方案的思路, 但不要直接复制. 版本号和镜像地址等内容可能随着时间发生变化.

## 一、首次启动引导中断，SDK下载不完整
### 现象
第一次初始化时网络中断，引导终止，SDK不全，无法正常新建项目。
### 处理方案（不重置配置）
1. 回到欢迎页：`Configure → SDK Manager`，在这里继续补下载缺失组件
2. SDK版本选择策略（新手推荐）
    - SDK Platforms：**只选1个稳定版**，优先 API34（Android14），教程多、坑少；想体验新特性选 API35（Android15），不要一次性勾选一大堆
    - SDK Build Tools：勾选最新版本，只保留一个即可
    - SDK Platform Tools：必选（adb/fastboot工具）
    - System Image（模拟器镜像）：**初学先不下载，体积巨大、下载慢**，后续真机调试足够用
    - Sources for Android SDK：可选，想看源码再勾选，不影响编译运行
> 概念简单区分：
> compileSdk：编译时用的SDK，决定能调用哪些API；minSdk：控制APP最低能在什么安卓版本手机上安装；targetSdk：适配系统规则。

## 二、SDK下载速度极慢：全局HTTP代理配置（实测有效）
> 备注：SDK Update Sites 添加镜像方案实测无效，本笔记只记录全局HTTP代理方案
1. 路径：欢迎页 `Configure → Settings → Appearance & Behavior → System Settings → HTTP Proxy`
2. 选择 `Automatic proxy configuration URL`
3. 填入腾讯镜像地址：`https://mirrors.cloud.tencent.com/AndroidSDK/`
4. 点击 `Check connection` 测试连通，连通成功后，再回到SDK Manager执行下载

## 三、Gradle下载超时报错：`Could not install Gradle distribution ... Connect timed out`
### 现象
同步项目时，从 `services.gradle.org` 拉取Gradle包超时
### 方案：修改 `gradle-wrapper.properties` 镜像地址
文件路径：项目目录 `gradle/wrapper/gradle-wrapper.properties`
找到 `distributionUrl`，把官方地址替换为腾讯镜像，**版本号和原有保持一致**
示例（gradle-9.6.0）：
```properties
distributionUrl=https\://mirrors.cloud.tencent.com/gradle/gradle-9.6.0-bin.zip
```
修改保存后，点击Sync Now重新同步。

## 四、settings.gradle.kts 语法报错（重点坑：Groovy 和 Kotlin DSL 语法不能混用）
### 现象
直接复制Groovy的镜像配置到 `.kts` 文件，报 `Unexpected tokens`、大量 `invoke` 相关报错
> 核心原因：`.gradle` 是Groovy脚本；`.gradle.kts` 是Kotlin DSL，语法严格，不能直接照搬
- Groovy写法：`maven { url 'xxx' }`
- Kotlin DSL正确写法：`maven { url = uri("xxx") }`

✅ 最终可用完整 `settings.gradle.kts`（阿里云镜像）
```kotlin
pluginManagement {
    repositories {
        maven {
            url = uri("https://maven.aliyun.com/repository/google")
        }
        maven {
            url = uri("https://maven.aliyun.com/repository/gradle-plugin")
        }
        maven {
            url = uri("https://maven.aliyun.com/repository/public")
        }
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        maven {
            url = uri("https://maven.aliyun.com/repository/google")
        }
        maven {
            url = uri("https://maven.aliyun.com/repository/public")
        }
        google()
        mavenCentral()
    }
}

rootProject.name = "PhoneDock"
include(":app")
```
> 使用方式：全选原有文件内容，粘贴替换，保存后同步项目

## 五、Mac无USB口，局域网无线调试（Android11+，无需USB先行配对）
> 前提：手机和Mac连**同一个WiFi**，尽量同频段；路由器关闭AP隔离（设备隔离）
### 步骤1：手机开启无线调试
1. 设置 → 关于手机，连续点击版本号，开启开发者选项
2. 进入开发者选项，打开 **无线调试**，点【使用配对码配对设备】
3. 页面记录：配对IP:端口 + 6位配对码

### 步骤2：Android Studio图形界面配对（推荐）
1. AS顶部设备下拉框 → `Pair Devices Using Wi‑Fi`
2. 弹窗选择 `Pair using pairing code`，填入手机上的IP端口、配对码
3. 手机弹窗授权，允许配对
4. 配对成功后，无线调试首页的IP端口会出现在AS设备列表，选中设备，直接点运行按钮，编译、安装、启动App，和USB调试一致

### 备选：Mac终端adb命令配对
```bash
# 配对
adb pair 192.168.x.x:配对端口
# 输入6位配对码，提示Successfully paired
# 连接调试端口
adb connect 192.168.x.x:调试端口
# 查看设备列表
adb devices
```

### 高频踩坑清单
1. 路由器开启AP隔离：局域网设备互相访问失败，需要路由器后台关闭
2. 公共WiFi、校园网、公司内网大多禁止设备互通，无法无线调试
3. 手机省电策略：关闭【锁屏断开WLAN】，防止锁屏断调试连接
4. 国产定制系统：开发者选项中额外打开USB调试，无线调试才能正常工作
5. 重启手机后，一般需要重新 `adb connect`，配对信息保留，不用重输配对码

## 六、小结
1. 新版AS默认Kotlin DSL（`.kts`），镜像配置语法和老Groovy不一样，复制配置前先看后缀
2. SDK下载慢走AS全局HTTP代理，Gradle包下载慢改wrapper里的distributionUrl
3. 没有USB优先用Android11及以上原生无线调试，同WiFi环境即可真机测试

