# Harbor 使用指南

完整的 Harbor 镜像服务器使用指南，涵盖从安装到日常运维的所有操作。

## 📚 目录

1. [快速开始](#快速开始)
2. [安装 Harbor](#安装-harbor)
3. [配置 Harbor](#配置-harbor)
4. [访问 Harbor](#访问-harbor)
5. [项目管理](#项目管理)
6. [用户管理](#用户管理)
7. [镜像操作](#镜像操作)
8. [CI/CD 集成](#cicd-集成)
9. [日常运维](#日常运维)
10. [故障排查](#故障排查)

---

## 快速开始

### 系统要求

- **操作系统**: Ubuntu 20.04/22.04 或 CentOS 7/8
- **硬件**: 最低 2核4G，推荐 4核8G
- **存储**: 至少 20GB（建议 50GB+）
- **软件**: Docker 20.10+ 和 Docker Compose 2.0+

### 快速安装

```bash
# 1. 下载 Harbor 安装包
cd registry/harbor
./scripts/download-harbor.sh

# 2. 上传到服务器
scp -r registry/* root@8.156.82.221:/opt/harbor

# 3. 在服务器上安装
ssh root@8.156.82.221
cd /opt/harbor/scripts
./install-harbor.sh
```

---

## 安装 Harbor

### 步骤 1: 下载安装包

**方式 1: 直接下载**
```bash
cd registry/harbor
curl -L -O https://github.com/goharbor/harbor/releases/download/v2.10.0/harbor-offline-installer-v2.10.0.tgz
```

**方式 2: 使用下载脚本**
```bash
cd registry/scripts
./download-harbor.sh
```

**方式 3: 手动下载**
- 访问: https://github.com/goharbor/harbor/releases
- 下载: `harbor-offline-installer-v2.10.0.tgz` (~600MB)
- 放到: `registry/harbor/` 目录

### 步骤 2: 解压安装包

```bash
cd registry/harbor
tar xzvf harbor-offline-installer-v2.10.0.tgz
```

### 步骤 3: 配置 Harbor

```bash
cd harbor
cp ../config/harbor.yml harbor.yml
# 或使用模板
cp harbor.yml.tmpl harbor.yml
```

**编辑配置文件**:
```bash
vim harbor.yml
```

**关键配置**:
```yaml
hostname: 8.156.82.221  # 服务器 IP
harbor_admin_password: Harbor12345  # 修改密码！
data_volume: /data/harbor  # 数据存储路径
```

### 步骤 4: 安装 Harbor

```bash
# 生成配置
./prepare

# 安装
./install.sh

# 启动
docker-compose up -d
```

---

## 配置 Harbor

### 基础配置

**harbor.yml 配置文件**:

```yaml
# 主机名（必须）
hostname: 8.156.82.221

# HTTP 配置
http:
  port: 80

# HTTPS 配置（可选）
https:
  port: 443
  certificate: /path/to/registry.crt
  private_key: /path/to/registry.key

# 管理员密码（必须修改）
harbor_admin_password: YourStrongPassword123!

# 数据存储
data_volume: /data/harbor

# 数据库
database:
  password: HarborDB12345

# Redis
redis:
  password: HarborRedis12345

# 日志
log:
  level: info
  location: /var/log/harbor
```

### HTTPS 配置

**方式 1: 自签名证书（测试用）**
```bash
# 生成证书
openssl req -newkey rsa:4096 -nodes -sha256 -keyout registry.key \
  -x509 -days 365 -out registry.crt \
  -subj "/CN=8.156.82.221"

# 配置 harbor.yml
https:
  port: 443
  certificate: /path/to/registry.crt
  private_key: /path/to/registry.key
```

**方式 2: Let's Encrypt（生产环境）**
```bash
# 安装 certbot
apt-get install certbot

# 获取证书（需要域名）
certbot certonly --standalone -d your-domain.com

# 配置 harbor.yml
https:
  port: 443
  certificate: /etc/letsencrypt/live/your-domain.com/fullchain.pem
  private_key: /etc/letsencrypt/live/your-domain.com/privkey.pem
```

### Docker 客户端配置

**HTTP 配置**:
```bash
# 编辑 Docker daemon 配置
vim /etc/docker/daemon.json

# 添加内容
{
  "insecure-registries": ["8.156.82.221"]
}

# 重启 Docker
systemctl restart docker
```

**HTTPS 配置**:
```bash
# 不需要修改 daemon.json
# 但需要信任证书
mkdir -p /etc/docker/certs.d/8.156.82.221
cp registry.crt /etc/docker/certs.d/8.156.82.221/
```

---

## 访问 Harbor

### Web UI 访问

**HTTP**:
```
http://8.156.82.221
```

**HTTPS**:
```
https://8.156.82.221
```

**默认账号**:
- 用户名: `admin`
- 密码: `Harbor12345`（配置文件中设置的）

### API 访问

**API 文档**:
```
http://8.156.82.221/api/v2.0/
```

**示例请求**:
```bash
# 获取系统信息
curl -u admin:Harbor12345 http://8.156.82.221/api/v2.0/systeminfo

# 获取项目列表
curl -u admin:Harbor12345 http://8.156.82.221/api/v2.0/projects

# 获取镜像列表
curl -u admin:Harbor12345 http://8.156.82.221/api/v2.0/projects/site/repositories
```

---

## 项目管理

### 创建项目

**方式 1: Web UI**
1. 登录 Harbor Web UI
2. 点击 "Projects" → "NEW PROJECT"
3. 输入项目名称（如 `site`）
4. 设置访问级别（Public 或 Private）
5. 点击 "OK"

**方式 2: API**
```bash
curl -X POST -u admin:Harbor12345 \
  -H "Content-Type: application/json" \
  -d '{"project_name":"site","public":false}' \
  http://8.156.82.221/api/v2.0/projects
```

### 项目配置

**项目名称规范**:
- 只能包含小写字母、数字、`-`、`_`
- 不能以 `-` 或 `_` 开头
- 最大长度 255 字符

**访问级别**:
- **Public**: 所有人可访问（不推荐）
- **Private**: 只有项目成员可访问（推荐）

**推荐项目**:
```
site          # 网站镜像
tools         # 工具镜像
base          # 基础镜像
experimental  # 实验镜像
```

---

## 用户管理

### 创建用户

**方式 1: Web UI**
1. 登录 Harbor Web UI
2. 点击 "Users" → "NEW USER"
3. 输入用户信息
4. 点击 "OK"

**方式 2: API**
```bash
curl -X POST -u admin:Harbor12345 \
  -H "Content-Type: application/json" \
  -d '{"username":"developer","email":"dev@example.com","realname":"Developer","password":"DevPass123"}' \
  http://8.156.82.221/api/v2.0/users
```

### 用户角色

| 角色 | 权限 |
|------|------|
| **Admin** | 所有权限（管理员） |
| **Maintainer** | 管理镜像、添加成员 |
| **Developer** | 推送、拉取镜像 |
| **Guest** | 只能拉取镜像 |

### 添加项目成员

**方式 1: Web UI**
1. 进入项目 → "Members"
2. 点击 "ADD MEMBER"
3. 输入用户名和角色
4. 点击 "OK"

**方式 2: API**
```bash
curl -X POST -u admin:Harbor12345 \
  -H "Content-Type: application/json" \
  -d '{"member_user":{"username":"developer"},"role_id":2}' \
  http://8.156.82.221/api/v2.0/projects/site/members
```

---

## 镜像操作

### Docker 登录

```bash
docker login 8.156.82.221
# Username: admin
# Password: Harbor12345
```

### 推送镜像

**步骤 1: 标记镜像**
```bash
# 标记镜像
docker tag your-image:latest 8.156.82.221/site/your-image:latest

# 或标记为特定版本
docker tag your-image:latest 8.156.82.221/site/your-image:v1.0.0
```

**步骤 2: 推送镜像**
```bash
# 推送镜像
docker push 8.156.82.221/site/your-image:latest

# 推送所有标签
docker push 8.156.82.221/site/your-image --all-tags
```

### 拉取镜像

```bash
# 拉取镜像
docker pull 8.156.82.221/site/your-image:latest

# 拉取特定版本
docker pull 8.156.82.221/site/your-image:v1.0.0
```

### 删除镜像

**方式 1: Web UI**
1. 进入项目 → "Repositories"
2. 选择镜像 → 点击删除图标
3. 确认删除

**方式 2: API**
```bash
curl -X DELETE -u admin:Harbor12345 \
  http://8.156.82.221/api/v2.0/projects/site/repositories/your-image/tags/latest
```

**方式 3: Docker（不推荐）**
```bash
# Docker 不能直接删除远程镜像
# 必须通过 Harbor Web UI 或 API
```

---

## CI/CD 集成

### GitHub Actions 配置

**修改 `.github/workflows/ci-cd.yml`**:
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main]

env:
  REGISTRY: 8.156.82.221
  IMAGE_NAME: site/isfounder-site

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Login to Harbor
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ secrets.HARBOR_USERNAME }}
          password: ${{ secrets.HARBOR_PASSWORD }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
```

**添加 GitHub Secrets**:
- `HARBOR_USERNAME`: Harbor 用户名
- `HARBOR_PASSWORD`: Harbor 密码

### GitLab CI 配置

```yaml
# .gitlab-ci.yml
stages:
  - build
  - push

build_and_push:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker login -u $HARBOR_USER -p $HARBOR_PASS 8.156.82.221
    - docker build -t 8.156.82.221/site/isfounder-site:$CI_COMMIT_SHA .
    - docker push 8.156.82.221/site/isfounder-site:$CI_COMMIT_SHA
  variables:
    HARBOR_USER: $HARBOR_USERNAME
    HARBOR_PASS: $HARBOR_PASSWORD
```

---

## 日常运维

### 启动 Harbor

```bash
cd /opt/harbor/harbor
docker-compose start
```

### 停止 Harbor

```bash
cd /opt/harbor/harbor
docker-compose stop
```

### 重启 Harbor

```bash
cd /opt/harbor/harbor
docker-compose restart
```

### 查看状态

```bash
docker-compose ps
docker-compose logs
```

### 备份数据

```bash
cd /opt/harbor/scripts
./backup-harbor.sh
```

### 更新 Harbor

```bash
cd /opt/harbor/scripts
./update-harbor.sh
```

### 清理镜像

**清理旧镜像**:
1. Web UI → 项目 → Repositories
2. 选择旧标签 → 删除

**设置保留策略**:
1. Web UI → 项目 → Configuration
2. 设置 "Tag Retention" 规则

---

## 故障排查

### Harbor 无法启动

**检查日志**:
```bash
docker-compose logs
docker-compose logs harbor-core
docker-compose logs harbor-db
```

**检查配置**:
```bash
cat harbor.yml
./prepare
```

**重启服务**:
```bash
docker-compose restart
```

### 无法推送镜像

**检查登录**:
```bash
docker login 8.156.82.221
```

**检查 Docker 配置**:
```bash
cat /etc/docker/daemon.json
# 应包含: "insecure-registries": ["8.156.82.221"]
```

**检查网络**:
```bash
curl -v http://8.156.82.221/v2/
```

### Web UI 无法访问

**检查端口**:
```bash
netstat -tulpn | grep :80
```

**检查防火墙**:
```bash
ufw status
firewall-cmd --list-all
```

**检查服务**:
```bash
docker-compose ps
curl http://8.156.82.221/api/v2.0/systeminfo
```

### 镜像拉取失败

**检查项目权限**:
- 确保用户有项目访问权限
- Public 项目所有人可访问
- Private 项目需要登录

**检查镜像存在**:
```bash
curl -u admin:Harbor12345 \
  http://8.156.82.221/api/v2.0/projects/site/repositories
```

---

## 安全建议

### 基础安全

1. **修改默认密码**
   - 管理员密码
   - 数据库密码
   - Redis密码

2. **启用 HTTPS**
   - 生产环境必须
   - 使用 Let's Encrypt 或购买证书

3. **配置防火墙**
   - 只开放必要端口
   - 使用白名单

4. **用户权限管理**
   - 不要给所有人 Admin 权限
   - 按需分配角色

### 高级安全

1. **镜像扫描**
   - 启用漏洞扫描
   - 定期检查镜像安全

2. **访问控制**
   - 配置 IP 白名单
   - 使用 LDAP/OIDC 集成

3. **审计日志**
   - 定期检查操作日志
   - 监控异常行为

4. **数据备份**
   - 定期备份数据
   - 测试恢复流程

---

## 参考文档

- [Harbor 官方文档](https://goharbor.io/docs/)
- [Harbor GitHub](https://github.com/goharbor/harbor)
- [Harbor API 文档](https://goharbor.io/docs/2.10.0/administration/api/)
- [Harbor 配置指南](https://goharbor.io/docs/2.10.0/install-config/)

---

## 常见问题

### Q: Harbor 占用多少存储空间？

**A**: 每个镜像约 200-500MB，建议预留 20GB 以上空间。

### Q: 如何迁移 Harbor？

**A**:
1. 备份数据库和镜像数据
2. 在新服务器上安装 Harbor
3. 恢复数据库和镜像数据
4. 更新客户端配置

### Q: 如何监控 Harbor？

**A**:
- 使用 Prometheus + Grafana
- 监控磁盘使用、容器状态
- 设置告警规则

### Q: Harbor 支持哪些镜像格式？

**A**: Docker 镜像、OCI 镜像、Helm Charts。

---

**创建日期**: 2026-06-20
**最后更新**: 2026-06-20
**维护者**: Fang Tao