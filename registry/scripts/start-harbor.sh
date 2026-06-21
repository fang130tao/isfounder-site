#!/bin/bash

# Harbor 启动脚本

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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ==========================================
# 检查 Harbor 目录
# ==========================================

print_info "=========================================="
print_info "Harbor 启动脚本"
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
    print_info "请先运行 prepare 脚本: ./prepare"
    exit 1
fi

# ==========================================
# 启动 Harbor
# ==========================================

print_info "启动 Harbor 服务..."
docker-compose start

print_success "Harbor 已启动"
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

print_success "Harbor 启动成功！"
echo ""
print_info "访问地址: http://8.156.82.221"
print_info "用户名: admin"
print_info "密码: Harbor12345"