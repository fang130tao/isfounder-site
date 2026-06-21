# ========================================
# Makefile for DevOps Operations
# Next.js + Docker + GitFlow
# ========================================

# Variables
APP_NAME := artistry-site
REGISTRY := ghcr.io
IMAGE_NAME := $(REGISTRY)/$(GITHUB_USER)/$(APP_NAME)
GITHUB_USER ?= your-github-username

# Docker targets
.PHONY: docker-build docker-build-dev docker-build-prod docker-run docker-run-dev docker-stop docker-clean docker-push docker-push-latest

# Git targets
.PHONY: git-start-feature git-finish-feature git-start-release git-finish-release git-start-hotfix git-finish-hotfix

# Development targets
.PHONY: dev install test lint build

# ========================================
# Development Commands
# ========================================

dev:
	npm run dev

install:
	npm install

test:
	npm test

lint:
	npm run lint

build:
	npm run build

# ========================================
# Docker Commands
# ========================================

# Build development image
docker-build-dev:
	docker build --target dev -t $(APP_NAME):dev .

# Build production image
docker-build:
	docker build --target builder -t $(APP_NAME):builder .
	docker build --target runner -t $(APP_NAME):latest .

# Build with custom tag
docker-build-tag:
	docker build --target runner -t $(IMAGE_NAME):$(TAG) .

# Run development container
docker-run-dev:
	docker run -d --name $(APP_NAME)-dev \
		-p 3000:3000 \
		-v $(PWD):/app \
		--restart unless-stopped \
		$(APP_NAME):dev

# Run production container
docker-run:
	docker run -d --name $(APP_NAME) \
		-p 3000:3000 \
		--restart unless-stopped \
		--health-cmd="wget --no-verbose --tries=1 --spider http://localhost:3000 || exit 1" \
		--health-interval=30s \
		--health-timeout=10s \
		--health-retries=3 \
		$(APP_NAME):latest

# Stop containers
docker-stop:
	docker stop $(APP_NAME) $(APP_NAME)-dev 2>/dev/null || true
	docker rm $(APP_NAME) $(APP_NAME)-dev 2>/dev/null || true

# Clean Docker resources
docker-clean:
	docker stop $$(docker ps -aq --filter name=$(APP_NAME)) 2>/dev/null || true
	docker rm $$(docker ps -aq --filter name=$(APP_NAME)) 2>/dev/null || true
	docker rmi $$(docker images -q $(APP_NAME)) 2>/dev/null || true
	docker system prune -f

# Push image to registry
docker-push:
	docker push $(IMAGE_NAME):$(TAG)

# Push latest to registry
docker-push-latest:
	docker tag $(APP_NAME):latest $(IMAGE_NAME):latest
	docker push $(IMAGE_NAME):latest

# ========================================
# GitFlow Commands
# ========================================

# Start a new feature
git-start-feature:
ifndef FEATURE_NAME
	$(error FEATURE_NAME is undefined. Usage: make git-start-feature FEATURE_NAME=my-feature)
endif
	git checkout develop
	git pull origin develop
	git checkout -b feature/$(FEATURE_NAME)
	@echo "Created feature branch: feature/$(FEATURE_NAME)"
	@echo "Now you can start developing..."

# Finish and merge feature
git-finish-feature:
ifndef FEATURE_NAME
	$(error FEATURE_NAME is undefined. Usage: make git-finish-feature FEATURE_NAME=my-feature)
endif
	@echo "Finishing feature/$(FEATURE_NAME)..."
	git checkout develop
	git pull origin develop
	git merge feature/$(FEATURE_NAME) --no-ff
	git push origin develop
	git branch -d feature/$(FEATURE_NAME)
	git push origin --delete feature/$(FEATURE_NAME)
	@echo "Feature merged and branch deleted!"

# Start a new release
git-start-release:
ifndef VERSION
	$(error VERSION is undefined. Usage: make git-start-release VERSION=1.0.0)
