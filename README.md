# OpsAnt介绍

OpsAnt是全开源的云原生运维平台，致力于为全国数百万小微企业提供开源的多云管理和运维管理平台。目前提供免费下载试用，2021年年底完全开放源代码。

- 前端开发：Vue.js + Ant Design of Vue
- 后端开发：Python + Django
- 数据库：MySQL、Redis

> 本项目是OpsAnt Docker容器化部署项目，OpsAnt源码请查看opsant-backend和opsant-frontend项目。

- 版本概览：v1.0.0

<p align="center">
    <a href="http://www.opsany.com/">
        <img src="https://www.opsany.com/images/opsant.png">
    </a>
</p>

- 微信交流群： 添加微信后，回复OpsAnt，即可加群。

> 纯技术交流，非技术话题一键踢出，零容忍。

<img src="https://www.opsany.com/images/opsant-weixin.png">

## 使用Docker部署OpsAnt

0. 环境准备

部署OpsAnt需要一台2C、4G内存的云主机，硬盘默认即可。对外开放安全组：80和443端口。

1. 安装Docker和初始化使用的软件包

- 【CentOS 7】安装Docker和MySQL客户端

  ```
  curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
  curl -o /etc/yum.repos.d/docker-ce.repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
  yum install -y git wget docker-ce mariadb
  systemctl enable --now docker
  ```

- 【CentOS 8】安装Docker和MySQL客户端

  ```
  dnf config-manager --add-repo=http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
  dnf -y install docker-ce --nobest
  dnf -y install mariadb git
  systemctl enable --now docker
  ```

- 【Ubuntu】 安装Docker和MySQL客户端

  ```
  # step 1: 安装必要的一些系统工具
  sudo apt-get update
  sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
  # step 2: 安装GPG证书
  curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
  # Step 3: 写入软件源信息
  sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
  # Step 4: 更新并安装Docker-CE
  sudo apt-get -y update
  sudo apt-get -y install docker-ce wget mysql-client git
  systemctl enable --now docker
  ```

2. 克隆项目代码

```
[root@linux-node1 ~]# git clone https://github.com/unixhot/opsant.git
```

3. 修改配置文件并执行安装

```
[root@linux-node1 ~]# cd opsant/
[root@linux-node1 opsant]# cp install.config.example install.config
[root@linux-node1 opsant]# vim install.config
LOCAL_IP="192.168.56.11"
DOMAIN_NAME="192.168.56.11"
[root@linux-node1 opsant]# ./install.sh
```
> DOMAIN_NAME是指访问的地址，为了安全期间，访问地址不支持域名和IP混用。

4. 访问OpsAnt，支持Chrome、Firefox等，不支持IE浏览器

https://192.168.56.11

6. 使用安装脚本输出的用户名和密码进行登录。

安装成功后会自动生成admin的密码，请使用输出的密码进行登录。并及时修改密码。
