#!/bin/bash

# Harbor 停止脚本

set -e

# ==========================================
# 配置参数
# ==========================================

HARBOR_DIR="/opt/harbor/harbor"

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
# 检查 Harbor 目录
# ==========================================

print_info "=========================================="
print_info "Harbor 停止脚本"
print_info "=========================================="
echo ""

if [ ! -d "$HARBOR_DIR" ]; then
    print_error "Harbor 目录不存在: $HARBOR_DIR"
    print_info "请先运行安装脚本: ./install-harbor.sh"
    exit 1
fi

# ==========================================
# 进入 Harbor 目录
# ==========================================

cd $HARBOR_DIR

# ==========================================
# 检查 Docker Compose 文件
# ==========================================

if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml 不存在"
    exit 1
fi

# ==========================================
# 停止 Harbor
# ==========================================

print_info "停止 Harbor 服务..."
docker-compose stop

print_success "Harbor 已停止"
echo ""

# ==========================================
# 查看状态
# ==========================================

print_info "服务状态:"
docker-compose ps

echo ""

# ==========================================
# 完成
# ==========================================

print_success "Harbor 停止成功！"
echo ""
print_warning "注意: 数据仍保留在 /data/harbor"
print_info "重新启动: ./start-harbor.sh 或 docker-compose start"