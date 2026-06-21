#!/bin/bash

# Harbor 备份脚本

set -e

# ==========================================
# 配置参数
# ==========================================

HARBOR_DIR="/opt/harbor/harbor"
DATA_DIR="/data/harbor"
BACKUP_BASE="/data/harbor-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="${BACKUP_BASE}/harbor_backup_${TIMESTAMP}"

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
# 检查环境
# ==========================================

print_info "=========================================="
print_info "Harbor 备份脚本"
print_info "=========================================="
echo ""

# 检查 Harbor 目录
if [ ! -d "$HARBOR_DIR" ]; then
    print_error "Harbor 目录不存在: $HARBOR_DIR"
    exit 1
fi

# 检查数据目录
if [ ! -d "$DATA_DIR" ]; then
    print_error "Harbor 数据目录不存在: $DATA_DIR"
    exit 1
fi

# ==========================================
# 创建备份目录
# ==========================================

print_info "=========================================="
print_info "创建备份目录"
print_info "=========================================="
echo ""

print_info "备份路径: $BACKUP_PATH"
mkdir -p $BACKUP_PATH

print_success "备份目录已创建"
echo ""

# ==========================================
# 备份配置文件
# ==========================================

print_info "=========================================="
print_info "备份配置文件"
print_info "=========================================="
echo ""

cd $HARBOR_DIR

print_info "备份 harbor.yml..."
cp harbor.yml $BACKUP_PATH/

print_info "备份 docker-compose.yml..."
cp docker-compose.yml $BACKUP_PATH/

print_info "备份其他配置..."
cp -r common $BACKUP_PATH/ 2>/dev/null || true

print_success "配置文件已备份"
echo ""

# ==========================================
# 备份数据库
# ==========================================

print_info "=========================================="
print_info "备份数据库"
print_info "=========================================="
echo ""

print_info "导出数据库..."
docker-compose exec -T harbor-db mysqldump -u root -pHarborDB12345 registry > $BACKUP_PATH/harbor_db.sql 2>/dev/null

if [ -f "$BACKUP_PATH/harbor_db.sql" ]; then
    print_success "数据库已备份"
    print_info "大小: $(du -h $BACKUP_PATH/harbor_db.sql | cut -f1)"
else
    print_warning "数据库备份失败，继续备份其他数据"
fi

echo ""

# ==========================================
# 备份镜像数据（可选）
# ==========================================

print_info "=========================================="
print_info "备份镜像数据"
print_info "=========================================="
echo ""

print_warning "镜像数据可能很大，建议使用 rsync 或定期备份"
echo ""

print_info "镜像数据位置: $DATA_DIR"
print_info "大小: $(du -sh $DATA_DIR | cut -f1)"
echo ""

read -p "是否备份镜像数据？(y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "开始备份镜像数据..."
    print_warning "这可能需要很长时间..."
    
    rsync -av --progress $DATA_DIR $BACKUP_PATH/harbor_data
    
    print_success "镜像数据已备份"
else
    print_info "跳过镜像数据备份"
fi

echo ""

# ==========================================
# 创建备份信息文件
# ==========================================

print_info "=========================================="
print_info "创建备份信息文件"
print_info "=========================================="
echo ""

print_info "创建备份信息..."
cat > $BACKUP_PATH/backup_info.txt <<EOF
Harbor 备份信息
================

备份时间: $(date)
备份路径: $BACKUP_PATH
Harbor 版本: $(curl -s http://8.156.82.221/api/v2.0/systeminfo | grep "harbor_version" || echo "Unknown")

备份内容:
- harbor.yml (配置文件)
- docker-compose.yml (Docker Compose 配置)
- common/ (其他配置)
- harbor_db.sql (数据库备份)
- harbor_data/ (镜像数据，可选)

恢复方法:
1. 停止 Harbor: docker-compose down
2. 恢复配置: cp harbor.yml docker-compose.yml $HARBOR_DIR/
3. 恢复数据库: docker-compose exec -T harbor-db mysql -u root -pHarborDB12345 registry < harbor_db.sql
4. 恢复数据: rsync -av harbor_data/ $DATA_DIR/
5. 重启 Harbor: docker-compose up -d

注意事项:
- 数据库密码需要与配置文件一致
- 镜像数据恢复可能需要很长时间
- 建议定期备份（每周或每月）
EOF

print_success "备份信息已创建"
echo ""

# ==========================================
# 备份总结
# ==========================================

print_info "=========================================="
print_info "备份总结"
print_info "=========================================="
echo ""

print_info "备份位置: $BACKUP_PATH"
print_info "备份大小: $(du -sh $BACKUP_PATH | cut -f1)"
echo ""

print_info "备份内容:"
ls -lh $BACKUP_PATH

echo ""

# ==========================================
# 清理旧备份（可选）
# ==========================================

print_info "=========================================="
print_info "清理旧备份"
print_info "=========================================="
echo ""

print_info "现有备份数量: $(ls -1 $BACKUP_BASE | wc -l)"
print_warning "建议保留最近 3-5 个备份"
echo ""

read -p "是否清理旧备份？(y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "保留最近 5 个备份..."
    
    cd $BACKUP_BASE
    ls -1t | tail -n +6 | xargs rm -rf
    
    print_success "旧备份已清理"
    print_info "剩余备份: $(ls -1 $BACKUP_BASE | wc -l)"
else
    print_info "保留所有备份"
fi

echo ""

# ==========================================
# 完成
# ==========================================

print_info "=========================================="
print_success "Harbor 备份完成！"
print_info "=========================================="
echo ""

print_info "备份位置: $BACKUP_PATH"
print_info "备份信息: $BACKUP_PATH/backup_info.txt"
echo ""

print_warning "建议:"
echo "  1. 定期备份（每周或每月）"
echo "  2. 将备份复制到其他服务器"
echo "  3. 测试恢复流程"
echo "  4. 监控备份大小"