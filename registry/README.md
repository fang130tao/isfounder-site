# Harbor Registry 配置目录

本目录包含 Harbor 镜像服务器的所有配置文件和管理脚本。

## 📁 目录结构

```
registry/
├── harbor/          # Harbor 安装包（需下载）
├── certs/           # SSL 证书（可选）
├── config/          # Harbor 配置文件
├── scripts/         # Harbor 管理脚本
└── README.md        # 本文档
```

## 🚀 快速开始

### 1. 下载 Harbor 安装包

```bash
cd harbor/
wget https://github.com/goharbor/harbor/releases/download/v2.10.0/harbor-offline-installer-v2.10.0.tgz
tar xzvf harbor-offline-installer-v2.10.0.tgz
```

### 2. 配置 Harbor

```bash
cd config/
cp ../harbor/harbor.yml.tmpl harbor.yml
# 编辑 harbor.yml 配置文件
```

### 3. 安装 Harbor

```bash
cd scripts/
./install-harbor.sh
```

## 📝 子目录说明

### harbor/
存放 Harbor 安装包和安装脚本。

**内容**:
- `harbor-offline-installer-v2.10.0.tgz` - Harbor 安装包
- `harbor.yml.tmpl` - Harbor 配置模板
- `install.sh` - Harbor 安装脚本
- `docker-compose.yml` - Docker Compose 配置

### certs/
存放 SSL 证书文件（可选，用于 HTTPS）。

**内容**:
- `registry.crt` - SSL 证书
- `registry.key` - SSL 私钥

**生成证书**:
```bash
# 自签名证书（测试用）
openssl req -newkey rsa:4096 -nodes -sha256 -keyout registry.key \
  -x509 -days 365 -out registry.crt \
  -subj "/CN=8.156.82.221"

# 或使用 Let's Encrypt（生产环境）
certbot certonly --standalone -d your-domain.com
```

### config/
存放 Harbor 配置文件。

**主要文件**:
- `harbor.yml` - Harbor 主配置文件
- `docker-compose.yml` - Docker Compose 配置（可选）

**配置要点**:
```yaml
hostname: 8.156.82.221
http_port: 80
https_port: 443
harbor_admin_password: Harbor12345  # 请修改！
data_volume: /data/harbor
```

### scripts/
存放 Harbor 管理脚本。

**脚本列表**:
- `install-harbor.sh` - 安装 Harbor
- `start-harbor.sh` - 启动 Harbor
- `stop-harbor.sh` - 停止 Harbor
- `update-harbor.sh` - 更新 Harbor
- `backup-harbor.sh` - 备份 Harbor 数据

## 🔧 Harbor 配置指南

### 基础配置

编辑 `config/harbor.yml`:

```yaml
# Harbor 配置
hostname: 8.156.82.221  # 你的服务器 IP

# HTTP 配置
http:
  port: 80

# HTTPS 配置（可选）
https:
  port: 443
  certificate: /your/cert/path/registry.crt
  private_key: /your/cert/path/registry.key

# 管理员密码
harbor_admin_password: Harbor12345  # 请修改为强密码！

# 数据存储路径
data_volume: /data/harbor

# 日志配置
log:
  level: info
  rotate_count: 50
  rotate_size: 200M
  location: /var/log/harbor
```

### 高级配置

**数据库配置**:
```yaml
database:
  password: root123  # 请修改！
  max_idle_conns: 50
  max_open_conns: 1000
```

**Redis 配置**:
```yaml
redis:
  password: redis123  # 请修改！
  max_idle_conns: 50
  max_open_conns: 1000
```

## 🌐 Harbor Web UI

### 访问地址

- HTTP: `http://8.156.82.221`
- HTTPS: `https://8.156.82.21`（如果配置了 SSL）

### 默认账号

- 用户名: `admin`
- 密码: `Harbor12345`（配置文件中设置的密码）

### 主要功能

1. **项目管理**: 创建和管理多个项目
2. **镜像管理**: 查看、推送、拉取镜像
3. **用户管理**: 创建用户、分配权限
4. **镜像扫描**: 检测镜像漏洞
5. **镜像复制**: 复制镜像到其他 Registry

## 📦 Docker 使用

### 登录 Harbor

```bash
docker login 8.156.82.221
# Username: admin
# Password: Harbor12345
```

### 推送镜像

```bash
# 标记镜像
docker tag your-image:latest 8.156.82.221/site/your-image:latest

# 推送镜像
docker push 8.156.82.221/site/your-image:latest
```

### 拉取镜像

```bash
docker pull 8.156.82.221/site/your-image:latest
```

## 🔒 安全建议

1. **修改默认密码**: 立即修改 `harbor_admin_password`
2. **启用 HTTPS**: 生产环境必须使用 HTTPS
3. **配置防火墙**: 只开放必要端口（80、443）
4. **定期备份**: 使用 `backup-harbor.sh` 定期备份数据
5. **用户权限**: 为不同用户分配不同权限

## 📚 相关文档

- [Harbor 官方文档](https://goharbor.io/docs/)
- [Harbor GitHub](https://github.com/goharbor/harbor)
- [Harbor 配置指南](https://goharbor.io/docs/2.10.0/install-config/)
- [Harbor 管理指南](https://goharbor.io/docs/2.10.0/administration/)

## 🆘 故障排查

### Harbor 无法启动

```bash
# 查看日志
docker-compose logs

# 检查配置
cat config/harbor.yml

# 重启服务
docker-compose restart
```

### 无法推送镜像

```bash
# 检查 Docker 配置
cat /etc/docker/daemon.json

# 需要添加（如果使用 HTTP）:
{
  "insecure-registries": ["8.156.82.221"]
}

# 重启 Docker
systemctl restart docker
```

### Web UI 无法访问

```bash
# 检查端口
netstat -tulpn | grep :80

# 检查防火墙
firewall-cmd --list-all

# 开放端口
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --reload
```

## 📞 支持

如有问题，请查看：
- Harbor 日志: `/var/log/harbor/`
- Docker 日志: `docker-compose logs`
- 配置文件: `config/harbor.yml`