endif
	git checkout develop
	git pull origin develop
	git checkout -b release/v$(VERSION)
	@echo "Created release branch: release/v$(VERSION)"

# Finish release
git-finish-release:
ifndef VERSION
	$(error VERSION is undefined. Usage: make git-finish-release VERSION=1.0.0)
endif
	@echo "Finishing release/v$(VERSION)..."
	git checkout main
	git pull origin main
	git merge release/v$(VERSION) --no-ff
	git tag -a v$(VERSION) -m "Release v$(VERSION)"
	git push origin main
	git push origin main --tags
	git checkout develop
	git merge release/v$(VERSION) --no-ff
	git push origin develop
	git branch -d release/v$(VERSION)
	git push origin --delete release/v$(VERSION)
	@echo "Release v$(VERSION) completed!"

# Start hotfix
git-start-hotfix:
ifndef HOTFIX_NAME
	$(error HOTFIX_NAME is undefined. Usage: make git-start-hotfix HOTFIX_NAME=urgent-fix)
endif
	git checkout main
	git pull origin main
	git checkout -b hotfix/$(HOTFIX_NAME)
	@echo "Created hotfix branch: hotfix/$(HOTFIX_NAME)"

# Finish hotfix
git-finish-hotfix:
ifndef HOTFIX_NAME
	$(error HOTFIX_NAME is undefined. Usage: make git-finish-hotfix HOTFIX_NAME=urgent-fix)
endif
	@echo "Finishing hotfix/$(HOTFIX_NAME)..."
	git checkout main
	git pull origin main
	git merge hotfix/$(HOTFIX_NAME) --no-ff
	git push origin main
	git checkout develop
	git merge hotfix/$(HOTFIX_NAME) --no-ff
	git push origin develop
	git branch -d hotfix/$(HOTFIX_NAME)
	git push origin --delete hotfix/$(HOTFIX_NAME)
	@echo "Hotfix completed!"

# ========================================
# Docker Compose Commands
# ========================================

.PHONY: dc-up dc-down dc-logs dc-restart

dc-up:
	docker-compose up -d

dc-down:
	docker-compose down

dc-logs:
	docker-compose logs -f

dc-restart:
	docker-compose restart

# ========================================
# Utility Commands
# ========================================

# Show help
help:
	@echo "Available commands:"
	@echo ""
	@echo "Development:"
	@echo "  make dev          - Start development server"
	@echo "  make install      - Install dependencies"
	@echo "  make test         - Run tests"
	@echo "  make lint         - Run linter"
	@echo "  make build        - Build for production"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-build        - Build production image"
	@echo "  make docker-build-dev    - Build development image"
	@echo "  make docker-run          - Run production container"
	@echo "  make docker-run-dev      - Run development container"
	@echo "  make docker-stop         - Stop containers"
	@echo "  make docker-clean        - Clean Docker resources"
	@echo ""
	@echo "GitFlow:"
	@echo "  make git-start-feature FEATURE_NAME=xxx    - Start feature branch"
	@echo "  make git-finish-feature FEATURE_NAME=xxx   - Finish feature branch"
	@echo "  make git-start-release VERSION=1.0.0        - Start release branch"
	@echo "  make git-finish-release VERSION=1.0.0      - Finish release branch"
	@echo "  make git-start-hotfix HOTFIX_NAME=xxx      - Start hotfix branch"
	@echo "  make git-finish-hotfix HOTFIX_NAME=xxx     - Finish hotfix branch"
	@echo ""
	@echo "Docker Compose:"
	@echo "  make dc-up         - Start docker-compose"
	@echo "  make dc-down       - Stop docker-compose"
	@echo "  make dc-logs       - View logs"
	@echo "  make dc-restart    - Restart containers"
	@echo ""
	@echo "Examples:"
	@echo "  make git-start-feature FEATURE_NAME=artwork-carousel"
	@echo "  make git-start-release VERSION=1.0.0"
	@echo "  make docker-build-tag TAG=v1.0.0"
