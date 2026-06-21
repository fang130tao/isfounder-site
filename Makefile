# ========================================
# Makefile for DevOps Operations
# Next.js + Docker + Simple Git Workflow
# ========================================

# Variables
APP_NAME := artistry-site
REGISTRY := ghcr.io
IMAGE_NAME := $(REGISTRY)/$(GITHUB_USER)/$(APP_NAME)
GITHUB_USER ?= your-github-username

# Docker targets
.PHONY: docker-build docker-run docker-stop docker-clean docker-push

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

# Build production image
docker-build:
	docker build --target runner -t $(APP_NAME):latest .

# Build with custom tag
docker-build-tag:
	docker build --target runner -t $(IMAGE_NAME):$(TAG) .

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
	docker stop $(APP_NAME) 2>/dev/null || true
	docker rm $(APP_NAME) 2>/dev/null || true

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
	@echo "  make docker-run          - Run production container"
	@echo "  make docker-stop         - Stop containers"
	@echo "  make docker-clean        - Clean Docker resources"
	@echo "  make docker-build-tag TAG=v1.0.0 - Build with custom tag"
	@echo ""
	@echo "Docker Compose:"
	@echo "  make dc-up         - Start docker-compose"
	@echo "  make dc-down       - Stop docker-compose"
	@echo "  make dc-logs       - View logs"
	@echo "  make dc-restart    - Restart containers"
	@echo ""
	@echo "Examples:"
	@echo "  make docker-build-tag TAG=v1.0.0"
	@echo "  make docker-push TAG=latest"