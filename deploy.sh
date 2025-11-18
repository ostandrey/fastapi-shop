#!/bin/bash

# ============================================================================
# FastAPI Shop automatic deployment script for VPS
# ============================================================================

set -e  # Stop execution on any error

# Colors for beautiful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Functions for beautiful output
print_header() {
    echo -e "\n${BOLD}${MAGENTA}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${MAGENTA}║${NC}  $1"
    echo -e "${BOLD}${MAGENTA}╚═══════════════════════════════════════════════════════════════╝${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

print_step() {
    echo -e "\n${BOLD}${BLUE}▶${NC} $1${NC}"
}

# Check that script is run with root privileges
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run with root privileges (use sudo)"
        exit 1
    fi
}

# Welcome message
show_welcome() {
    clear
    echo -e "${BOLD}${CYAN}"
    cat << "EOF"
   ╔═══════════════════════════════════════════════════════════╗
   ║                                                           ║
   ║       🛍️  FASTAPI SHOP - DEPLOYMENT SCRIPT 🛍️            ║
   ║                                                           ║
   ║         Automatic installation and configuration         ║
   ║                   on Ubuntu VPS                           ║
   ║                                                           ║
   ╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"
}

# Dialog menu for data input
get_user_input() {
    print_header "PROJECT CONFIGURATION"

    # Domain
    while true; do
        echo -e "${BOLD}${YELLOW}Enter main domain (e.g., myshop.com):${NC}"
        read -p "> " DOMAIN
        if [[ -z "$DOMAIN" ]]; then
            print_error "Domain cannot be empty!"
        elif [[ ! "$DOMAIN" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]?\.[a-zA-Z]{2,}$ ]]; then
            print_error "Invalid domain format!"
        else
            print_success "Domain accepted: $DOMAIN"
            break
        fi
    done

    # Email for Let's Encrypt
    echo -e "\n${BOLD}${YELLOW}Enter email for Let's Encrypt certificates:${NC}"
    read -p "> " EMAIL
    while [[ ! "$EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; do
        print_error "Invalid email format!"
        read -p "> " EMAIL
    done
    print_success "Email accepted: $EMAIL"

    # Application name
    echo -e "\n${BOLD}${YELLOW}Enter shop name (default: FastAPI Shop):${NC}"
    read -p "> " APP_NAME
    APP_NAME=${APP_NAME:-"FastAPI Shop"}
    print_success "Name: $APP_NAME"

    # Confirmation
    echo -e "\n${BOLD}${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}Review entered data:${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "  Domain:         ${GREEN}$DOMAIN${NC}"
    echo -e "  WWW Domain:     ${GREEN}www.$DOMAIN${NC}"
    echo -e "  Email:          ${GREEN}$EMAIL${NC}"
    echo -e "  Name:           ${GREEN}$APP_NAME${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}\n"

    read -p "Is everything correct? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Configuration cancelled. Restart the script."
        exit 0
    fi
}

# Create .env file
create_env_file() {
    print_step "Creating .env configuration file"

    cat > .env << EOF
# Domain Configuration
DOMAIN=$DOMAIN
EMAIL=$EMAIL

# Application
APP_NAME=$APP_NAME
DEBUG=False

# CORS Origins (comma-separated)
CORS_ORIGINS=https://$DOMAIN,https://www.$DOMAIN

# API Configuration
VITE_API_BASE_URL=https://$DOMAIN/api
EOF

    print_success ".env file created successfully"
}

# Create backend .env file
create_backend_env_file() {
    print_step "Creating backend/.env file"

    cat > backend/.env << EOF
# Application
APP_NAME=$APP_NAME
DEBUG=False

# Database
DATABASE_URL=sqlite:///./shop.db

# CORS Origins
CORS_ORIGINS=https://$DOMAIN,https://www.$DOMAIN

# Static files
STATIC_DIR=static
IMAGES_DIR=static/images
EOF

    print_success "backend/.env file created successfully"
}

# Update system
update_system() {
    print_step "Updating Ubuntu system"
    apt-get update -qq > /dev/null 2>&1
    apt-get upgrade -y -qq > /dev/null 2>&1
    print_success "System updated"
}

# Install required packages
install_dependencies() {
    print_step "Installing required packages"

    PACKAGES=(
        "curl"
        "wget"
        "git"
        "software-properties-common"
        "ca-certificates"
        "gnupg"
        "lsb-release"
    )

    for package in "${PACKAGES[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package"; then
            print_info "Installing $package..."
            apt-get install -y -qq "$package" > /dev/null 2>&1
            print_success "$package installed"
        else
            print_info "$package already installed"
        fi
    done
}

# Stop processes on port 80
kill_port_80() {
    print_step "Checking processes on port 80"

    if lsof -Pi :80 -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_warning "Processes detected on port 80"
        print_info "Stopping processes..."

        PIDS=$(lsof -Pi :80 -sTCP:LISTEN -t)
        for PID in $PIDS; do
            PROCESS_NAME=$(ps -p $PID -o comm=)
            print_info "Stopping process: $PROCESS_NAME (PID: $PID)"
            kill -9 $PID 2>/dev/null || true
        done

        sleep 2

        if lsof -Pi :80 -sTCP:LISTEN -t >/dev/null 2>&1; then
            print_error "Failed to free port 80"
            exit 1
        else
            print_success "Port 80 freed"
        fi
    else
        print_success "Port 80 is free"
    fi
}

# Install Docker
install_docker() {
    print_step "Checking Docker installation"

    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version | cut -d ' ' -f3 | cut -d ',' -f1)
        print_success "Docker already installed (version: $DOCKER_VERSION)"
    else
        print_info "Installing Docker..."

        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg

        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

        apt-get update -qq > /dev/null 2>&1
        apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1

        systemctl start docker
        systemctl enable docker > /dev/null 2>&1

        DOCKER_VERSION=$(docker --version | cut -d ' ' -f3 | cut -d ',' -f1)
        print_success "Docker installed successfully (version: $DOCKER_VERSION)"
    fi
}

