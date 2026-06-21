# Simple Git Workflow

## 📋 分支结构

| 分支 | 用途 | 保护状态 |
|------|------|---------|
| `main` | 生产环境代码 | ✅ 保护分支 |

## 🔄 工作流程

### 开发流程

```bash
# 1. 直接在 main 分支开发
git checkout main
git pull origin main

# 2. 创建功能分支（可选）
git checkout -b feature/new-feature

# 3. 开发并提交代码
git add .
git commit -m "feat: add new feature"

# 4. 推送到远程
git push origin feature/new-feature

# 5. 创建 Pull Request 到 main
# PR 标题格式: feat: description
```

### 直接推送到 main（简单模式）

```bash
# 1. 更新 main 分支
git checkout main
git pull origin main

# 2. 开发并提交
git add .
git commit -m "feat: add new feature"

# 3. 直接推送
git push origin main
```

## 📝 Commit Message 规范

### 格式

```
<type>: <subject>

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
| `main` | `latest`, `sha-xxxxx` | Production |

### 镜像命名

```bash
# 生产环境镜像
ghcr.io/username/isfounder-site:latest
ghcr.io/username/isfounder-site:sha-xxxxx
```

## 📊 CI/CD 流程

### GitHub Actions 自动触发

1. **Push to Main**
   - 自动运行 Lint 和 Type Check
   - 构建 Production 镜像
   - 运行安全扫描
   - 推送到 GitHub Container Registry

2. **Pull Request to Main**
   - 自动运行 Lint 和 Type Check
   - 运行安全扫描

## ✅ Pull Request 检查清单

- [ ] PR 标题符合规范
- [ ] 代码通过 Lint 检查
- [ ] TypeScript 类型检查通过
- [ ] 相关测试通过（如需要）
- [ ] 文档已更新（如需要）
- [ ] 至少 1 个 Review 批准（如需要）
- [ ] 分支已同步最新代码

## 🎯 最佳实践

1. **频繁提交**: 每完成一个小功能就提交
2. **小步提交**: 每个 commit 尽量小且专注
3. **及时同步**: 定期从 main 分支 pull 最新代码
4. **保护主分支**: main 必须受保护
5. **代码质量**: 确保通过所有检查再合并

## 📚 参考资料

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)