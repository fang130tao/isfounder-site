# 阿里云服务器配置指南

详细的阿里云服务器配置指南，涵盖从系统初始化到安全配置的所有步骤。

## 📚 目录

1. [服务器信息](#服务器信息)
2. [系统要求](#系统要求)
3. [连接服务器](#连接服务器)
4. [系统初始化](#系统初始化)
5. [安装 Docker](#安装-docker)
6. [配置防火墙](#配置防火墙)
7. [配置 Harbor](#配置-harbor)
8. [部署网站](#部署网站)
9. [安全配置](#安全配置)
10. [日常维护](#日常维护)

---

## 服务器信息

### 服务器详情

| 项目 | 值 |
|------|-----|
| **公网 IP** | 8.156.82.221 |
| **系统** | Ubuntu 20.04/22.04 |
| **CPU** | 2 核（最低） |
| **内存** | 4GB（最低） |
| **存储** | 20GB+ |
| **SSH 端口** | 22 |

### 推荐配置

| 配置 | 规格 | 月费用 | 适用场景 |
|------|------|--------|---------|
| **基础** | 2核4G | ~100元 | 个人项目、测试环境 |
| **推荐** | 4核8G | ~200元 | 生产环境、小团队 |
| **高性能** | 8核16G | ~400元 | 大流量、高并发 |

---

## 系统要求

### 操作系统

- **Ubuntu**: 20.04 LTS 或 22.04 LTS（推荐）
- **CentOS**: 7.x 或 8.x
- **Debian**: 10.x 或 11.x

### 必要软件

- **Docker Engine**: 20.10+
- **Docker Compose**: 2.0+
- **防火墙**: UFW / firewalld / iptables

---

## 连接服务器

### SSH 连接

**基本连接**:
```bash
ssh root@8.156.82.221
```

**使用密钥连接**:
```bash
ssh -i ~/.ssh/your_key.pem root@8.156.82.221
```

**配置 SSH 快捷方式**:
```bash
# 编辑 ~/.ssh/config
Host aliyun
    HostName 8.156.82.221
    User root
    Port 22
    IdentityFile ~/.ssh/your_key.pem
```

然后直接使用:
```bash
ssh aliyun
```

### 首次连接

如果首次连接，需要：
1. 获取服务器密码或密钥
2. 接受服务器指纹
3. 登录后修改密码

```bash
# 修改 root 密码
passwd root

# 输入新密码（至少 12 位）
```

---

## 系统初始化

### 方式 1: 使用初始化脚本（推荐）

```bash
# 从本地执行初始化
cd deploy/scripts
./setup-server.sh 8.156.82.221
```

脚本会自动完成：
- ✅ 系统更新
- ✅ 安装基础工具
- ✅ 安装 Docker
- ✅ 配置 Docker
- ✅ 配置防火墙
- ✅ 创建必要目录

### 方式 2: 手动初始化

#### 更新系统

```bash
# Ubuntu/Debian
apt-get update -y
apt-get upgrade -y

# CentOS
yum update -y
yum upgrade -y
```

#### 安装基础工具

```bash
# Ubuntu/Debian
apt-get install -y curl wget vim git unzip ca-certificates gnupg lsb-release

# CentOS
yum install -y curl wget vim git unzip ca-certificates
```

---

## 安装 Docker

### Ubuntu/Debian

#### 1. 卸载旧版本

```bash
apt-get remove -y docker docker-engine docker.io containerd runc
```

#### 2. 安装 Docker

```bash
# 添加 Docker GPG key
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 添加 Docker 仓库
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### CentOS

```bash
# 添加 Docker 仓库
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 安装 Docker
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### 配置 Docker

```bash
# 创建配置目录
mkdir -p /etc/docker

# 配置 Docker daemon
cat > /etc/docker/daemon.json <<'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "insecure-registries": ["8.156.82.221"]
}
EOF

# 启动 Docker
systemctl enable docker
systemctl start docker

# 验证安装
docker --version
docker compose version
```

---

## 配置防火墙

### 阿里云安全组配置

**必须步骤**：在阿里云控制台配置安全组

#### 1. 登录阿里云控制台

访问：https://ecs.console.aliyun.com

#### 2. 进入 ECS 实例

选择实例 → 点击 "安全组"

#### 3. 添加入方向规则

点击 "添加安全组规则"，配置以下规则：

| 方向 | 协议 | 端口范围 | 授权对象 | 说明 |
|------|------|---------|---------|------|
| 入方向 | TCP | 22/22 | 0.0.0.0/0 | SSH |
| 入方向 | TCP | 80/80 | 0.0.0.0/0 | HTTP |
| 入方向 | TCP | 443/443 | 0.0.0.0/0 | HTTPS |
| 入方向 | TCP | 3000/3000 | 0.0.0.0/0 | Web |

**生产环境建议**：
- SSH 限制来源 IP
- 只开放必要端口

### UFW 防火墙（Ubuntu）

```bash
# 安装 UFW
apt-get install -y ufw

# 配置规则
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 3000/tcp

# 启用防火墙
echo "y" | ufw enable

# 查看状态
ufw status
```

### firewalld（CentOS）

```bash
# 开放端口
firewall-cmd --permanent --add-port=22/tcp
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=3000/tcp

# 重载防火墙
firewall-cmd --reload

# 查看状态
firewall-cmd --list-all
```

---

## 配置 Harbor

### 创建目录

```bash
mkdir -p /opt/harbor
mkdir -p /data/harbor
mkdir -p /var/log/harbor
```

### 上传配置文件

**方式 1: 使用部署脚本（推荐）**
```bash
cd deploy/scripts
./deploy-registry.sh 8.156.82.221
```

**方式 2: 手动上传**
```bash
# 从本地执行
scp -r registry/* root@8.156.82.221:/opt/harbor/
```

### 下载 Harbor 安装包

```bash
# 在服务器上执行
cd /opt/harbor

# 下载 Harbor（如果没有上传）
wget https://github.com/goharbor/harbor/releases/download/v2.10.0/harbor-offline-installer-v2.10.0.tgz

# 解压
tar xzvf harbor-offline-installer-v2.10.0.tgz
```

### 配置 Harbor

```bash
cd /opt/harbor/harbor

# 复制配置文件
cp ../config/harbor.yml harbor.yml

# 编辑配置
vim harbor.yml
```

**关键配置**:
```yaml
hostname: 8.156.82.221
harbor_admin_password: Harbor12345  # 修改密码！
data_volume: /data/harbor
```

### 安装 Harbor

```bash
# 生成配置
./prepare

# 安装
./install.sh

# 启动
docker-compose up -d

# 查看状态
docker-compose ps
```

### 访问 Harbor

- **Web UI**: http://8.156.82.221
- **用户名**: admin
- **密码**: Harbor12345（配置文件中设置的）

---

## 部署网站

### 方式 1: 使用部署脚本（推荐）

```bash
cd deploy/scripts
./deploy-site.sh 8.156.82.221 8.156.82.221
```

### 方式 2: 手动部署

#### 1. 登录 Harbor

```bash
docker login 8.156.82.221
# Username: admin
# Password: Harbor12345
```

#### 2. 拉取镜像

```bash
docker pull 8.156.82.221/site/isfounder-site:latest
```

#### 3. 启动容器

```bash
docker run -d \
  --name site \
  -p 3000:3000 \
  --restart unless-stopped \
  8.156.82.221/site/isfounder-site:latest
```

#### 4. 验证部署

```bash
# 查看状态
docker ps | grep site

# 查看日志
docker logs site

# 测试访问
curl http://localhost:3000
```

### 访问网站

- **网站地址**: http://8.156.82.221:3000

---

## 安全配置

### SSH 安全

#### 1. 修改 SSH 端口

```bash
vim /etc/ssh/sshd_config
```

修改：
```conf
Port 22022  # 修改默认端口
PermitRootLogin no  # 禁用 root 登录
PasswordAuthentication no  # 禁用密码登录
PubkeyAuthentication yes  # 启用密钥登录
```

重启 SSH：
```bash
systemctl restart sshd
```

#### 2. 使用 SSH 密钥

```bash
# 本地生成密钥
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 上传公钥到服务器
ssh-copy-id -i ~/.ssh/id_rsa.pub root@8.156.82.221
```

### 防火墙优化

#### 只开放必要端口

```bash
# 只开放特定 IP
ufw allow from 1.2.3.4 to any port 22
ufw allow from 1.2.3.4 to any port 80
ufw allow from 1.2.3.4 to any port 443
```

#### 限制连接数

```bash
# 限制 SSH 并发连接
ufw limit 22/tcp
```

### Harbor 安全

#### 1. 修改默认密码

登录 Harbor Web UI → 用户管理 → 修改密码

#### 2. 启用 HTTPS（生产环境）

参考：[Harbor HTTPS 配置](docs/HARBOR-USAGE.md#https-配置)

#### 3. 配置用户权限

- 创建普通用户
- 不使用 admin 账号日常操作
- 按项目分配权限

### Docker 安全

#### 1. 限制容器权限

```json
{
  "icc": false,
  "userns-remap": "default",
  "live-restore": true
}
```

#### 2. 启用 Docker 日志限额

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

---

## 日常维护

### 系统维护

#### 更新系统

```bash
# Ubuntu/Debian
apt-get update && apt-get upgrade -y

# CentOS
yum update -y
```

#### 查看系统状态

```bash
# CPU 和内存
top
htop

# 磁盘使用
df -h

# 网络状态
netstat -tulpn
```

### Docker 维护

#### 查看容器状态

```bash
docker ps -a
docker-compose ps
```

#### 查看日志

```bash
# 所有容器
docker-compose logs

# 指定容器
docker-compose logs -f harbor
docker logs -f site
```

#### 清理资源

```bash
# 清理未使用的镜像
docker image prune -a

# 清理未使用的容器
docker container prune

# 清理未使用的网络
docker network prune

# 清理所有未使用的资源
docker system prune -a
```

### Harbor 维护

#### 备份数据

```bash
cd /opt/harbor/scripts
./backup-harbor.sh
```

#### 更新 Harbor

```bash
cd /opt/harbor/scripts
./update-harbor.sh
```

#### 清理旧镜像

```bash
# 登录 Harbor
docker login 8.156.82.221

# 手动删除（通过 Web UI）
# 或使用 API
curl -X DELETE -u admin:Harbor12345 \
  http://8.156.82.221/api/v2.0/projects/site/repositories/image/tags/v1.0.0
```

### 网站维护

#### 重启网站

```bash
docker restart site
```

#### 更新网站

```bash
# 拉取新镜像
docker pull 8.156.82.221/site/isfounder-site:latest

# 重启容器
docker restart site
```

#### 查看网站日志

```bash
docker logs -f site --tail 100
```

---

## 故障排查

### SSH 无法连接

**检查步骤**：
1. 确认服务器已开机
2. 确认 IP 地址正确
3. 检查安全组规则（SSH 端口）
4. 检查本地网络

**解决方案**：
```bash
# 使用阿里云控制台的 VNC 连接
# 重置密码
# 重启 SSH 服务
```

### Docker 无法启动

**检查日志**：
```bash
systemctl status docker
journalctl -u docker -n 50
```

**常见问题**：
- 端口冲突
- 存储空间不足
- 配置文件错误

**解决方案**：
```bash
# 检查端口占用
netstat -tulpn | grep :2375

# 清理磁盘空间
docker system prune -a

# 重置 Docker
systemctl restart docker
```

### Harbor 无法访问

**检查服务状态**：
```bash
cd /opt/harbor/harbor
docker-compose ps
docker-compose logs
```

**检查端口占用**：
```bash
netstat -tulpn | grep :80
```

**常见问题**：
- 配置文件错误
- 端口被占用
- 防火墙未开放

**解决方案**：
```bash
# 重新生成配置
./prepare

# 重启服务
docker-compose down
docker-compose up -d

# 检查日志
docker-compose logs -f
```

### 网站无法访问

**检查步骤**：
1. 确认容器运行中：`docker ps | grep site`
2. 确认端口开放：`netstat -tulpn | grep :3000`
3. 查看网站日志：`docker logs site`

**解决方案**：
```bash
# 重启容器
docker restart site

# 重新部署
docker stop site
docker rm site
docker run -d --name site -p 3000:3000 8.156.82.221/site/isfounder-site:latest
```

---

## 参考文档

- [Harbor 使用指南](docs/HARBOR-USAGE.md)
- [部署指南](deploy/README.md)
- [阿里云 ECS 文档](https://help.aliyun.com/document_detail/25430.html)
- [Docker 官方文档](https://docs.docker.com/)
- [Harbor 官方文档](https://goharbor.io/docs/)

---

## 联系方式

如有问题，请联系：
- 技术支持: 查看 GitHub Issues
- 文档反馈: 提交 PR 或 Issue

---

**创建日期**: 2026-06-20
**最后更新**: 2026-06-20
**维护者**: Fang Tao