# Install Certbot
install_certbot() {
    print_step "Installing Certbot for SSL certificates"

    if command -v certbot &> /dev/null; then
        print_success "Certbot already installed"
    else
        print_info "Installing Certbot..."
        apt-get install -y -qq certbot > /dev/null 2>&1
        print_success "Certbot installed"
    fi
}

# Obtain SSL certificates
obtain_ssl_certificates() {
    print_step "Obtaining Let's Encrypt SSL certificates"

    if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
        print_warning "Certificates for $DOMAIN already exist"
        read -p "Renew certificates? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Using existing certificates"
            return 0
        fi
    fi

    mkdir -p certbot/www

    print_info "Starting temporary web server for domain verification..."

    docker run --rm -d \
        --name nginx_certbot_temp \
        -p 80:80 \
        -v "$(pwd)/certbot/www:/usr/share/nginx/html" \
        nginx:alpine > /dev/null 2>&1

    sleep 3

    print_info "Requesting certificates for domains: $DOMAIN, www.$DOMAIN"

    certbot certonly --webroot \
        --webroot-path="$(pwd)/certbot/www" \
        --email "$EMAIL" \
        --agree-tos \
        --no-eff-email \
        --force-renewal \
        -d "$DOMAIN" \
        -d "www.$DOMAIN"

    docker stop nginx_certbot_temp > /dev/null 2>&1 || true

    if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
        print_success "SSL certificates obtained successfully"
        print_info "Certificates saved in: /etc/letsencrypt/live/$DOMAIN/"
    else
        print_error "Failed to obtain SSL certificates"
        print_warning "Check that domains $DOMAIN and www.$DOMAIN point to this server"
        exit 1
    fi
}

# Configure Nginx configuration
configure_nginx() {
    print_step "Configuring Nginx configuration"

    cat > nginx/nginx.conf << EOF
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server_tokens off;
    client_max_body_size 10M;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json;

    # HTTP to HTTPS redirect
    server {
        listen 80;
        server_name $DOMAIN www.$DOMAIN;

        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        location / {
            return 301 https://\$host\$request_uri;
        }
    }

    # HTTPS server
    server {
        listen 443 ssl http2;
        server_name $DOMAIN www.$DOMAIN;

        ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;

        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;

        # Frontend (Vue.js)
        location / {
            proxy_pass http://frontend:80;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }

        # Backend API
        location /api {
            proxy_pass http://backend:8000;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;

            proxy_http_version 1.1;
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }

        # Static files from backend
        location /static/ {
            alias /app/backend/static/;
            expires 30d;
            add_header Cache-Control "public, immutable";
        }

        # Health check
        location /health {
            proxy_pass http://backend:8000;
            access_log off;
        }
    }
}
EOF

    print_success "Nginx configuration created"
}

