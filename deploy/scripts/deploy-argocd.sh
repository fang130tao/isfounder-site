#!/bin/bash
set -e

SERVER_IP=${1:-8.156.82.221}

echo "=========================================="
echo "  ArgoCD 部署脚本"
echo "  服务器 IP: $SERVER_IP"
echo "=========================================="

echo ""
echo "1. 创建 ArgoCD 命名空间..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "2. 安装 ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo ""
echo "3. 等待 ArgoCD Pod 就绪..."
kubectl wait pods -n argocd --all --for=condition=Ready --timeout=5m

echo ""
echo "4. 配置 ArgoCD Server 服务类型..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

echo ""
echo "5. 应用 Ingress 配置..."
kubectl apply -f /opt/argocd/argocd/ingress.yaml

echo ""
echo "6. 获取初始管理员密码..."
PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)
echo "初始管理员密码: $PASSWORD"

echo ""
echo "7. 获取服务端口..."
NODE_PORT=$(kubectl -n argocd get svc argocd-server -o jsonpath='{.spec.ports[0].nodePort}')
echo "ArgoCD Server NodePort: $NODE_PORT"

echo ""
echo "=========================================="
echo "  ArgoCD 部署完成！"
echo "=========================================="
echo ""
echo "访问方式："
echo "  Web UI: http://$SERVER_IP:$NODE_PORT"
echo "  Ingress: https://argocd.$SERVER_IP.nip.io"
echo ""
echo "登录信息："
echo "  用户名: admin"
echo "  密码: $PASSWORD"
echo ""
echo "使用 argocd CLI 登录："
echo "  argocd login $SERVER_IP:$NODE_PORT --username admin --password $PASSWORD"
echo ""
echo "注意："
echo "  1. 首次登录后请立即修改密码: argocd account update-password"
echo "  2. 如使用 Ingress，需要确保 Traefik 已配置 TLS"
echo "  3. 建议配置阿里云安全组开放端口 $NODE_PORT"