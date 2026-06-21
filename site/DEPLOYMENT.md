# 部署指南

## 📦 镜像信息

**镜像位置**: `ghcr.io/fang130tao/isfounder-site:latest`

**镜像标签**:
- `latest` - 最新版本（main 分支）
- `v1.2.3` - 完整版本号
- `v1.2` - 主版本.次版本
- `v1` - 主版本

## 🚀 部署方式

### 方式 1：本地 Docker 部署

#### 前提条件
- Docker 已安装
- GitHub Personal Access Token（PAT）

#### 步骤

1. **创建 GitHub Personal Access Token**
   - 访问：https://github.com/settings/tokens
   - 点击 "Generate new token" → "Generate new token (classic)"
   - 权限选择：`read:packages`
   - 复制生成的 token

2. **登录到 GitHub Container Registry**
   ```bash
   echo "YOUR_GITHUB_TOKEN" | docker login ghcr.io -u fang130tao --password-stdin
   ```

3. **拉取镜像**
   ```bash
   docker pull ghcr.io/fang130tao/isfounder-site:latest
   ```

4. **运行容器**
   ```bash
   docker run -d \
     --name artistry-site \
     -p 3000:3000 \
     --restart unless-stopped \
     ghcr.io/fang130tao/isfounder-site:latest
   ```

5. **访问网站**
   ```
   http://localhost:3000
   ```

### 方式 2：使用部署脚本

```bash
# 运行部署脚本
./scripts/deploy.sh
```

脚本会自动完成：
- 检查 Docker 安装
- 登录到 GHCR
- 拉取最新镜像
- 停止旧容器
- 启动新容器
- 显示状态和访问地址

### 方式 3：使用 Docker Compose

```bash
# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

### 方式 4：部署到云服务器

#### 阿里云 / 腾讯云 / AWS

1. **购买云服务器**
   - 选择 Ubuntu 20.04/22.04
   - 至少 1GB RAM，1 CPU

2. **安装 Docker**
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker $USER
   ```

3. **部署应用**
   ```bash
   # 使用部署脚本
   ./scripts/deploy.sh

   # 或手动部署
   docker pull ghcr.io/fang130tao/isfounder-site:latest
   docker run -d --name artistry-site -p 80:3000 --restart unless-stopped ghcr.io/fang130tao/isfounder-site:latest
   ```

4. **配置防火墙**
   ```bash
   # Ubuntu UFW
   sudo ufw allow 80/tcp
   sudo ufw enable
   ```

5. **访问网站**
   ```
   http://your-server-ip
   ```

### 方式 5：使用 Docker Swarm / Kubernetes

#### Docker Swarm

```bash
# 初始化 Swarm
docker swarm init

# 部署服务
docker service create \
  --name artistry-site \
  --publish 80:3000 \
  --replicas 2 \
  ghcr.io/fang130tao/isfounder-site:latest
```

#### Kubernetes

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: artistry-site
spec:
  replicas: 2
  selector:
    matchLabels:
      app: artistry-site
  template:
    metadata:
      labels:
        app: artistry-site
    spec:
      containers:
      - name: artistry-site
        image: ghcr.io/fang130tao/isfounder-site:latest
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: artistry-site
spec:
  selector:
    app: artistry-site
  ports:
  - port: 80
    targetPort: 3000
  type: LoadBalancer
```

```bash
# 部署
kubectl apply -f deployment.yaml

# 查看状态
kubectl get pods
kubectl get services
```

## 🔧 管理命令

### 查看容器状态
```bash
docker ps
docker logs artistry-site
```

### 停止容器
```bash
docker stop artistry-site
docker rm artistry-site
```

### 重启容器
```bash
docker restart artistry-site
```

### 更新到最新版本
```bash
docker pull ghcr.io/fang130tao/isfounder-site:latest
docker stop artistry-site
docker rm artistry-site
docker run -d --name artistry-site -p 3000:3000 --restart unless-stopped ghcr.io/fang130tao/isfounder-site:latest
```

## 🌐 域名配置

### 使用 Nginx 反向代理

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 配置 HTTPS（Let's Encrypt）

```bash
# 安装 Certbot
sudo apt install certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d your-domain.com

# 自动续期
sudo certbot renew --dry-run
```

## 📊 监控和日志

### 查看健康状态
```bash
docker inspect --format='{{.State.Health.Status}}' artistry-site
```

### 查看资源使用
```bash
docker stats artistry-site
```

### 导出日志
```bash
docker logs artistry-site > artistry-site.log
```

## 🔒 安全建议

1. **使用防火墙**：只开放必要端口
2. **定期更新**：及时更新镜像和系统
3. **监控日志**：定期检查应用日志
4. **备份**：定期备份数据（如果有）
5. **HTTPS**：生产环境使用 SSL 证书

## 🆘 故障排查

### 容器无法启动
```bash
# 查看日志
docker logs artistry-site

# 检查端口占用
sudo lsof -i :3000
```

### 无法访问网站
```bash
# 检查容器状态
docker ps -a

# 检查防火墙
sudo ufw status

# 检查端口映射
docker port artistry-site
```

### 镜像拉取失败
```bash
# 重新登录
echo "YOUR_TOKEN" | docker login ghcr.io -u fang130tao --password-stdin

# 检查网络连接
ping ghcr.io
```

## 📞 支持

如有问题，请查看：
- GitHub Actions 状态：https://github.com/fang130tao/isfounder-site/actions
- GitHub Issues：https://github.com/fang130tao/isfounder-site/issues