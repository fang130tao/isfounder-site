#!/bin/bash

# Harbor 部署脚本
# 用于在阿里云服务器上部署 Harbor 镜像服务器

set -e

# ==========================================
# 配置参数
# ==========================================

SERVER_IP="${1:-8.156.82.221}"
SERVER_USER="root"
HARBOR_DIR="/opt/harbor"
HARBOR_VERSION="v2.10.0"
HARBOR_PACKAGE="harbor-offline-installer-${HARBOR_VERSION}.tgz"

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
# 检查本地文件
# ==========================================

print_info "=========================================="
print_info "Harbor 部署脚本"
print_info "=========================================="
echo ""

print_info "检查本地配置文件..."
echo ""

# 检查 Harbor 安装包
if [ ! -f "registry/harbor/${HARBOR_PACKAGE}" ]; then
    print_error "Harbor 安装包不存在: registry/harbor/${HARBOR_PACKAGE}"
    print_info "请先下载 Harbor 安装包"
    print_info "运行: ./download-harbor.sh"
    exit 1
fi

print_success "Harbor 安装包已找到"

# 检查配置文件
if [ ! -f "registry/config/harbor.yml" ]; then
    print_error "配置文件不存在: registry/config/harbor.yml"
    exit 1
fi

print_success "配置文件已找到"

# 检查脚本
if [ ! -f "registry/scripts/install-harbor.sh" ]; then
    print_error "安装脚本不存在: registry/scripts/install-harbor.sh"
    exit 1
fi

print_success "安装脚本已找到"
echo ""

# ==========================================
# 确认操作
# ==========================================

print_warning "此脚本将执行以下操作:"
echo ""
echo "  1. 上传 Harbor 配置文件到服务器"
echo "  2. 在服务器上执行安装脚本"
echo ""
print_warning "服务器 IP: $SERVER_IP"
echo ""

read -p "确认继续？(y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "取消操作"
    exit 0
fi

echo ""

# ==========================================
# 创建临时目录
# ==========================================

print_info "=========================================="
print_info "步骤 1: 准备上传文件"
print_info "=========================================="
echo ""

TEMP_DIR="/tmp/harbor-deploy-$(date +%s)"
mkdir -p $TEMP_DIR

print_info "创建临时目录: $TEMP_DIR"
echo ""

