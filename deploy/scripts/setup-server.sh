#!/bin/bash

# 阿里云服务器初始化脚本
# 用于在阿里云服务器上安装和配置 Docker、Docker Compose、Harbor 等

set -e

# ==========================================
# 配置参数
# ==========================================

SERVER_IP="${1:-8.156.82.221}"
SERVER_USER="root"

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
# 检查是否在服务器上运行
# ==========================================

print_info "=========================================="
print_info "阿里云服务器初始化脚本"
print_info "=========================================="
echo ""

if [ ! -f "/etc/os-release" ]; then
    print_error "此脚本需要在 Linux 服务器上运行"
    exit 1
fi

print_info "检测到操作系统: $(cat /etc/os-release | grep "^NAME=" | cut -d= -f2)"
echo ""

# ==========================================
# 确认操作
# ==========================================

print_warning "此脚本将执行以下操作:"
echo ""
echo "  1. 安装基础工具 (curl, wget, vim, git)"
echo "  2. 安装 Docker Engine"
echo "  3. 安装 Docker Compose"
echo "  4. 配置 Docker 服务"
echo "  5. 配置防火墙规则"
echo "  6. 创建必要目录"
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
# 更新系统
# ==========================================

print_info "=========================================="
print_info "步骤 1: 更新系统"
print_info "=========================================="
echo ""

print_info "更新软件包..."
if command -v apt-get &> /dev/null; then
    apt-get update -y
    apt-get upgrade -y
elif command -v yum &> /dev/null; then
    yum update -y
    yum upgrade -y
elif command -v dnf &> /dev/null; then
    dnf update -y
    dnf upgrade -y
fi

print_success "系统已更新"
echo ""

# ==========================================
# 安装基础工具
# ==========================================

print_info "=========================================="
print_info "步骤 2: 安装基础工具"
print_info "=========================================="
echo ""

print_info "安装基础工具..."
if command -v apt-get &> /dev/null; then
    apt-get install -y curl wget vim git unzip ca-certificates gnupg lsb-release
elif command -v yum &> /dev/null; then
    yum install -y curl wget vim git unzip ca-certificates
elif command -v dnf &> /dev/null; then
    dnf install -y curl wget vim git unzip ca-certificates
fi

print_success "基础工具已安装"
echo ""

# ==========================================
# 安装 Docker Engine
# ==========================================

print_info "=========================================="
print_info "步骤 3: 安装 Docker Engine"
print_info "=========================================="
echo ""

# 检查 Docker 是否已安装
if command -v docker &> /dev/null; then
    print_warning "Docker 已安装: $(docker --version)"
    read -p "是否跳过 Docker 安装？(y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "跳过 Docker 安装"
    else
        echo ""
        print_info "安装新版本 Docker..."
        
        # 卸载旧版本
        if command -v apt-get &> /dev/null; then
            apt-get remove -y docker docker-engine docker.io containerd runc
        elif command -v yum &> /dev/null; then
            yum remove -y docker docker-common docker-selinux docker-engine-selinux docker-engine
        fi
        
        # 安装新版本
        if command -v apt-get &> /dev/null; then
            # 添加 Docker GPG key
            mkdir -p /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            
            # 添加 Docker 仓库
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            # 安装 Docker
            apt-get update -y
            apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        elif command -v yum &> /dev/null; then
            # 添加 Docker 仓库
            yum install -y yum-utils
            yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            
            # 安装 Docker
            yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        fi
        
        print_success "Docker 已安装"
    fi
else
    print_info "安装 Docker..."
    
    if command -v apt-get &> /dev/null; then
        # 添加 Docker GPG key
        mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        
        # 添加 Docker 仓库
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # 安装 Docker
        apt-get update -y
        apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    elif command -v yum &> /dev/null; then
        # 添加 Docker 仓库
        yum install -y yum-utils
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        
        # 安装 Docker
        yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi
    
    print_success "Docker 已安装"
fi

echo ""

# ==========================================
# 配置 Docker
# ==========================================

print_info "=========================================="
print_info "步骤 4: 配置 Docker"
print_info "=========================================="
echo ""

# 配置 Docker daemon
print_info "配置 Docker daemon..."
mkdir -p /etc/docker

cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "insecure-registries": ["${SERVER_IP}"]
}
EOF

print_success "Docker daemon 已配置"
echo ""

# 启动 Docker
print_info "启动 Docker 服务..."
systemctl enable docker
systemctl start docker

# 验证 Docker
print_info "验证 Docker 安装..."
if docker --version; then
    print_success "Docker 验证成功"
else
    print_error "Docker 验证失败"
    exit 1
fi

echo ""