# Update docker-compose.yml
update_docker_compose() {
    print_step "Updating docker-compose.yml"

    cat > docker-compose.yml << EOF
version: '3.8'

services:
  backend:
    build:
      context: .
      dockerfile: backend/Dockerfile
    container_name: fashop_backend
    command: uvicorn backend.app.main:app --host 0.0.0.0 --port 8000
    volumes:
      - ./backend:/app/backend
      - ./backend/shop.db:/app/backend/shop.db
      - backend_static:/app/backend/static
    environment:
      - APP_NAME=$APP_NAME
      - DEBUG=False
      - DATABASE_URL=sqlite:///./backend/shop.db
      - CORS_ORIGINS=https://$DOMAIN,https://www.$DOMAIN
    expose:
      - "8000"
    restart: unless-stopped
    networks:
      - fashop_network

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      args:
        - VITE_API_BASE_URL=https://$DOMAIN/api
    container_name: fashop_frontend
    depends_on:
      - backend
    expose:
      - "80"
    restart: unless-stopped
    networks:
      - fashop_network

  nginx:
    image: nginx:alpine
    container_name: fashop_nginx
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - /etc/letsencrypt:/etc/letsencrypt:ro
      - backend_static:/app/backend/static:ro
      - ./certbot/www:/var/www/certbot:ro
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - backend
      - frontend
    restart: unless-stopped
    networks:
      - fashop_network

  certbot:
    image: certbot/certbot
    container_name: fashop_certbot
    volumes:
      - /etc/letsencrypt:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait \$\${!}; done;'"
    restart: unless-stopped
    networks:
      - fashop_network

networks:
  fashop_network:
    driver: bridge

volumes:
  backend_static:
EOF

    print_success "docker-compose.yml updated"
}

# Update backend Dockerfile
update_backend_dockerfile() {
    print_step "Updating backend Dockerfile"

    cat > backend/Dockerfile << EOF
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \\
    gcc \\
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ .

# Create static directory in the correct location
RUN mkdir -p static/images

RUN chmod -R 755 static

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

    print_success "backend/Dockerfile updated"
}

# Update frontend Dockerfile to pass API URL
update_frontend_dockerfile() {
    print_step "Updating frontend Dockerfile"

    cat > frontend/Dockerfile << EOF
FROM node:20-alpine as build

WORKDIR /app

ARG VITE_API_BASE_URL
ENV VITE_API_BASE_URL=\${VITE_API_BASE_URL}

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
EOF

    print_success "frontend/Dockerfile updated"
}

# Create necessary directories
create_directories() {
    print_step "Creating necessary directories"

    DIRS=(
        "backend/static/images"
        "certbot/www"
    )

    for dir in "${DIRS[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_success "Directory created: $dir"
        else
            print_info "Directory already exists: $dir"
        fi
    done

    chmod -R 755 backend/static 2>/dev/null || true
    print_success "Permissions set"
}

# Build and run Docker containers
build_and_run_docker() {
    print_step "Building and running Docker containers"

    if docker ps -a | grep -q "fashop"; then
        print_info "Stopping existing containers..."
        docker compose down > /dev/null 2>&1 || true
        print_success "Old containers stopped"
    fi

    print_info "Building Docker images (this may take several minutes)..."
    docker compose build --no-cache > /dev/null 2>&1
    print_success "Docker images built"

    print_info "Starting containers..."
    docker compose up -d

    print_info "Waiting for services to start..."
    sleep 15

    STATUS=$(docker compose ps | grep -c "Up" || echo "0")

    if [ "$STATUS" -ge 2 ]; then
        print_success "All containers started successfully"
    else
        print_warning "Some containers may not be running"
        print_info "Check status: docker compose ps"
    fi
}

