# 部署配置和脚本目录

本目录包含所有部署相关的脚本、配置文件和文档。

## 📁 目录结构

```
deploy/
├── scripts/         # 部署脚本
├── configs/         # 部署配置文件
├── docs/            # 部署文档
└── README.md        # 本文档
```

## 🚀 快速开始

### 1. 初始化服务器

```bash
cd scripts/
./setup-server.sh 8.156.82.221
```

### 2. 部署 Harbor

```bash
./deploy-registry.sh 8.156.82.221
```

### 3. 部署网站

```bash
./deploy-site.sh 8.156.82.221
```

## 📝 子目录说明

### scripts/
存放所有部署和管理脚本。

**脚本列表**:
- `setup-server.sh` - 服务器初始化（安装 Docker、配置防火墙等）
- `deploy-registry.sh` - Harbor 部署脚本
- `deploy-site.sh` - 网站部署脚本
- `backup.sh` - 备份脚本
- `monitor.sh` - 监控脚本

**使用方法**:
```bash
# 初始化服务器
./scripts/setup-server.sh <服务器IP>

# 部署 Harbor
./scripts/deploy-registry.sh <服务器IP>

# 部署网站
./scripts/deploy-site.sh <服务器IP>
```

### configs/
存放部署配置文件。

**配置文件**:
- `nginx.conf` - Nginx 反向代理配置（可选）
- `docker-daemon.json` - Docker daemon 配置
- `firewall-rules.sh` - 防火墙规则配置

**Docker daemon 配置示例**:
```json
{
  "insecure-registries": ["8.156.82.221"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

### docs/
存放部署相关文档。

**文档列表**:
- `SERVER-SETUP.md` - 服务器配置详细指南
- `HARBOR-SETUP.md` - Harbor 配置详细指南
- `CI-INTEGRATION.md` - CI/CD 集成指南
- `TROUBLESHOOTING.md` - 故障排查指南

## 🌐 部署流程

### 完整部署流程

```
1. 服务器初始化
   ↓
2. 安装 Docker & Docker Compose
   ↓
3. 配置防火墙
   ↓
4. 部署 Harbor
   ↓
5. 配置 Harbor
   ↓
6. 部署网站
   ↓
7. 配置 CI/CD
   ↓
8. 测试验证
```

### 部署顺序

**推荐顺序**:
1. 先部署 Harbor（镜像服务器）
2. 再部署网站（应用服务器）
3. 最后配置 CI/CD（自动化）

**原因**:
- Harbor 是基础设施，需要先部署
- 网站镜像需要推送到 Harbor
- CI/CD 需要连接 Harbor

## 🔧 服务器配置

### 阿里云服务器信息

- **IP**: 8.156.82.221
- **系统**: Ubuntu 20.04/22.04（推荐）
- **配置**: 最低 2核4G，推荐 4核8G
- **存储**: 至少 20GB

### SSH 连接

```bash
# 连接服务器
ssh root@8.156.82.221

# 或使用密钥
ssh -i ~/.ssh/aliyun_key root@8.156.82.221
```

### 防火墙配置

**需要开放的端口**:
- `22` - SSH
- `80` - HTTP（Harbor Web UI）
- `443` - HTTPS（可选）
- `3000` - 网站（如果直接暴露）

**配置命令**:
```bash
# UFW (Ubuntu)
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable

# 或 firewall-cmd (CentOS)
firewall-cmd --permanent --add-port=22/tcp
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload
```

## 📦 Harbor 部署

### 部署步骤

1. **上传配置文件**
   ```bash
   scp -r ../registry/config root@8.156.82.221:/opt/harbor
   ```

2. **安装 Harbor**
   ```bash
   cd /opt/harbor
   ./install.sh
   ```

3. **启动 Harbor**
   ```bash
   docker-compose up -d
   ```

4. **验证状态**
   ```bash
   docker-compose ps
   curl http://8.156.82.221/api/v2.0/systeminfo
   ```

### Harbor 配置要点

**必须修改**:
- `hostname`: 设置为服务器 IP
- `harbor_admin_password`: 修改默认密码
- `data_volume`: 设置数据存储路径

**可选配置**:
- HTTPS 证书
- 邮件通知
- 验证码设置

## 🌐 网站部署

### 部署方式

**方式 1: Docker 直接部署**
```bash
docker pull 8.156.82.221/site/isfounder-site:latest
docker run -d -p 3000:3000 --name site 8.156.82.221/site/isfounder-site:latest
```

**方式 2: Docker Compose**
```bash
docker-compose up -d
```

**方式 3: Nginx 反向代理**
```bash
# 配置 Nginx
cp configs/nginx.conf /etc/nginx/sites-available/site
ln -s /etc/nginx/sites-available/site /etc/nginx/sites-enabled/site
nginx -t
systemctl restart nginx
```

## 🔄 CI/CD 集成

### GitHub Actions 配置

**修改 `.github/workflows/ci-cd.yml`**:
```yaml
env:
  REGISTRY: 8.156.82.221  # Harbor 地址
  IMAGE_NAME: site/isfounder-site

steps:
  - name: Login to Harbor
    uses: docker/login-action@v3
    with:
      registry: ${{ env.REGISTRY }}
      username: ${{ secrets.HARBOR_USERNAME }}
      password: ${{ secrets.HARBOR_PASSWORD }}
```

**添加 GitHub Secrets**:
- `HARBOR_USERNAME`: Harbor 用户名
- `HARBOR_PASSWORD`: Harbor 密码

## 📊 监控和维护

### 监控脚本

```bash
# 查看服务状态
./scripts/monitor.sh status

# 查看日志
./scripts/monitor.sh logs

# 查看资源使用
./scripts/monitor.sh resources
```

### 备份脚本

```bash
# 备份 Harbor 数据
./scripts/backup.sh harbor

# 备份网站数据
./scripts/backup.sh site
```

## 🔒 安全建议

1. **SSH 安全**
   - 禁用密码登录，使用密钥
   - 修改默认 SSH 端口
   - 安装 fail2ban

2. **防火墙**
   - 只开放必要端口
   - 定期检查规则
   - 使用白名单

3. **Harbor 安全**
   - 修改默认密码
   - 启用 HTTPS
   - 配置用户权限

4. **定期维护**
   - 更新系统和软件
   - 清理旧镜像
   - 备份数据

## 🆘 故障排查

### 常见问题

**服务器无法连接**:
```bash
# 检查 SSH
ssh -vvv root@8.156.82.221

# 检查防火墙
ufw status
```

**Harbor 无法访问**:
```bash
# 检查服务状态
docker-compose ps

# 检查端口
netstat -tulpn | grep :80
```

**镜像推送失败**:
```bash
# 检查 Docker 配置
cat /etc/docker/daemon.json

# 检查登录状态
docker login 8.156.82.221
```

**网站无法访问**:
```bash
# 检查容器状态
docker ps | grep site

# 检查日志
docker logs site
```

## 📚 相关文档

- [服务器配置指南](docs/SERVER-SETUP.md)
- [Harbor 配置指南](docs/HARBOR-SETUP.md)
- [CI/CD 集成指南](docs/CI-INTEGRATION.md)
- [故障排查指南](docs/TROUBLESHOOTING.md)

## 📞 支持

如有问题，请查看：
- 部署日志: `/var/log/deploy/`
- Harbor 日志: `/var/log/harbor/`
- Docker 日志: `docker logs <container>`