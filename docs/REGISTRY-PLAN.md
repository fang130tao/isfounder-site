# 阿里云镜像服务器规划方案

## 📋 项目概述

**目标**: 在阿里云服务器（8.156.82.221）上部署 Harbor 镜像服务器，实现镜像的统一管理和可视化查看。

**方案**: Harbor（企业级 Docker Registry）+ 统一目录管理

---

## 📁 目录结构规划

### 当前目录重组方案

```
/Users/fang-tao/Desktop/code/isfounder-site/
├── registry/                    # Harbor 镜像服务器配置
│   ├── harbor/                  # Harbor 安装包
│   │   ├── docker-compose.yml
│   │   ├── harbor.yml.tmpl
│   │   └── prepare
│   │   └── install.sh
│   ├── certs/                   # SSL 证书（可选）
│   │   ├── registry.crt
│   │   └ registry.key
│   ├── config/                  # Harbor 配置文件
│   │   ├── harbor.yml           # 主配置文件
│   │   └── docker-compose.yml   # Docker Compose 配置
│   ├── scripts/                 # Harbor 管理脚本
│   │   ├── install-harbor.sh    # 安装脚本
│   │   ├── start-harbor.sh      # 启动脚本
│   │   ├── stop-harbor.sh       # 停止脚本
│   │   ├── update-harbor.sh     # 更新脚本
│   │   └ backup-harbor.sh       # 备份脚本
│   └ data/                      # Harbor 数据目录（服务器上）
│   └── README.md                # Harbor 使用文档
│
├── site/                        # 网站代码（当前内容）
│   ├── src/                     # 源代码
│   │   └ app/
│   ├── public/                  # 静态资源
│   ├── .github/                 # GitHub 配置
│   ├── Dockerfile               # 网站镜像构建文件
│   ├── docker-compose.yml       # 网站部署配置
│   ├── package.json             # 项目依赖
│   ├── next.config.js           # Next.js 配置
│   ├── tsconfig.json            # TypeScript 配置
│   ├── tailwind.config.ts       # Tailwind 配置
│   └── .eslintrc.json           # ESLint 配置
│
├── deploy/                      # 部署配置和脚本
│   ├── scripts/                 # 部署脚本
│   │   ├── deploy-site.sh       # 网站部署脚本
│   │   ├── deploy-registry.sh   # Registry 部署脚本
│   │   ├── setup-server.sh      # 服务器初始化脚本
│   ├── configs/                 # 部署配置
│   │   ├── nginx.conf           # Nginx 配置（可选）
│   │   ├── docker-daemon.json   # Docker 配置
│   ├── docs/                    # 部署文档
│   │   ├── SERVER-SETUP.md      # 服务器配置文档
│   │   ├── HARBOR-SETUP.md      # Harbor 配置文档
│   │   ├── CI-INTEGRATION.md    # CI/CD 集成文档
│   └── README.md                # 部署总览
│
└── docs/                        # 项目总文档
    ├── README.md                # 项目总览
    ├── ARCHITECTURE.md          # 架构说明
    ├── REGISTRY.md              # Registry 使用指南
    └── MIGRATION.md             # 迁移记录

```

### 目录说明

| 目录 | 用途 | 内容 |
|------|------|------|
| `registry/` | Harbor 镜像服务器 | 安装包、配置、证书、脚本 |
| `site/` | 网站代码 | Next.js 项目、Dockerfile、CI配置 |
| `deploy/` | 部署工具 | 部署脚本、服务器配置、文档 |
| `docs/` | 项目文档 | 总览文档、架构说明、使用指南 |

---

## 🏗️ Harbor 部署方案

### 1. Harbor 架构

```
阿里云服务器 (8.156.82.221)
├── Docker Engine
├── Docker Compose
└── Harbor Components
    ├── Harbor Core (Web UI + API)
    ├── Harbor Portal (前端界面)
    ├── Harbor Registry (镜像存储)
    ├── Harbor DB (PostgreSQL)
    ├── Harbor Redis (缓存)
    ├── Harbor Log (日志收集)
    └── Harbor Chart Museum (Helm Charts)
```

### 2. Harbor 功能

**核心功能**:
- ✅ Web UI 界面（镜像列表、详情查看）
- ✅ 用户权限管理
- ✅ 项目管理（多项目隔离）
- ✅ 镜像标签管理
- ✅ 镜像搜索
- ✅ 镜像复制（可选）
- ✅ 漏洞扫描（可选）

**访问方式**:
- Web UI: `http://8.156.82.221:80` 或 `https://8.156.82.221:443`
- API: `http://8.156.82.221:80/api`
- Docker Push/Pull: `docker push 8.156.82.221/site:latest`

### 3. Harbor 配置参数

| 参数 | 值 | 说明 |
|------|-----|------|
| hostname | `8.156.82.221` | 服务器公网 IP |
| http_port | `80` | HTTP 端口 |
| https_port | `443` | HTTPS 端口（可选） |
| harbor_admin_password | `Harbor12345` | 管理员密码（需修改） |
| data_volume | `/data/harbor` | 数据存储路径 |
| database | `PostgreSQL` | 数据库类型 |

---

## 🚀 实施计划

### Phase 1: 目录重组（本地）

**目标**: 将当前目录重组为新的结构

**步骤**:
1. 创建 `registry/` 目录及子目录
2. 创建 `deploy/` 目录及子目录
3. 创建 `docs/` 目录
4. 将当前文件移动到 `site/` 目录
5. 创建各目录的 README 文档

