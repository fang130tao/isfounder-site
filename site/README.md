# Artistry Site - 网站源代码

一个富有艺术感的现代化网站，基于 Next.js + React + TypeScript 构建，使用 Framer Motion 实现丰富的动画效果。

## 🎨 设计特色

### 艺术化视觉风格
- **渐变色彩**: 紫色、粉色、蓝色的艺术渐变
- **流动形状**: 动态流动的渐变圆形背景
- **艺术线条**: 水平装饰线条增添层次感
- **圆形装饰**: 旋转出现的边框圆形

### 品牌定位
- **Logo**: "ARTISTRY" - 艺术、创意的代名词
- **导航**: 探索、作品、关于、联系
- **整体调性**: 数字艺术的无限可能

## 📁 项目结构

```
site/
├── src/                # 源代码
│   └ app/             # Next.js App Router
│       ├── globals.css    # 全局样式
│       ├── layout.tsx     # 根布局
│       └ page.tsx         # 首页组件
├── public/             # 静态资源
│   ├── .gitkeep          # 保持目录
│   └ index.html          # 占位符页面
├── .github/            # GitHub 配置
│   ├── workflows/        # GitHub Actions
│       └ ci-cd.yml         # CI/CD 配置
│   ├── GITFLOW.md        # Git 工作流文档
│   └ branch-protection.yml # 分支保护规则
├── scripts/            # 管理脚本
│   ├── cleanup-branches.sh  # 分支清理
│   ├── deploy.sh            # 部署脚本
│   └ gitflow-setup.sh       # GitFlow 初始化
├── .next/              # Next.js 构建输出
├── Dockerfile          # Docker 构建文件
├── docker-compose.yml  # Docker Compose 配置
├── package.json        # 项目依赖
├── next.config.js      # Next.js 配置
├── tsconfig.json       # TypeScript 配置
├── tailwind.config.ts  # Tailwind CSS 配置
├── postcss.config.js   # PostCSS 配置
├── .eslintrc.json      # ESLint 配置
├── .gitignore          # Git 忽略文件
├── .dockerignore       # Docker 忽略文件
├── next-env.d.ts       # Next.js TypeScript 声明
├── Makefile            # Make 命令
└ DEPLOYMENT.md         # 部署文档
└ README.md             # 本文档
```

## 🚀 快速开始

### 本地开发

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 访问网站
# http://localhost:3000
```

### 生产构建

```bash
# 构建
npm run build

# 启动生产服务器
npm run start
```

### Docker 部署

```bash
# 构建镜像
docker build --target runner -t artistry-site:latest .

# 运行容器
docker run -d -p 3000:3000 --name artistry-site artistry-site:latest

