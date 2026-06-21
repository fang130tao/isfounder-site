#!/bin/bash

# Harbor 更新脚本

set -e

# ==========================================
# 配置参数
# ==========================================

HARBOR_DIR="/opt/harbor/harbor"
BACKUP_DIR="/data/harbor-backup"
NEW_VERSION="v2.10.0"  # 更新为新版本

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
print_info "Harbor 更新脚本"
print_info "=========================================="
echo ""

if [ ! -d "$HARBOR_DIR" ]; then
    print_error "Harbor 目录不存在: $HARBOR_DIR"
    exit 1
fi

cd $HARBOR_DIR

# ==========================================
# 备份当前配置
# ==========================================

print_info "=========================================="
print_info "备份当前配置"
print_info "=========================================="
echo ""

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="${BACKUP_DIR}/harbor_backup_${TIMESTAMP}"

print_info "创建备份目录: $BACKUP_PATH"
mkdir -p $BACKUP_PATH

print_info "备份配置文件..."
cp harbor.yml $BACKUP_PATH/
cp docker-compose.yml $BACKUP_PATH/ 2>/dev/null || true

print_success "配置已备份到: $BACKUP_PATH"
echo ""

# ==========================================
# 停止 Harbor
# ==========================================

print_info "=========================================="
print_info "停止 Harbor"
print_info "=========================================="
echo ""

print_info "停止服务..."
docker-compose down

print_success "Harbor 已停止"
echo ""

# ==========================================
# 下载新版本（需要手动下载）
# ==========================================

print_info "=========================================="
print_info "下载新版本"
print_info "=========================================="
echo ""

NEW_PACKAGE="harbor-offline-installer-${NEW_VERSION}.tgz"

if [ ! -f "../${NEW_PACKAGE}" ]; then
    print_error "新版本安装包不存在: ../${NEW_PACKAGE}"
    print_info "请先下载新版本安装包"
    print_info "wget https://github.com/goharbor/harbor/releases/download/${NEW_VERSION}/${NEW_PACKAGE}"
    exit 1
fi

print_success "新版本安装包已找到"
echo ""

# ==========================================
# 解压新版本
# ==========================================

print_info "=========================================="
print_info "解压新版本"
print_info "=========================================="
echo ""

cd ..

print_info "解压新版本..."
tar xzvf ${NEW_PACKAGE}

cd harbor

print_success "新版本已解压"
echo ""

# ==========================================
# 恢复配置
# ==========================================

print_info "=========================================="
print_info "恢复配置"
print_info "=========================================="
echo ""

print_info "恢复配置文件..."
cp $BACKUP_PATH/harbor.yml harbor.yml

print_success "配置已恢复"
echo ""

# ==========================================
# 运行 prepare
# ==========================================

print_info "=========================================="
print_info "运行 prepare"
print_info "=========================================="
echo ""

print_info "生成配置..."
./prepare

print_success "配置生成完成"
echo ""

# ==========================================
# 启动新版本
# ==========================================

print_info "=========================================="
print_info "启动新版本"
print_info "=========================================="
echo ""

print_info "启动服务..."
docker-compose up -d

print_success "Harbor 已启动"
echo ""

# ==========================================
# 验证更新
# ==========================================

print_info "=========================================="
print_info "验证更新"
print_info "=========================================="
echo ""

print_info "检查服务状态..."
docker-compose ps

echo ""

print_info "等待服务启动..."
sleep 10

print_info "检查版本..."
if curl -s http://8.156.82.221/api/v2.0/systeminfo | grep -q "harbor_version"; then
    print_success "Harbor 更新成功"
    curl -s http://8.156.82.221/api/v2.0/systeminfo | grep "harbor_version"
else
    print_warning "Harbor 可能未完全启动，请稍后再试"
fi

echo ""

# ==========================================
# 完成
# ==========================================

print_info "=========================================="
print_success "Harbor 更新完成！"
print_info "=========================================="
echo ""

print_info "备份位置: $BACKUP_PATH"
print_info "访问地址: http://8.156.82.221"
echo ""

print_warning "如果遇到问题，可以恢复备份:"
echo "  1. 停止服务: docker-compose down"
echo "  2. 恢复配置: cp $BACKUP_PATH/harbor.yml harbor.yml"
echo "  3. 重新安装: ./prepare && docker-compose up -d"