**预计时间**: 10 分钟

---

### Phase 2: Harbor 部署准备（本地）

**目标**: 准备 Harbor 安装文件和配置

**步骤**:
1. 下载 Harbor 安装包（v2.10.0）
2. 创建 Harbor 配置文件（harbor.yml）
3. 创建安装和管理脚本
4. 创建 SSL 证书（可选）
5. 创建 Harbor 使用文档

**预计时间**: 15 分钟

---

### Phase 3: 阿里云服务器初始化

**目标**: 配置服务器基础环境

**步骤**:
1. 连接到阿里云服务器
2. 安装 Docker Engine
3. 安装 Docker Compose
4. 配置防火墙规则
5. 创建 Harbor 数据目录
6. 配置系统参数

**命令预览**:
```bash
# 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 安装 Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 配置防火墙
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload
```

**预计时间**: 20 分钟

---

### Phase 4: Harbor 安装和配置

**目标**: 在服务器上安装并启动 Harbor

**步骤**:
1. 上传 Harbor 配置文件到服务器
2. 执行 Harbor 安装脚本
3. 启动 Harbor 服务
4. 验证 Harbor 运行状态
5. 创建项目和用户
6. 测试镜像推送和拉取

**命令预览**:
```bash
# 上传配置文件
scp -r registry/harbor root@8.156.82.221:/opt/harbor

# 安装 Harbor
cd /opt/harbor
./install.sh

# 启动 Harbor
docker-compose up -d

# 查看状态
docker-compose ps
```

**预计时间**: 15 分钟

---

### Phase 5: GitHub Actions 集成

**目标**: 配置 CI/CD 推送镜像到 Harbor

**步骤**:
1. 修改 GitHub Actions workflow
2. 配置 Harbor 登录凭据
3. 更新镜像推送目标
4. 测试自动构建和推送

**配置预览**:
```yaml
# .github/workflows/ci-cd.yml
env:
  REGISTRY: 8.156.82.221  # 改为 Harbor 地址
  IMAGE_NAME: site

steps:
  - name: Login to Harbor
    uses: docker/login-action@v3
    with:
      registry: ${{ env.REGISTRY }}
      username: ${{ secrets.HARBOR_USERNAME }}
      password: ${{ secrets.HARBOR_PASSWORD }}
```

**预计时间**: 10 分钟

---

### Phase 6: 测试和验证

**目标**: 验证整个流程

**步骤**:
1. 触发 GitHub Actions 构建
2. 检查镜像是否推送到 Harbor
3. 在 Harbor Web UI 查看镜像列表
4. 测试从 Harbor 拉取镜像
5. 测试部署网站到服务器

**验证清单**:
- ✅ Harbor Web UI 可访问
- ✅ 镜像列表可见
- ✅ GitHub Actions 成功推送
- ✅ 可以拉取镜像部署

**预计时间**: 10 分钟

---

## 📊 总时间预估

| Phase | 时间 | 主要内容 |
|-------|------|---------|
| Phase 1 | 10 分钟 | 目录重组 |
| Phase 2 | 15 分钟 | Harbor 准备 |
| Phase 3 | 20 分钟 | 服务器初始化 |
| Phase 4 | 15 分钟 | Harbor 安装 |
| Phase 5 | 10 分钟 | CI/CD 集成 |
| Phase 6 | 10 分钟 | 测试验证 |
| **总计** | **80 分钟** | 完整部署 |

---

## 🔒 安全建议

### 1. Harbor 安全配置

- 修改默认管理员密码
- 启用 HTTPS（生产环境必须）
- 配置防火墙规则
- 定期备份数据
- 设置用户权限

### 2. 服务器安全

- 禁用 SSH 密码登录（使用密钥）
- 配置防火墙（只开放必要端口）
- 定期更新系统
- 安装安全监控工具

### 3. 镜像安全

- 定期扫描镜像漏洞
- 只推送经过验证的镜像
- 设置镜像保留策略

---

## 💰 成本估算

### 阿里云服务器成本

| 配置 | 月费用 | 说明 |
|------|--------|------|
| 2核4G | ~100元 | Harbor 最低配置 |
| 4核8G | ~200元 | 推荐配置（支持更多镜像） |
| 存储 | ~0.3元/GB | 镜像存储费用 |

### Harbor 存储

- 每个镜像约 200-500MB
- 10个镜像约需 2-5GB
- 建议预留 20GB 存储空间

---

## 📝 后续维护

### 日常维护任务

1. **监控 Harbor 状态**
   ```bash
   docker-compose ps
   docker-compose logs
   ```

2. **清理旧镜像**
   - Harbor UI: 项目 → 镜像 → 删除旧标签
   - 或设置保留策略

3. **备份数据**
   ```bash
   ./scripts/backup-harbor.sh
   ```

4. **更新 Harbor**
   ```bash
   ./scripts/update-harbor.sh
   ```

---

## ✅ 下一步行动

**请确认以下事项**:

1. ✅ 目录结构方案是否满意？
2. ✅ Harbor 部署方案是否清晰？
3. ✅ 实施计划是否可行？
4. ✅ 时间预估是否合理？
5. ✅ 是否有其他需求？

**确认后，我将开始执行 Phase 1: 目录重组**

---

## 📞 技术支持

如有疑问，请随时提出：
- 目录结构调整建议
- Harbor 配置优化
- 服务器配置问题
- CI/CD 集成问题
- 其他技术问题