# 访问网站
# http://localhost:3000
```

## 📦 技术栈

### 核心框架
- **Next.js**: 14.2.0 (App Router)
- **React**: 18.2.0
- **TypeScript**: 5.x

### 样式和动画
- **Tailwind CSS**: 3.3.0
- **Framer Motion**: 11.0.0
- **PostCSS**: 8.x
- **Autoprefixer**: 10.0.1

### 开发工具
- **ESLint**: 8.x
- **Docker**: Multi-stage 构建
- **GitHub Actions**: CI/CD 自动化

## 🎨 页面组件

### Hero 区域
- 大标题"创意无界限"
- 艺术化渐变文字效果
- CTA 按钮"开始探索"、"查看作品"

### 作品展示
- 6个艺术作品卡片
- 数字梦境、星际探索、抽象之美等
- 悬停动画效果

### 艺术理念
- 引用文字区域
- "艺术是灵魂的表达"

### CTA 区域
- "开始创作"行动号召
- 渐变按钮效果

## 🔄 动画效果

### Framer Motion 动画

**背景动画**:
- 流动形状的缩放、旋转、移动
- 艺术线条的渐显动画
- 圆形装饰的旋转出现

**交互动画**:
- 卡片悬停上浮和边框高亮
- 渐变文字的动态背景位置
- 滚动触发的淡入效果

**页面动画**:
- 元素淡入上升
- 视口进入触发
- 平滑过渡效果

## 📝 开发命令

### NPM Scripts

```bash
npm run dev       # 开发服务器
npm run build     # 生产构建
npm run start     # 生产服务器
npm run lint      # ESLint 检查
npm run type-check # TypeScript 类型检查
```

### Makefile 命令

```bash
make dev          # 开发服务器
make build        # 生产构建
make lint         # Lint 检查
make docker-build # Docker 构建
make docker-run   # Docker 运行
make dc-up        # Docker Compose 启动
make dc-down      # Docker Compose 停止
```

## 🐳 Docker 配置

### Multi-stage Dockerfile

**5 个构建阶段**:
1. `base`: 基础镜像 (Node.js 22 Alpine)
2. `dev`: 开发环境
3. `deps`: 依赖安装
4. `builder`: 应用构建
5. `runner`: 生产运行

**特性**:
- 非 root 用户安全配置
- 健康检查配置
- Standalone 模式
- 静态资源优化

### Docker Compose

**服务配置**:
- Production: 端口 3000
- Staging: 端口 3001（可选）
- Development: 端口 3002（可选）

## 🔄 CI/CD 配置

### GitHub Actions Workflow

**触发条件**:
- Push to `main` 分支
- Pull Request to `main` 分支

**构建步骤**:
1. Lint & Type Check
2. Build Production Image
3. Push to Harbor Registry
4. Security Scan

**镜像标签**:
- `latest` - 最新版本
- `v1.2.3` - 完整版本号
- `v1.2` - 主版本.次版本
- `v1` - 主版本

## 📊 性能优化

### Next.js 优化
- App Router 架构
- Server Components
- 自动代码分割
- 图片优化

### Docker 优化
- Multi-stage 构建
- 层缓存优化
- 最小化镜像大小
- 健康检查

### CSS 优化
- Tailwind CSS JIT
- PostCSS 优化
- Autoprefixer
- 最小化 CSS

## 🔧 配置文件

### Next.js 配置

```javascript
// next.config.js
module.exports = {
  output: 'standalone',  // Docker standalone 模式
};
```

### TypeScript 配置

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "es2015"],
    "strict": true,
    "noEmit": true
  }
}
```

### Tailwind CSS 配置

```typescript
// tailwind.config.ts
module.exports = {
  content: ['./src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: '#8B5CF6',
        secondary: '#EC4899'
      }
    }
  }
}
```

## 🎯 Git 工作流

### 简化 GitFlow

**分支结构**:
- `main` - 唯一分支（生产环境）

**工作流程**:
```
开发 → 提交 → 推送 → 自动构建
```

**Commit 规范**:
- `feat`: 新功能
- `fix`: 修复 bug
- `docs`: 文档更新
- `style`: 代码格式
- `refactor`: 重构
- `chore`: 其他更改

## 📚 相关文档

- [部署指南](DEPLOYMENT.md)
- [Git 工作流](../.github/GITFLOW.md)
- [项目总览](../README.md)
- [部署配置](../deploy/README.md)

## 🛠️ 故障排查

### 开发环境问题

**依赖安装失败**:
```bash
# 清理缓存
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

**端口占用**:
```bash
# 查看端口占用
lsof -i :3000

# 杀掉进程
kill -9 <PID>
```

### Docker 问题

**构建失败**:
```bash
# 查看日志
docker logs <container-id>

# 清理缓存
docker system prune -a
```

**容器无法启动**:
```bash
# 检查状态
docker ps -a

# 重启容器
docker restart <container-id>
```

## 📞 支持

如有问题，请查看：
- GitHub Issues: https://github.com/fang130tao/isfounder-site/issues
- 部署文档: [DEPLOYMENT.md](DEPLOYMENT.md)
- 项目文档: [../docs/](../docs/)

## 📄 License

MIT License

---

**创建日期**: 2026-06-20
**最后更新**: 2026-06-20
**维护者**: Fang Tao