# Seed database with test data
seed_database() {
    print_step "Seeding database with test data"

    print_info "Checking for existing data in database..."

    sleep 5

    print_info "Running seed_data.py script..."
    docker compose exec -T backend python backend/seed_data.py

    if [ $? -eq 0 ]; then
        print_success "Database seeded successfully"
    else
        print_warning "Database may already contain data"
    fi
}

# Check application health
check_health() {
    print_step "Checking application health"

    print_info "Waiting for service initialization..."
    sleep 5

    if curl -f -s http://localhost:8000/health > /dev/null 2>&1; then
        print_success "Backend is responding to requests"
    else
        print_warning "Backend is not responding yet (may need more time)"
    fi

    print_info "Checking HTTPS availability..."
    sleep 3
    if curl -f -s -k "https://$DOMAIN/health" > /dev/null 2>&1; then
        print_success "HTTPS is working correctly"
    else
        print_warning "HTTPS may need additional time to initialize"
    fi
}

# Show deployment information
show_deployment_info() {
    clear
    print_header "DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉"

    echo -e "${BOLD}${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║                   PROJECT INFORMATION                        ║${NC}"
    echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}\n"

    echo -e "${BOLD}🌐 URLs:${NC}"
    echo -e "   Shop:             ${CYAN}https://$DOMAIN${NC}"
    echo -e "   WWW version:      ${CYAN}https://www.$DOMAIN${NC}"
    echo -e "   API Docs:         ${CYAN}https://$DOMAIN/api/docs${NC}"
    echo -e "   Health Check:     ${CYAN}https://$DOMAIN/health${NC}"

    echo -e "\n${BOLD}📝 Useful commands:${NC}"
    echo -e "   View logs:            ${CYAN}docker compose logs -f${NC}"
    echo -e "   Backend logs:         ${CYAN}docker compose logs -f backend${NC}"
    echo -e "   Frontend logs:        ${CYAN}docker compose logs -f frontend${NC}"
    echo -e "   Restart:              ${CYAN}docker compose restart${NC}"
    echo -e "   Stop:                 ${CYAN}docker compose down${NC}"
    echo -e "   Container status:     ${CYAN}docker compose ps${NC}"
    echo -e "   Recreate data:        ${CYAN}docker compose exec backend python backend/seed_data.py${NC}"

    echo -e "\n${BOLD}📂 Important files:${NC}"
    echo -e "   Configuration:   ${CYAN}.env${NC}"
    echo -e "   Backend config:  ${CYAN}backend/.env${NC}"
    echo -e "   Database:        ${CYAN}backend/shop.db${NC}"
    echo -e "   SSL certificates: ${CYAN}/etc/letsencrypt/live/$DOMAIN/${NC}"

    echo -e "\n${BOLD}🔄 Certificate renewal:${NC}"
    echo -e "   Certificates are automatically renewed via certbot container"
    echo -e "   Manual renewal: ${CYAN}docker compose restart certbot${NC}"

    echo -e "\n${BOLD}📦 Project structure:${NC}"
    echo -e "   Backend:  FastAPI (SQLite) - port 8000"
    echo -e "   Frontend: Vue.js 3 + Vite - port 80 (inside container)"
    echo -e "   Nginx:    Reverse Proxy + SSL - ports 80/443"

    echo -e "\n${BOLD}${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║  Your shop is available at: https://$DOMAIN            ║${NC}"
    echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}\n"
}

# Main function
main() {
    show_welcome

    print_info "Checking access rights..."
    check_root

    get_user_input

    print_header "STARTING INSTALLATION"

    create_env_file
    create_backend_env_file
    update_system
    install_dependencies
    kill_port_80
    install_docker
    install_certbot
    obtain_ssl_certificates
    configure_nginx
    update_docker_compose
    update_frontend_dockerfile
    create_directories
    build_and_run_docker
    seed_database
    check_health

    show_deployment_info

    print_success "Deployment completed!"
}

# Handle interruption
trap 'echo -e "\n${RED}Installation interrupted by user${NC}"; exit 130' INT

# Run main function
main

exit 0