# ==========================================
# 安装 Docker Compose
# ==========================================

print_info "=========================================="
print_info "步骤 5: 安装 Docker Compose"
print_info "=========================================="
echo ""

# 检查 Docker Compose
if command -v docker-compose &> /dev/null; then
    print_warning "Docker Compose 已安装: $(docker-compose --version)"
elif docker compose version &> /dev/null; then
    print_warning "Docker Compose (Plugin) 已安装: $(docker compose version)"
else
    print_info "安装 Docker Compose..."
    
    # 下载 Docker Compose
    COMPOSE_VERSION="v2.20.0"
    curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    
    # 添加执行权限
    chmod +x /usr/local/bin/docker-compose
    
    # 创建符号链接
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    print_success "Docker Compose 已安装"
fi

echo ""

# ==========================================
# 配置防火墙
# ==========================================

print_info "=========================================="
print_info "步骤 6: 配置防火墙"
print_info "=========================================="
echo ""

# 检查防火墙类型
if command -v ufw &> /dev/null; then
    print_info "检测到 UFW 防火墙"
    
    print_info "开放必要端口..."
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 3000/tcp
    
    # 启用防火墙
    echo "y" | ufw enable
    
    print_success "UFW 防火墙已配置"
    
elif command -v firewall-cmd &> /dev/null; then
    print_info "检测到 firewalld"
    
    print_info "开放必要端口..."
    firewall-cmd --permanent --add-port=22/tcp
    firewall-cmd --permanent --add-port=80/tcp
    firewall-cmd --permanent --add-port=443/tcp
    firewall-cmd --permanent --add-port=3000/tcp
    firewall-cmd --reload
    
    print_success "firewalld 已配置"
    
else
    print_warning "未检测到防火墙，将使用 iptables"
    
    # 检查 iptables
    if ! command -v iptables &> /dev/null; then
        print_info "安装 iptables..."
        if command -v apt-get &> /dev/null; then
            apt-get install -y iptables iptables-persistent
        fi
    fi
    
    # 添加规则
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
    
    print_success "iptables 已配置"
fi

echo ""

# ==========================================
# 创建目录
# ==========================================

print_info "=========================================="
print_info "步骤 7: 创建必要目录"
print_info "=========================================="
echo ""

print_info "创建 Harbor 目录..."
mkdir -p /opt/harbor
mkdir -p /data/harbor
mkdir -p /var/log/harbor

print_success "目录已创建"
echo ""

# ==========================================
# 阿里云安全组配置说明
# ==========================================

print_info "=========================================="
print_warning "阿里云安全组配置"
print_info "=========================================="
echo ""

print_info "请在阿里云控制台配置安全组规则:"
echo ""
echo "  1. 登录阿里云控制台"
echo "  2. 进入 ECS 实例"
echo "  3. 点击 '安全组'"
echo "  4. 添加以下入方向规则:"
echo ""
echo "     端口范围     | 授权对象"
echo "     ------------|------------"
echo "     22/TCP       | 0.0.0.0/0   (SSH)"
echo "     80/TCP       | 0.0.0.0/0   (HTTP)"
echo "     443/TCP      | 0.0.0.0/0   (HTTPS)"
echo "     3000/TCP     | 0.0.0.0/0   (Web)"
echo ""
print_warning "注意: 生产环境建议限制 SSH 访问来源 IP"
echo ""

# ==========================================
# 配置完成
# ==========================================

print_info "=========================================="
print_success "服务器初始化完成！"
print_info "=========================================="
echo ""

print_info "验证结果:"
echo ""
echo "  Docker 版本:        $(docker --version)"
echo "  Docker Compose:     $(docker-compose --version 2>/dev/null || docker compose version)"
echo "  服务器 IP:          $SERVER_IP"
echo ""
echo "  开放端口:"
echo "    - 22 (SSH)"
echo "    - 80 (HTTP)"
echo "    - 443 (HTTPS)"
echo "    - 3000 (Web)"
echo ""
echo "  目录:"
echo "    - /opt/harbor"
echo "    - /data/harbor"
echo "    - /var/log/harbor"
echo ""

print_info "下一步操作:"
echo ""
echo "  1. 上传 Harbor 配置:"
echo "     scp -r registry/* root@${SERVER_IP}:/opt/harbor/"
echo ""
echo "  2. 连接到服务器:"
echo "     ssh root@${SERVER_IP}"
echo ""
echo "  3. 安装 Harbor:"
echo "     cd /opt/harbor"
echo "     ./scripts/install-harbor.sh"
echo ""
echo "  4. 访问 Harbor:"
echo "     http://${SERVER_IP}"
echo ""

print_success "服务器初始化成功！"