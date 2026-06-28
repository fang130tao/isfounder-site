# 部署进度总结

---

## 一、项目整体架构

| 服务 | 状态 | 访问地址 |
|------|------|----------|
| **Harbor 镜像仓库** | ✅ 已部署 | https://harbor.isfounder.com (80端口) |
| **K3s Kubernetes** | ✅ 已部署 | v1.35.5+k3s1 |
| **ArgoCD** | ✅ 已部署 | NodePort: 30404(HTTP), 30807(HTTPS) |
| **网站镜像** | ✅ 已构建 | GitHub Actions 自动推送 |
| **Traefik Ingress** | ❌ 未部署 | 镜像拉取失败 |

---

## 二、已完成任务

### 1. Harbor 镜像服务器部署
- ✅ 安装 Harbor 2.10.0
- ✅ 配置 HTTPS 通配符证书 (`*.isfounder.com`)
- ✅ 启动 Harbor 服务

### 2. K3s Kubernetes 部署
- ✅ 切换 cgroup v2（使用 `grubby`）
- ✅ 安装 K3s 单节点集群
- ✅ 验证节点和 Pod 状态

### 3. ArgoCD 部署
- ✅ 安装 ArgoCD CLI (`/usr/local/bin/argocd`)
- ✅ 应用安装清单 (`/opt/argocd/install.yaml`)
- ✅ 所有 Pod 运行正常
- ✅ 暴露 NodePort 服务 (30404/30807)
- ✅ 获取初始密码 (`XWDgPW-0ojFqcqzq`)

---

## 三、当前进行中任务

### ArgoCD 域名配置 (`https://argo.isfounder.com`)

**问题**：
- Traefik Ingress Controller 未安装（镜像拉取失败）
- HTTPS 证书已配置但浏览器显示"不安全"

**解决方案（待执行）**：

```bash
# 方案一：安装 Traefik（推荐）
helm repo add traefik https://helm.traefik.io/traefik
helm install traefik traefik/traefik \
  --namespace kube-system \
  --set "service.type=NodePort" \
  --set "service.nodePorts.http=30080" \
  --set "service.nodePorts.https=30443"

# 方案二：使用 nginx 反向代理（最简单）
cat > /etc/nginx/conf.d/argo.conf <<EOF
server {
    listen 443 ssl;
    server_name argo.isfounder.com;
    ssl_certificate /opt/harbor/cert/server.crt;
    ssl_certificate_key /opt/harbor/cert/server.key;
    location / {
        proxy_pass https://127.0.0.1:30807;
        proxy_set_header Host \$host;
    }
}
EOF
systemctl start nginx
```

---

## 四、关键配置文件

| 文件路径 | 说明 |
|----------|------|
| `/opt/harbor/harbor.yml` | Harbor 配置 |
| `/opt/harbor/cert/server.crt` | HTTPS 证书 |
| `/opt/argocd/install.yaml` | ArgoCD 安装清单 |
| `/usr/local/bin/argocd` | ArgoCD CLI |
| `/etc/rancher/k3s/k3s.yaml` | K3s kubeconfig |

---

## 五、关键命令速查

```bash
# 设置 KUBECONFIG（每次必做）
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# 永久生效
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc

# K3s 状态
kubectl get nodes
kubectl get pods -A

# Harbor 操作
cd /opt/harbor && docker compose ps
docker compose restart nginx

# ArgoCD 操作
kubectl get pods -n argocd
kubectl get ingress -n argocd
kubectl get secret argocd-server-tls -n argocd

# 证书验证
openssl x509 -in /opt/harbor/cert/server.crt -text -noout | grep DNS

# Traefik 安装状态
kubectl get pods -n kube-system | grep traefik
```

---

## 六、待完成任务

| 任务 | 优先级 | 状态 |
|------|--------|------|
| 安装 Traefik 或配置 nginx 反向代理 | 高 | ⏳ 待执行 |
| ArgoCD 域名 HTTPS 正常访问 | 高 | ⏳ 待执行 |
| 通过 ArgoCD 部署网站应用 | 中 | ⏳ 待执行 |
| 配置 Let's Encrypt 证书 | 低 | ⏳ 可选 |

---

## 七、访问信息汇总

| 服务 | 地址 | 用户名/密码 |
|------|------|------------|
| Harbor | https://harbor.isfounder.com | admin/Harbor12345 |
| ArgoCD (NodePort) | https://8.156.82.221:30807 | admin/XWDgPW-0ojFqcqzq |
| ArgoCD (域名) | https://argo.isfounder.com | ⏳ 配置中 |

---

## 八、遇到的主要问题与解决方案

| 问题 | 解决方案 |
|------|----------|
| cgroup v1 导致 K3s 无法启动 | `grubby --update-kernel=DEFAULT --args="systemd.unified_cgroup_hierarchy=1"` |
| kubectl 连接 localhost:8080 | `export KUBECONFIG=/etc/rancher/k3s/k3s.yaml` |
| ArgoCD Secret 已存在 | `kubectl delete secret argocd-server-tls -n argocd` |
| Traefik 镜像拉取失败 | 使用 Helm 安装或 nginx 反向代理 |
| HTTPS 显示"不安全" | 通配符证书 + nginx/Traefik 配置 |

---

## 九、下一步行动建议

1. **登录服务器**：
   ```bash
   ssh root@8.156.82.221
   export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
   ```

2. **选择 Traefik 或 nginx 方案**：
   - 推荐使用 **nginx 反向代理**（最简单）
   - 或使用 Helm 安装 Traefik

3. **验证 ArgoCD 域名访问**：
   ```bash
   curl -k https://argo.isfounder.com
   ```

4. **登录 ArgoCD Web UI**：
   - 用户名：`admin`
   - 密码：`XWDgPW-0ojFqcqzq`

---

## 十、服务器信息

- **公网 IP**: 8.156.82.221
- **系统**: Alibaba Cloud Linux 3
- **Docker**: 已安装
- **K3s**: v1.35.5+k3s1
- **cgroup**: v2 (已切换)