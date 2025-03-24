---
title: SSH使用笔记
math: false
date: 2025-03-23 22:13:06
categories:
tags:
cover_picture: 
---


SSH
-----------------------------

### 仅允许局域网密码登录

如果希望处于外网的用户只能使用秘钥登录, 而处于局域网的用户依然可以使用密码登录, 则可以进行如下的配置. 编辑`/etc/ssh/sshd_config`文件, 添加如下的内容

```
#禁用密码验证
PasswordAuthentication no
#启用密钥验证
RSAAuthentication yes
PubkeyAuthentication yes

# 局域网IP允许密码验证
Match Address 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
    PasswordAuthentication yes
Match all
```


- [linux ssh使用秘钥登录并禁用密码登录](https://blog.csdn.net/qq_32506245/article/details/81355497)
- [Only allow password authentication to SSH server from internal network](https://serverfault.com/questions/406839/only-allow-password-authentication-to-ssh-server-from-internal-network)
- [OpenSSH: How to end a match block](https://unix.stackexchange.com/questions/67334/openssh-how-to-end-a-match-block)


### 端口转发

SSH（Secure Shell）不仅是远程登录的安全协议，其端口转发功能更是解决网络隔离、穿透内网的神器。通过加密隧道，SSH能在不同网络环境中安全地转发流量。本文将深入解析**本地端口转发**、**远程端口转发**和**动态端口转发**三种模式，并给出具体操作示例。

---

#### 一、本地端口转发（Local Port Forwarding）

**核心作用**：将远程服务器的指定端口映射到本地，实现通过SSH隧道访问内网资源。  
**适用场景**：访问位于防火墙后的数据库、内部Web服务等。

##### 命令格式
```bash
ssh -L [本地绑定地址:]本地端口:目标主机:目标端口 用户名@跳板机地址
```

##### 示例场景
假设需要通过跳板机 `jump.example.com`（用户名为 `user`）访问内网主机 `10.0.0.5` 的MySQL服务（端口3306）：

```bash
ssh -L 3306:10.0.0.5:3306 user@jump.example.com
```
执行后，本地访问 `127.0.0.1:3306` 的流量将被加密转发到内网主机的MySQL服务。

**验证方式**：
```bash
mysql -h 127.0.0.1 -P 3306 -u db_user -p
```

**高级用法**：绑定到所有网络接口（允许其他设备访问）
```bash
ssh -L 0.0.0.0:3306:10.0.0.5:3306 user@jump.example.com
```

---

#### 二、远程端口转发（Remote Port Forwarding）

**核心作用**：将本地端口暴露到远程服务器，使外部用户可通过远程服务器访问本地服务。  
**适用场景**：本地开发环境临时对外暴露（如微信调试）、无公网IP的内网服务穿透。

##### 命令格式
```bash
ssh -R [远程绑定地址:]远程端口:本地目标主机:本地目标端口 用户名@公网服务器地址
```

##### 示例场景
将本地开发中的Web服务（端口8000）通过公网服务器 `public.example.com` 的8080端口对外暴露：

```bash
ssh -R 8080:localhost:8000 user@public.example.com
```
此时，访问 `public.example.com:8080` 的请求会转发到本地的 `localhost:8000`。

**验证方式**：
```bash
curl http://public.example.com:8080
```

**注意**：需确保远程服务器的SSH配置启用 `GatewayPorts`（默认关闭）：
```bash
# 在公网服务器上修改 /etc/ssh/sshd_config
GatewayPorts yes
systemctl restart sshd
```

---

#### 三、动态端口转发（Dynamic Port Forwarding）

**核心作用**：创建SOCKS代理，动态转发所有流量，无需指定固定端口。  
**适用场景**：全局代理访问多端口服务（如浏览器翻墙、跨区域访问内部系统）。

##### 命令格式
```bash
ssh -D [本地绑定地址:]本地端口 用户名@代理服务器地址
```

##### 示例场景
通过跳板机 `proxy.example.com` 建立本地SOCKS5代理（端口1080）：

```bash
ssh -D 1080 user@proxy.example.com
```

**使用方式**：  
1. 浏览器或系统设置代理为 `SOCKS5://127.0.0.1:1080`
2. 所有流量将通过SSH隧道加密传输，实现安全访问内网资源。

**验证方式**：
```bash
curl --socks5 127.0.0.1:1080 http://internal-site.example
```

---

#### 四、对比与总结

| 转发类型       | 命令参数 | 流量方向                | 典型场景                   |
|----------------|----------|-------------------------|---------------------------|
| 本地端口转发   | `-L`     | 本地 → 远程 → 目标      | 访问内网数据库、Web服务    |
| 远程端口转发   | `-R`     | 远程 → 本地 ← 外部请求  | 暴露本地服务到公网         |
| 动态端口转发   | `-D`     | 本地 ↔ 远程（任意端口） | 全局代理、多端口访问需求   |

---

#### 五、安全建议

1. **最小化暴露范围**：尽量绑定到 `127.0.0.1` 而非 `0.0.0.0`。
2. **使用密钥认证**：避免密码泄露，配置SSH密钥对。
3. **限制访问IP**：通过防火墙或SSH的 `AllowTcpForwarding` 控制权限。

掌握SSH端口转发技术，能有效解决跨网络访问难题，但需始终牢记：**能力越大，责任越大**——合理使用，安全第一！


- [SSH隧道：端口转发功能详解 ](https://www.cnblogs.com/f-ck-need-u/p/10482832.html)
