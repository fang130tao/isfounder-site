#!/bin/bash

# ========================================
# Deploy Script for Artistry Site
# Supports: Local, VPS, Cloud Platforms
# ========================================

set -e

# Configuration
IMAGE_NAME="ghcr.io/fang130tao/isfounder-site:latest"
CONTAINER_NAME="artistry-site"
PORT=3000

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check Docker installation
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    log_info "Docker is installed: $(docker --version)"
}

# Login to GitHub Container Registry
login_ghcr() {
    log_info "Logging into GitHub Container Registry..."
    echo "Please enter your GitHub Personal Access Token (with read:packages scope):"
    read -s -p "Token: " GITHUB_TOKEN
    echo ""

    echo "$GITHUB_TOKEN" | docker login ghcr.io -u fang130tao --password-stdin

    if [ $? -eq 0 ]; then
        log_info "Successfully logged into GHCR"
    else
        log_error "Failed to login to GHCR"
        exit 1
    fi
}

# Pull latest image
pull_image() {
    log_info "Pulling latest image: $IMAGE_NAME"
    docker pull $IMAGE_NAME

    if [ $? -eq 0 ]; then
        log_info "Image pulled successfully"
    else
        log_error "Failed to pull image"
        exit 1
    fi
}

# Stop and remove existing container
stop_existing() {
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        log_warn "Stopping existing container: $CONTAINER_NAME"
        docker stop $CONTAINER_NAME
        docker rm $CONTAINER_NAME
        log_info "Existing container removed"
    fi
}

# Run new container
run_container() {
    log_info "Starting container: $CONTAINER_NAME"
    docker run -d \
        --name $CONTAINER_NAME \
        -p $PORT:3000 \
        --restart unless-stopped \
        --health-cmd="wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1" \
        --health-interval=30s \
        --health-timeout=10s \
        --health-retries=3 \
        $IMAGE_NAME

    if [ $? -eq 0 ]; then
        log_info "Container started successfully"
    else
        log_error "Failed to start container"
        exit 1
    fi
}

# Show container status
show_status() {
    log_info "Container status:"
    docker ps --filter name=$CONTAINER_NAME --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

    echo ""
    log_info "Health check:"
    docker inspect --format='{{.State.Health.Status}}' $CONTAINER_NAME

    echo ""
    log_info "Access your website at: http://localhost:$PORT"
    log_info "Or from remote server: http://$(curl -s ifconfig.me):$PORT"
}

# Main deployment flow
main() {
    log_info "Starting deployment of Artistry Site..."
    echo ""

    check_docker
    login_ghcr
    pull_image
    stop_existing
    run_container
    show_status

    echo ""
    log_info "Deployment completed successfully! 🎉"
}

# Run main function
main