#!/bin/bash

# 网站部署脚本
# 用于在阿里云服务器上部署网站

set -e

# ==========================================
# 配置参数
# ==========================================

SERVER_IP="${1:-8.156.82.221}"
SERVER_USER="root"
REGISTRY_IP="${2:-$SERVER_IP}"
PROJECT_NAME="isfounder-site"
SITE_DIR="/opt/site"
REGISTRY="${REGISTRY_IP}"

# ==========================================
# 颜色输出
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ==========================================
# 辅助函数
# ==========================================

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ==========================================
# 确认操作
# ==========================================

print_info "=========================================="
print_info "网站部署脚本"
print_info "=========================================="
echo ""

print_info "配置信息:"
echo ""
echo "  服务器 IP:      $SERVER_IP"
echo "  镜像仓库:       $REGISTRY"
echo "  项目名称:       $PROJECT_NAME"
echo "  部署目录:       $SITE_DIR"
echo ""

print_warning "此脚本将执行以下操作:"
echo ""
echo "  1. 从 Harbor 拉取网站镜像"
echo "  2. 停止旧容器（如果存在）"
echo "  3. 启动新容器"
echo "  4. 验证部署"
echo ""

read -p "确认继续？(y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "取消操作"
    exit 0
fi

echo ""

# ==========================================
# 在服务器上执行部署
# ==========================================

print_info "=========================================="
print_info "步骤 1: 在服务器上部署网站"
print_info "=========================================="
echo ""

ssh $SERVER_USER@$SERVER_IP << ENDSSH
set -e

echo "=========================================="
echo "[INFO] 网站部署脚本"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() {
    echo -e "\${GREEN}[INFO]\${NC} \$1"
}

warning() {
    echo -e "\${YELLOW}[WARNING]\${NC} \$1"
}

# ==========================================
# 检查 Docker
# ==========================================

info "检查 Docker..."
if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker 未安装"
    exit 1
fi

info "Docker 已安装: \$(docker --version)"
echo ""

# ==========================================
# 配置 Docker insecure registry
# ==========================================

info "配置 Docker 访问 Harbor..."

# 检查是否已配置
if grep -q "$REGISTRY" /etc/docker/daemon.json 2>/dev/null; then
    info "Harbor 已配置为 insecure registry"
else
    info "添加 Harbor 到 insecure registries..."
    
    mkdir -p /etc/docker
    
    # 添加到 insecure registries
    if [ -f /etc/docker/daemon.json ]; then
        # 添加到现有配置
        cat /etc/docker/daemon.json | jq ".insecure_registries += [\"$REGISTRY\"]" > /tmp/daemon.json
        mv /tmp/daemon.json /etc/docker/daemon.json
    else
        # 创建新配置
        echo "{\"insecure-registries\": [\"$REGISTRY\"]}" > /etc/docker/daemon.json
    fi
    
    # 重启 Docker
    info "重启 Docker 服务..."
    systemctl restart docker
    
    info "Docker 配置已更新"
fi

echo ""

# ==========================================
# 登录 Harbor
# ==========================================

info "登录 Harbor..."

# 检查是否已登录
if docker info 2>/dev/null | grep -q "$REGISTRY"; then
    info "已登录到 Harbor"
else
    echo "请输入 Harbor 用户名和密码:"
    docker login $REGISTRY
    
    if [ \$? -eq 0 ]; then
        info "登录成功"
    else
        echo "[ERROR] 登录失败"
        exit 1
    fi
fi

echo ""

# ==========================================
# 拉取镜像
# ==========================================

info "=========================================="
info "步骤 2: 拉取网站镜像"
info "=========================================="
echo ""

IMAGE="\${REGISTRY}/site/\${PROJECT_NAME}:latest"

info "镜像地址: \$IMAGE"
echo ""

# 检查镜像是否存在
if docker manifest inspect \$IMAGE > /dev/null 2>&1; then
    info "镜像存在，开始拉取..."
    docker pull \$IMAGE
    
    if [ \$? -eq 0 ]; then
        info "镜像拉取成功"
    else
        echo "[ERROR] 镜像拉取失败"
        exit 1
    fi
else
    warning "镜像不存在: \$IMAGE"
    echo ""
    info "请先构建并推送镜像:"
    echo "  docker build -t \$IMAGE ."
    echo "  docker push \$IMAGE"
    echo ""
    
    read -p "是否继续？（将部署最新可用镜像）(y/N): " -n 1 -r
    echo ""
    
    if [[ ! \$REPLY =~ ^[Yy]$ ]]; then
        info "取消操作"
        exit 0
    fi
fi

echo ""

# ==========================================
# 停止旧容器
# ==========================================

info "=========================================="
info "步骤 3: 停止旧容器"
info "=========================================="
echo ""

CONTAINER_NAME="site"

# 检查容器是否存在
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}\$"; then
    info "停止旧容器..."
    docker stop \$CONTAINER_NAME
    docker rm \$CONTAINER_NAME
    info "旧容器已停止和删除"
else
    info "没有找到旧容器，跳过"
fi

echo ""

# ==========================================
# 启动新容器
# ==========================================

info "=========================================="
info "步骤 4: 启动新容器"
info "=========================================="
echo ""

info "启动容器..."
docker run -d \
  --name \$CONTAINER_NAME \
  -p 3000:3000 \
  --restart unless-stopped \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  \$IMAGE

if [ \$? -eq 0 ]; then
    info "容器启动成功"
else
    echo "[ERROR] 容器启动失败"
    exit 1
fi

echo ""

# ==========================================
# 验证部署
# ==========================================

info "=========================================="
info "步骤 5: 验证部署"
info "=========================================="
echo ""

info "检查容器状态..."
sleep 2
docker ps | grep \$CONTAINER_NAME

echo ""

info "检查容器日志..."
docker logs \$CONTAINER_NAME --tail 10

echo ""

# 等待服务启动
info "等待服务启动..."
sleep 5

# 测试访问
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200\|301\|302"; then
    info "网站访问正常"
else
    warning "网站可能未完全启动，请稍后检查"
fi

echo ""

# ==========================================
# 部署完成
# ==========================================

info "=========================================="
info "[SUCCESS] 网站部署完成！"
info "=========================================="
echo ""

info "访问信息:"
echo ""
echo "  网站地址:   http://\$SERVER_IP:3000"
echo "  容器名称:   \$CONTAINER_NAME"
echo "  镜像地址:   \$IMAGE"
echo ""

info "管理命令:"
echo ""
echo "  查看状态:   docker ps | grep \$CONTAINER_NAME"
echo "  查看日志:   docker logs -f \$CONTAINER_NAME"
echo "  重启容器:   docker restart \$CONTAINER_NAME"
echo "  停止容器:   docker stop \$CONTAINER_NAME"
echo "  进入容器:   docker exec -it \$CONTAINER_NAME sh"
echo ""

ENDSSH

if [ $? -eq 0 ]; then
    print_success "网站部署完成"
else
    print_error "网站部署失败"
    exit 1
fi

echo ""

# ==========================================
# 最终信息
# ==========================================

print_info "=========================================="
print_success "部署成功！"
print_info "=========================================="
echo ""

print_info "访问信息:"
echo ""
echo "  网站地址:   http://${SERVER_IP}:3000"
echo "  Harbor:     http://${REGISTRY}"
echo ""

print_warning "管理命令:"
echo ""
echo "  SSH 到服务器:   ssh root@${SERVER_IP}"
echo "  查看日志:       docker logs -f site"
echo "  重启网站:       docker restart site"
echo "  停止网站:       docker stop site"
echo ""

print_success "部署完成！"