# 复制文件
print_info "复制配置文件..."
cp -r registry/* $TEMP_DIR/

print_success "文件已准备好"
echo ""

# ==========================================
# 上传文件到服务器
# ==========================================

print_info "=========================================="
print_info "步骤 2: 上传文件到服务器"
print_info "=========================================="
echo ""

print_info "上传配置文件到 ${SERVER_IP}..."

# 创建服务器目录
ssh $SERVER_USER@$SERVER_IP "mkdir -p $HARBOR_DIR"

# 上传文件
scp -r $TEMP_DIR/* $SERVER_USER@$SERVER_IP:$HARBOR_DIR/

print_success "文件上传完成"
echo ""

# 清理临时目录
rm -rf $TEMP_DIR

# ==========================================
# 在服务器上执行安装
# ==========================================

print_info "=========================================="
print_info "步骤 3: 在服务器上安装 Harbor"
print_info "=========================================="
echo ""

print_info "连接服务器并执行安装..."
echo ""

ssh $SERVER_USER@$SERVER_IP << 'ENDSSH'
set -e

echo "=========================================="
echo "[INFO] 检查服务器环境"
echo "=========================================="
echo ""

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker 未安装"
    echo "请先运行服务器初始化脚本"
    exit 1
fi

echo "[INFO] Docker 已安装: $(docker --version)"

# 检查 Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "[ERROR] Docker Compose 未安装"
    exit 1
fi

echo "[INFO] Docker Compose 已安装"

echo ""

# ==========================================
# 解压安装包
# ==========================================

echo "=========================================="
echo "[INFO] 解压 Harbor 安装包"
echo "=========================================="
echo ""

cd /opt/harbor

if [ -d "harbor" ]; then
    echo "[WARNING] harbor 目录已存在，跳过解压"
else
    echo "[INFO] 解压安装包..."
    tar xzvf harbor-offline-installer-*.tgz
    echo "[SUCCESS] 解压完成"
fi

echo ""

# ==========================================
# 配置 Harbor
# ==========================================

echo "=========================================="
echo "[INFO] 配置 Harbor"
echo "=========================================="
echo ""

cd harbor

if [ -f "../config/harbor.yml" ]; then
    echo "[INFO] 复制配置文件..."
    cp ../config/harbor.yml harbor.yml
    echo "[SUCCESS] 配置文件已复制"
else
    echo "[WARNING] 配置文件不存在，使用模板"
    if [ -f "harbor.yml.tmpl" ]; then
        cp harbor.yml.tmpl harbor.yml
        echo "[INFO] 请编辑 harbor.yml 配置文件"
        echo "[INFO] vim harbor.yml"
    fi
fi

echo ""

# ==========================================
# 创建数据目录
# ==========================================

echo "=========================================="
echo "[INFO] 创建数据目录"
echo "=========================================="
echo ""

DATA_VOLUME="/data/harbor"

if [ ! -d "$DATA_VOLUME" ]; then
    echo "[INFO] 创建数据目录: $DATA_VOLUME"
    mkdir -p $DATA_VOLUME
    echo "[SUCCESS] 数据目录已创建"
else
    echo "[WARNING] 数据目录已存在: $DATA_VOLUME"
fi

echo ""

# ==========================================
# 运行 prepare
# ==========================================

echo "=========================================="
echo "[INFO] 运行 prepare 脚本"
echo "=========================================="
echo ""

if [ ! -f "prepare" ]; then
    echo "[ERROR] prepare 脚本不存在"
    exit 1
fi

echo "[INFO] 生成配置..."
./prepare

echo "[SUCCESS] 配置生成完成"
echo ""

# ==========================================
# 安装 Harbor
# ==========================================

echo "=========================================="
echo "[INFO] 安装 Harbor"
echo "=========================================="
echo ""

if [ ! -f "install.sh" ]; then
    echo "[ERROR] install.sh 不存在"
    exit 1
fi

echo "[INFO] 开始安装..."
./install.sh

echo "[SUCCESS] Harbor 安装完成"
echo ""

# ==========================================
# 启动 Harbor
# ==========================================

echo "=========================================="
echo "[INFO] 启动 Harbor"
echo "=========================================="
echo ""

echo "[INFO] 启动服务..."
docker-compose up -d

echo "[SUCCESS] Harbor 已启动"
echo ""

# ==========================================
# 验证安装
# ==========================================

echo "=========================================="
echo "[INFO] 验证安装"
echo "=========================================="
echo ""

echo "[INFO] 检查服务状态..."
docker-compose ps

echo ""

echo "[INFO] 等待服务启动..."
sleep 10

echo "[INFO] 检查 Harbor 版本..."
curl -s http://localhost/api/v2.0/systeminfo | grep -o '"harbor_version":"[^"]*"' || echo "[INFO] API 响应正常"

echo ""

# ==========================================
# 安装完成
# ==========================================

echo "=========================================="
echo "[SUCCESS] Harbor 部署成功！"
echo "=========================================="
echo ""

echo "访问信息:"
echo ""
echo "  Web UI:  http://8.156.82.221"
echo "  API:     http://8.156.82.221/api/v2.0"
echo ""
echo "  用户名:  admin"
echo "  密码:    Harbor12345 (请修改！)"
echo ""

echo "管理命令:"
echo ""
echo "  查看状态:   docker-compose ps"
echo "  查看日志:   docker-compose logs"
echo "  启动服务:   docker-compose start"
echo "  停止服务:   docker-compose stop"
echo "  重启服务:   docker-compose restart"
echo ""

ENDSSH

if [ $? -eq 0 ]; then
    print_success "Harbor 部署完成"
else
    print_error "Harbor 部署失败"
    exit 1
fi

echo ""

# ==========================================
# 部署完成
# ==========================================

print_info "=========================================="
print_success "Harbor 部署成功！"
print_info "=========================================="
echo ""

print_info "访问信息:"
echo ""
echo "  Web UI:  http://${SERVER_IP}"
echo "  API:     http://${SERVER_IP}/api/v2.0"
echo ""
echo "  用户名:  admin"
echo "  密码:    Harbor12345 (请修改！)"
echo ""

print_warning "下一步操作:"
echo ""
echo "  1. 访问 Web UI: http://${SERVER_IP}"
echo "  2. 修改管理员密码"
echo "  3. 创建项目和用户"
echo "  4. 测试镜像推送和拉取"
echo ""

print_success "部署完成！"