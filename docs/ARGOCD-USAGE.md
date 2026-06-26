# ArgoCD 使用文档

## 概述

ArgoCD 是一个声明式的 GitOps 持续交付工具，用于 Kubernetes 应用程序的部署和管理。

本文档描述了如何在阿里云服务器的 K3s 集群上安装和使用 ArgoCD。

## 环境准备

### 前置条件

| 依赖 | 版本要求 | 状态 |
|------|----------|------|
| K3s | v1.27+ | ✅ 已安装 |
| kubectl | v1.27+ | ✅ 已安装 |
| Harbor | v2.10+ | ✅ 已安装 |

### 服务器信息

- **服务器 IP**: `8.156.82.221`
- **K3s kubeconfig**: `/etc/rancher/k3s/k3s.yaml`
- **ArgoCD CLI**: `/usr/local/bin/argocd`

## 安装步骤

### 方式一：使用部署脚本（推荐）

```bash
# 上传文件到服务器
scp -r deploy/argocd/ root@8.156.82.221:/opt/argocd/
scp deploy/scripts/deploy-argocd.sh root@8.156.82.221:/opt/argocd/scripts/

# 登录服务器并执行
ssh root@8.156.82.221
chmod +x /opt/argocd/scripts/deploy-argocd.sh
/opt/argocd/scripts/deploy-argocd.sh
```

### 方式二：手动安装

```bash
# 1. 创建命名空间
kubectl create namespace argocd

# 2. 安装 ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3. 等待 Pod 就绪
kubectl wait pods -n argocd --all --for=condition=Ready --timeout=5m

# 4. 暴露服务
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# 5. 应用 Ingress
kubectl apply -f /opt/argocd/argocd/ingress.yaml
```

## 访问 ArgoCD

### Web UI 访问

```bash
# 获取 NodePort
NODE_PORT=$(kubectl -n argocd get svc argocd-server -o jsonpath='{.spec.ports[0].nodePort}')
echo "ArgoCD Web UI: http://8.156.82.221:$NODE_PORT"
```

### 初始密码

```bash
# 获取初始管理员密码
PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)
echo "初始密码: $PASSWORD"
```

### 登录 Web UI

1. 打开浏览器访问 `http://8.156.82.221:<NODE_PORT>`
2. 用户名: `admin`
3. 密码: 上述获取的密码

## CLI 使用

### 登录

```bash
# 登录 ArgoCD
argocd login 8.156.82.221:<NODE_PORT> --username admin --password <PASSWORD>

# 首次登录后修改密码
argocd account update-password
```

### 常用命令

```bash
# 查看集群
argocd cluster list

# 查看应用
argocd app list

# 创建应用
argocd app create <APP_NAME> \
  --repo <GIT_REPO_URL> \
  --path <PATH_TO_MANIFESTS> \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace <NAMESPACE>

# 同步应用
argocd app sync <APP_NAME>

# 删除应用
argocd app delete <APP_NAME>
```

## 配置 GitOps 工作流

### 创建应用

```bash
# 创建网站应用
argocd app create isfounder-site \
  --repo https://github.com/fang130tao/isfounder-site.git \
  --path site/ \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated \
  --auto-prune \
  --self-heal
```

### 同步策略

| 策略 | 说明 |
|------|------|
| `automated` | 自动同步，当 Git 仓库有变更时自动部署 |
| `auto-prune` | 自动清理不在 Git 中的资源 |
| `self-heal` | 自动修复被手动修改的资源 |

## 集成 Harbor 镜像仓库

### 添加 Harbor 仓库

```bash
# 登录 Harbor
docker login 8.156.82.221

# 在 ArgoCD 中添加 Harbor 仓库
argocd repo add 8.156.82.221 \
  --type helm \
  --name harbor \
  --username admin \
  --password <HARBOR_PASSWORD>
```

### 使用 Harbor 镜像

在 Kubernetes 部署文件中使用 Harbor 镜像：

```yaml
image: 8.156.82.221/library/isfounder-site:latest
```

## 配置阿里云安全组

开放以下端口：

| 端口 | 用途 |
|------|------|
| 80 | HTTP |
| 443 | HTTPS |
| 30000-32767 | NodePort 范围 |
| 8080 | K3s API |

## 故障排查

### 查看 ArgoCD 日志

```bash
# 查看所有 Pod 状态
kubectl get pods -n argocd

# 查看具体 Pod 日志
kubectl logs -n argocd <POD_NAME>

# 查看服务状态
kubectl get svc -n argocd
```

### 常见问题

#### 问题：Pod 一直处于 Pending 状态

**原因**: 资源不足或调度问题

**解决**:
```bash
# 查看事件
kubectl describe pod -n argocd <POD_NAME>

# 检查节点状态
kubectl get nodes
```

#### 问题：无法访问 Web UI

**原因**: 网络配置问题

**解决**:
```bash
# 检查 Service 配置
kubectl get svc -n argocd argocd-server -o yaml

# 检查防火墙规则
ufw status

# 检查阿里云安全组
```

#### 问题：同步失败

**原因**: 镜像拉取失败或配置错误

**解决**:
```bash
# 查看应用状态
argocd app get <APP_NAME>

# 查看同步日志
argocd app sync <APP_NAME> --log
```

## 日常维护

### 备份 ArgoCD 配置

```bash
# 导出应用配置
argocd app export <APP_NAME> > <APP_NAME>.yaml

# 备份整个 ArgoCD 配置
kubectl get all -n argocd -o yaml > argocd-backup.yaml
```

### 更新 ArgoCD

```bash
# 更新 ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 重启 ArgoCD

```bash
# 重启所有 ArgoCD Pod
kubectl delete pods -n argocd --all
```

## 参考链接

- [ArgoCD 官方文档](https://argo-cd.readthedocs.io/)
- [ArgoCD GitHub](https://github.com/argoproj/argo-cd)
- [GitOps 概念](https://www.gitops.tech/)

## 配置文件清单

| 文件 | 说明 |
|------|------|
| `deploy/argocd/namespace.yaml` | ArgoCD 命名空间配置 |
| `deploy/argocd/ingress.yaml` | ArgoCD Ingress 配置 |
| `deploy/scripts/deploy-argocd.sh` | ArgoCD 部署脚本 |