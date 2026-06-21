# GitFlow Branch Strategy

## 📋 分支结构

### 长期分支 (Long-lived Branches)

| 分支 | 用途 | 保护状态 | 自动部署 |
|------|------|---------|----------|
| `main` | 生产环境代码 | ✅ 保护分支 | ✅ Production |
| `develop` | 开发环境代码 | ✅ 保护分支 | ✅ Development |
| `release/*` | 发布准备分支 | ✅ 保护分支 | ✅ Staging |

### 短期分支 (Short-lived Branches)

| 分支前缀 | 用途 | 合并目标 | 命名示例 |
|---------|------|---------|----------|
| `feature/*` | 新功能开发 | develop | feature/artwork-carousel |
| `hotfix/*` | 生产环境紧急修复 | main + develop | hotfix/login-bug |
| `bugfix/*` | 开发环境问题修复 | develop | bugfix/modal-scroll |

## 🔄 工作流程

### Feature 分支流程

```bash
# 1. 从 develop 创建 feature 分支
git checkout develop
git pull origin develop
git checkout -b feature/new-feature

# 2. 开发并提交代码
git add .
git commit -m "feat: add new feature"

# 3. 推送到远程
git push origin feature/new-feature

# 4. 创建 Pull Request 到 develop
# PR 标题格式: feat: description
```

### Release 分支流程

```bash
# 1. 从 develop 创建 release 分支
git checkout develop
git pull origin develop
git checkout -b release/v1.0.0

# 2. 修复 release 问题并提交
git commit -m "release: prepare v1.0.0"

# 3. 合并到 main
git checkout main
git merge release/v1.0.0 --no-ff
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin main --tags

# 4. 合并回 develop
git checkout develop
git merge release/v1.0.0 --no-ff
git push origin develop

# 5. 删除 release 分支
git branch -d release/v1.0.0
git push origin --delete release/v1.0.0
```

### Hotfix 分支流程

```bash
# 1. 从 main 创建 hotfix 分支
git checkout main
git pull origin main
git checkout -b hotfix/urgent-fix

# 2. 修复并提交
git commit -m "hotfix: fix critical issue"

# 3. 合并到 main 和 develop
git checkout main
git merge hotfix/urgent-fix --no-ff
git push origin main

git checkout develop
git merge hotfix/urgent-fix --no-ff
git push origin develop

# 4. 删除 hotfix 分支
git branch -d hotfix/urgent-fix
git push origin --delete hotfix/urgent-fix
```

## 📝 Commit Message 规范

### 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type 类型

| 类型 | 描述 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(artwork): add carousel component` |
| `fix` | 修复 bug | `fix(modal): resolve scroll issue` |
| `docs` | 文档更新 | `docs: update README` |
| `style` | 代码格式（不影响功能） | `style: format code` |
| `refactor` | 重构（不修复问题或添加功能） | `refactor: simplify logic` |
| `perf` | 性能优化 | `perf: improve loading speed` |
| `test` | 测试相关 | `test: add unit tests` |
| `build` | 构建或依赖更新 | `build: upgrade dependencies` |
| `ci` | CI/CD 配置 | `ci: add GitHub Actions` |
| `chore` | 其他更改 | `chore: update configs` |
| `release` | 发布版本 | `release: v1.0.0` |

### 示例

```bash
# 新功能
git commit -m "feat(hero): add animated gradient text effect

- Implement dynamic gradient animation
- Add hover effects for buttons
- Update responsive styles"

# 修复问题
git commit -m "fix(navbar): resolve scroll background issue

Closes #123"

# 发布版本
git commit -m "release: v1.0.0

- Add artwork portfolio section
- Implement artistic animations
- Configure Docker multi-stage builds"
```

## 🏷️ 版本号规范 (SemVer)

版本格式: `MAJOR.MINOR.PATCH`

- **MAJOR**: 不兼容的 API 变更
- **MINOR**: 向后兼容的功能新增
- **PATCH**: 向后兼容的问题修复

示例: `v1.2.3`

## 🚀 自动构建镜像标签

### 分支对应镜像标签

| 分支 | 镜像标签 | 环境 |
|------|---------|------|
| `main` | `latest`, `v1.x.x` | Production |
| `release/*` | `staging`, `v1.x.x-rc` | Staging |
| `develop` | `dev` | Development |
| `feature/*` | `feature-{branch-name}` | Preview |

### 镜像命名

```bash
# 生产环境镜像
ghcr.io/username/isfounder-site:latest
ghcr.io/username/isfounder-site:v1.0.0

# 开发环境镜像
ghcr.io/username/isfounder-site:dev

# Staging 环境镜像
ghcr.io/username/isfounder-site:staging

# Feature 分支镜像
ghcr.io/username/isfounder-site:feature-artwork-carousel
```

## 📊 CI/CD 流程

### GitHub Actions 自动触发

1. **Push to Feature Branch**
   - 自动运行 Lint 和 Type Check
   - 构建 Preview 镜像
   - 运行安全扫描

2. **Merge to Develop**
   - 自动构建 Development 镜像
   - 部署到开发环境

3. **Create Release Branch**
   - 自动构建 Staging 镜像
   - 部署到预发布环境

4. **Merge to Main**
   - 构建 Production 镜像
   - 自动打版本标签
   - 部署到生产环境

## ✅ Pull Request 检查清单

- [ ] PR 标题符合规范
- [ ] 代码通过 Lint 检查
- [ ] TypeScript 类型检查通过
- [ ] 相关测试通过
- [ ] 文档已更新（如需要）
- [ ] 至少 1 个 Review 批准
- [ ] 分支已同步最新代码

## 🎯 最佳实践

1. **频繁集成**: 每天至少 push 一次到 feature 分支
2. **小步提交**: 每个 commit 尽量小且专注
3. **及时 Code Review**: PR 创建后尽快 review
4. **保持分支同步**: 定期从目标分支 pull 最新代码
5. **删除无用分支**: PR 合并后及时删除远程分支
6. **保护关键分支**: main 和 develop 必须受保护

## 📚 参考资料

- [GitFlow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
