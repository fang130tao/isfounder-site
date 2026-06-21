#!/bin/bash
# ========================================
# GitFlow Setup Script
# Initialize Git repository with GitFlow
# ========================================

set -e

echo "🚀 Setting up GitFlow for Artistry Site..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}Git is not installed. Please install git first.${NC}"
    exit 1
fi

# Initialize git repository if not already initialized
if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
fi

# Set default branch name to main
git config init.defaultBranch main

# Configure user settings if not set
if [ -z "$(git config user.email)" ]; then
    read -p "Enter your git email: " email
    git config user.email "$email"
fi

if [ -z "$(git config user.name)" ]; then
    read -p "Enter your git name: " name
    git config user.name "$name"
fi

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    cat > .gitignore << 'EOF'
# Dependencies
node_modules
/.pnp
.pnp.js

# Testing
/coverage

# Next.js
/.next/
/out/

# Production
/build

# Misc
.DS_Store
*.pem

# Debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Local env files
.env*.local
.env

# Vercel
.vercel

# TypeScript
*.tsbuildinfo
next-env.d.ts
EOF
    echo "Created .gitignore"
fi

# Create initial commit on main if branch is empty
if [ $(git rev-parse --verify HEAD 2>/dev/null || echo "empty") = "empty" ]; then
    echo "Creating initial commit..."
    git add .
    git commit -m "chore: initial project setup"
fi

# Create develop branch
if ! git show-ref --verify --quiet refs/heads/develop; then
    echo "Creating develop branch..."
    git checkout -b develop
    git checkout main
    echo -e "${GREEN}✅ Created develop branch${NC}"
fi

# Push branches to remote
read -p "Do you want to push branches to remote? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter remote URL (e.g., https://github.com/user/repo.git): " remote_url
    
    if [ ! -z "$remote_url" ]; then
        git remote add origin "$remote_url" 2>/dev/null || git remote set-url origin "$remote_url"
        git push -u origin main
        git push -u origin develop
        echo -e "${GREEN}✅ Pushed branches to remote${NC}"
    fi
fi

# Create GitHub Actions workflow directory
mkdir -p .github/workflows
echo -e "${GREEN}✅ Created .github/workflows directory${NC}"

# Print summary
echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  GitFlow Setup Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo "Branch structure:"
echo "  • main       - Production code"
echo "  • develop    - Development code"
echo ""
echo "Next steps:"
echo "  1. Create feature branches: make git-start-feature FEATURE_NAME=my-feature"
echo "  2. View available commands: make help"
echo "  3. Push to GitHub and enable GitHub Actions"
echo ""
