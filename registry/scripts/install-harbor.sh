#!/bin/bash

# Harbor 安装脚本
# 用于在阿里云服务器上安装 Harbor 镜像服务器

set -e

# ==========================================
# 配置参数
# ==========================================

HARBOR_VERSION="v2.10.0"
HARBOR_PACKAGE="harbor-offline-installer-${HARBOR_VERSION}.tgz"
HARBOR_DIR="/opt/harbor"
CONFIG_FILE="../config/harbor.yml"
SERVER_IP="8.156.82.221"

# ==========================================
# 颜色输出
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
# 检查环境
# ==========================================

print_info "=========================================="
print_info "Harbor 安装脚本"
print_info "=========================================="
echo ""

# 检查是否在服务器上运行
print_info "检查运行环境..."
if [ ! -f "/etc/os-release" ]; then
    print_error "此脚本需要在 Linux 服务器上运行"
    print_info "请先上传配置文件到服务器，然后在服务器上执行此脚本"
    exit 1
fi

# 检查 Docker
print_info "检查 Docker..."
if ! command -v docker &> /dev/null; then
    print_error "Docker 未安装"
    print_info "请先运行服务器初始化脚本: deploy/scripts/setup-server.sh"
    exit 1
fi

# 检查 Docker Compose
print_info "检查 Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose 未安装"
    print_info "请先运行服务器初始化脚本: deploy/scripts/setup-server.sh"
    exit 1
fi

print_success "环境检查通过"
echo ""

# ==========================================
# 检查 Harbor 安装包
# ==========================================

print_info "=========================================="
print_info "检查 Harbor 安装包"
print_info "=========================================="
echo ""

if [ ! -f "../harbor/${HARBOR_PACKAGE}" ]; then
    print_error "Harbor 安装包不存在: ../harbor/${HARBOR_PACKAGE}"
    print_info "请先下载 Harbor 安装包"
    print_info "运行下载脚本: ./download-harbor.sh"
    echo ""
    print_info "或手动下载:"
    print_info "wget https://github.com/goharbor/harbor/releases/download/${HARBOR_VERSION}/${HARBOR_PACKAGE}"
    exit 1
fi

print_success "Harbor 安装包已找到"
echo ""

# ==========================================
# 解压安装包
# ==========================================

print_info "=========================================="
print_info "解压 Harbor 安装包"
print_info "=========================================="
echo ""

cd ../harbor

if [ -d "harbor" ]; then
    print_warning "harbor 目录已存在，跳过解压"
else
    print_info "解压安装包..."
    tar xzvf ${HARBOR_PACKAGE}
    print_success "解压完成"
fi

echo ""

# ==========================================
# 配置 Harbor
# ==========================================

print_info "=========================================="
print_info "配置 Harbor"
print_info "=========================================="
echo ""

cd harbor

# 复制配置文件
if [ -f "../../config/harbor.yml" ]; then
    print_info "复制配置文件..."
    cp ../../config/harbor.yml harbor.yml
    print_success "配置文件已复制"
else
    print_warning "配置文件不存在，使用模板"
    if [ -f "harbor.yml.tmpl" ]; then
        cp harbor.yml.tmpl harbor.yml
        print_info "请编辑 harbor.yml 配置文件"
        print_info "vim harbor.yml"
    else
        print_error "配置模板不存在"
        exit 1
    fi
fi

echo ""

# ==========================================
# 创建数据目录
# ==========================================

print_info "=========================================="
print_info "创建数据目录"
print_info "=========================================="
echo ""

DATA_VOLUME="/data/harbor"

if [ ! -d "$DATA_VOLUME" ]; then
    print_info "创建数据目录: $DATA_VOLUME"
    mkdir -p $DATA_VOLUME
    print_success "数据目录已创建"
else
    print_warning "数据目录已存在: $DATA_VOLUME"
fi

echo ""

# ==========================================
# 运行 prepare 脚本
# ==========================================

print_info "=========================================="
print_info "运行 prepare 脚本"
print_info "=========================================="
echo ""

if [ ! -f "prepare" ]; then
    print_error "prepare 脚本不存在"
    exit 1
fi

print_info "生成配置..."
./prepare

print_success "配置生成完成"
echo ""

# ==========================================
# 安装 Harbor
# ==========================================

print_info "=========================================="
print_info "安装 Harbor"
print_info "=========================================="
echo ""

if [ ! -f "install.sh" ]; then
    print_error "install.sh 脚本不存在"
    exit 1
fi

print_info "开始安装..."
./install.sh

print_success "Harbor 安装完成"
echo ""

# ==========================================
# 启动 Harbor
# ==========================================

print_info "=========================================="
print_info "启动 Harbor"
print_info "=========================================="
echo ""

print_info "启动服务..."
docker-compose up -d

print_success "Harbor 已启动"
echo ""

# ==========================================
# 验证安装
# ==========================================

print_info "=========================================="
print_info "验证安装"
print_info "=========================================="
echo ""

print_info "检查服务状态..."
docker-compose ps

echo ""

print_info "等待服务启动..."
sleep 10

print_info "检查 API..."
if curl -s http://${SERVER_IP}/api/v2.0/systeminfo | grep -q "harbor_version"; then
    print_success "Harbor API 正常"
else
    print_warning "Harbor API 可能未完全启动，请稍后再试"
fi

echo ""

# ==========================================
# 安装完成
# ==========================================

print_info "=========================================="
print_success "Harbor 安装成功！"
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

print_info "下一步操作:"
echo ""
echo "  1. 访问 Web UI 并修改管理员密码"
echo "  2. 创建项目和用户"
echo "  3. 配置 Docker 客户端"
echo "  4. 测试推送和拉取镜像"
echo ""

print_warning "安全提醒:"
echo ""
echo "  ⚠️  请立即修改管理员密码"
echo "  ⚠️  生产环境建议启用 HTTPS"
echo "  ⚠️  配置防火墙规则"
echo "  ⚠️  定期备份数据"
echo ""

print_info "管理命令:"
echo ""
echo "  启动:   docker-compose start"
echo "  停止:   docker-compose stop"
echo "  重启:   docker-compose restart"
echo "  状态:   docker-compose ps"
echo "  日志:   docker-compose logs"
echo ""

print_success "安装完成！"