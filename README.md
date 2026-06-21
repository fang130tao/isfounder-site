# Artistry Site - 艺术化网站项目

一个基于 Next.js + React + TypeScript 的现代化艺术风格网站，包含完整的镜像服务器和部署方案。

## 📁 项目结构

```
isfounder-site/
├── registry/      # Harbor 镜像服务器配置
├── site/          # 网站源代码
├── deploy/        # 部署脚本和配置
├── docs/          # 项目文档
└── README.md      # 本文档
```

## 🚀 快速开始

### 1. 查看网站代码

```bash
cd site/
npm install
npm run dev
# 访问 http://localhost:3000
```

### 2. 部署镜像服务器

```bash
cd deploy/scripts/
./setup-server.sh 8.156.82.221
./deploy-registry.sh 8.156.82.221
```

### 3. 部署网站

```bash
./deploy-site.sh 8.156.82.221
```

## 📝 子项目说明

### registry/ - 镜像服务器

**Harbor 镜像服务器配置**

- Harbor 安装包和配置
- SSL 证书（可选）
- 管理脚本
- 使用文档

**访问地址**: `http://8.156.82.221`

**功能**:
- Web UI 镜像管理
- 用户权限控制
- 项目隔离
- 镜像扫描（可选）

**详细文档**: [registry/README.md](registry/README.md)

---

### site/ - 网站源代码

**Next.js + React + TypeScript 网站**

- 艺术化 UI 设计
- Framer Motion 动画
- Tailwind CSS 样式
- Docker 部署配置
- GitHub Actions CI/CD

**技术栈**:
- Next.js 14
- React 18
- TypeScript 5
- Tailwind CSS 3
- Framer Motion 11

**详细文档**: [site/README.md](site/README.md)

---

### deploy/ - 部署配置

**部署脚本和配置文件**

- 服务器初始化脚本
- Harbor 部署脚本
- 网站部署脚本
- Docker 配置
- Nginx 配置（可选）

**部署流程**:
```
服务器初始化 → Harbor 部署 → 网站部署 → CI/CD 配置
```

**详细文档**: [deploy/README.md](deploy/README.md)

---

### docs/ - 项目文档

**完整的项目文档**

- 镜像服务器规划方案
- 服务器配置指南
- Harbor 配置指南
- CI/CD 集成指南
- 故障排查指南

**详细文档**: [docs/](docs/)

---

## 🌐 访问地址

| 服务 | 地址 | 说明 |
|------|------|------|
| Harbor Web UI | `http://8.156.82.221` | 镜像管理界面 |
| 网站（本地） | `http://localhost:3000` | 本地开发环境 |
| 网站（线上） | `http://8.156.82.221:3000` | 生产环境（待部署） |

## 📦 镜像信息

**镜像地址**: `8.156.82.221/site/isfounder-site:latest`

**镜像标签**:
- `latest` - 最新版本
- `v1.2.3` - 完整版本号
- `v1.2` - 主版本.次版本
- `v1` - 主版本

## 🔧 开发指南

### 本地开发

```bash
cd site/
npm install
npm run dev
```

### 构建镜像

```bash
cd site/
docker build --target runner -t 8.156.82.221/site/isfounder-site:latest .
```

### 推送镜像

```bash
docker login 8.156.82.221
docker push 8.156.82.221/site/isfounder-site:latest
```

## 🔄 CI/CD 流程

### GitHub Actions 自动化

```
代码提交 → GitHub Actions 构建 → 镜像推送到 Harbor → 自动部署
```

**触发条件**:
- Push to `main` 分支
- Pull Request to `main` 分支

**构建步骤**:
1. Lint & Type Check
2. Build Production Image
3. Push to Harbor Registry
4. Security Scan

## 📊 项目状态

| 组件 | 状态 | 进度 |
|------|------|------|
| 网站代码 | ✅ 完成 | 100% |
| Docker 配置 | ✅ 完成 | 100% |
| CI/CD 配置 | ✅ 完成 | 100% |
| Harbor 配置 | 🔄 进行中 | 0% |
| 服务器部署 | ⏳ 待开始 | 0% |

## 🎯 下一步计划

1. ✅ 完成目录重组
2. 🔄 准备 Harbor 配置文件
3. ⏳ 初始化阿里云服务器
4. ⏳ 部署 Harbor 镜像服务器
5. ⏳ 配置 CI/CD 集成
6. ⏳ 测试和验证

## 📚 相关文档

- [镜像服务器规划方案](docs/REGISTRY-PLAN.md)
- [部署指南](deploy/README.md)
- [网站开发指南](site/README.md)
- [Harbor 使用指南](registry/README.md)

## 🛠️ 技术栈

### 网站技术
- **框架**: Next.js 14 (App Router)
- **语言**: TypeScript 5
- **样式**: Tailwind CSS 3
- **动画**: Framer Motion 11
- **容器**: Docker

### 部署技术
- **镜像服务器**: Harbor 2.10
- **容器编排**: Docker Compose
- **CI/CD**: GitHub Actions
- **服务器**: 阿里云 Ubuntu

## 🔒 安全配置

### Harbor 安全
- 修改默认管理员密码
- 启用 HTTPS（生产环境）
- 配置用户权限
- 定期备份数据

### 服务器安全
- SSH 密钥登录
- 防火墙规则
- 定期更新系统
- 监控和日志

## 💰 成本估算

| 项目 | 月费用 | 说明 |
|------|--------|------|
| 阿里云服务器 | ~100-200元 | 2核4G 或 4核8G |
| 存储 | ~0.3元/GB | 镜像存储 |
| 带宽 | ~按流量计费 | 根据访问量 |

**总计**: ~100-300元/月

## 📞 支持

如有问题，请查看：
- 项目文档: `docs/`
- 部署文档: `deploy/docs/`
- Harbor 文档: `registry/README.md`

## 📄 License

MIT License

---

**创建日期**: 2026-06-20
**最后更新**: 2026-06-20
**维护者**: Fang Tao