#!/bin/bash

###############################################################################
# EchoMateLite - One-Click Deployment Script for EC2 Ubuntu
# This script sets up the complete application with PM2 and Nginx
###############################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration Variables
APP_NAME="echomate"
DOMAIN="your-domain.com"  # Change this to your domain or EC2 public IP
BACKEND_PORT=5000
FRONTEND_PORT=3000
MONGO_DB_NAME="echomate"
MONGO_URI="mongodb://localhost:27017/$MONGO_DB_NAME"

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================${NC}\n"
}

# Check if running as root or with sudo
check_sudo() {
    if [ "$EUID" -eq 0 ]; then 
        print_error "Please do not run this script as root. Run with sudo when needed."
        exit 1
    fi
}

# Update system packages
update_system() {
    print_header "Updating System Packages"
    sudo apt update
    sudo apt upgrade -y
    print_message "System updated successfully"
}

# Install Node.js and npm
install_nodejs() {
    print_header "Installing Node.js and npm"
    
    if command -v node &> /dev/null; then
        print_warning "Node.js is already installed ($(node -v))"
    else
        print_message "Installing Node.js 20.x LTS..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt install -y nodejs
        print_message "Node.js installed: $(node -v)"
        print_message "npm installed: $(npm -v)"
    fi
}

# Install MongoDB
install_mongodb() {
    print_header "Installing MongoDB"
    
    if command -v mongod &> /dev/null; then
        print_warning "MongoDB is already installed"
    else
        print_message "Installing MongoDB..."
        
        # Import MongoDB GPG key
        curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
            sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
        
        # Add MongoDB repository
        echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
            sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
        
        sudo apt update
        sudo apt install -y mongodb-org
        
        # Start and enable MongoDB
        sudo systemctl start mongod
        sudo systemctl enable mongod
        
        print_message "MongoDB installed and started successfully"
    fi
}

# Install PM2
install_pm2() {
    print_header "Installing PM2"
    
    if command -v pm2 &> /dev/null; then
        print_warning "PM2 is already installed ($(pm2 -v))"
    else
        print_message "Installing PM2 globally..."
        sudo npm install -g pm2
        
        # Setup PM2 to start on boot
        sudo pm2 startup systemd -u $USER --hp $HOME
        
        print_message "PM2 installed: $(pm2 -v)"
    fi
}

# Install Nginx
install_nginx() {
    print_header "Installing Nginx"
    
    if command -v nginx &> /dev/null; then
        print_warning "Nginx is already installed"
    else
        print_message "Installing Nginx..."
        sudo apt install -y nginx
        
        # Enable Nginx to start on boot
        sudo systemctl enable nginx
        
        print_message "Nginx installed successfully"
    fi
}

# Install project dependencies
install_dependencies() {
    print_header "Installing Project Dependencies"
    
    # Backend dependencies
    print_message "Installing backend dependencies..."
    cd backend
    npm install
    cd ..
    
    # Frontend dependencies
    print_message "Installing frontend dependencies..."
    cd frontend
    npm install
    npm run build  # Build Next.js for production
    cd ..
    
    print_message "All dependencies installed successfully"
}

# Setup environment files
setup_environment() {
    print_header "Setting Up Environment Files"
    
    # Backend .env
    print_message "Creating backend .env file..."
    cat > backend/.env << EOF
# Server Configuration
PORT=$BACKEND_PORT
NODE_ENV=production

# MongoDB Configuration
MONGODB_URI=$MONGO_URI

# JWT Configuration
JWT_SECRET=$(openssl rand -base64 32)
JWT_EXPIRE=7d

# CORS Configuration
FRONTEND_URL=http://$DOMAIN
EOF
    
    # Frontend .env.local
    print_message "Creating frontend .env.local file..."
    cat > frontend/.env.local << EOF
# API Configuration
NEXT_PUBLIC_API_URL=http://$DOMAIN/api
EOF
    
    print_message "Environment files created successfully"
}

# Configure PM2
configure_pm2() {
    print_header "Configuring PM2"
    
    print_message "Creating PM2 ecosystem file..."
    cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'echomate-backend',
      cwd: './backend',
      script: 'npm',
      args: 'start',
      env: {
        NODE_ENV: 'production',
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '500M',
      error_file: './logs/backend-error.log',
      out_file: './logs/backend-out.log',
      log_file: './logs/backend-combined.log',
      time: true,
    },
    {
      name: 'echomate-frontend',
      cwd: './frontend',
      script: 'npm',
      args: 'start',
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '500M',
      error_file: './logs/frontend-error.log',
      out_file: './logs/frontend-out.log',
      log_file: './logs/frontend-combined.log',
      time: true,
    },
  ],
};
EOF
    
    # Create logs directory
    mkdir -p logs
    
    print_message "PM2 ecosystem file created"
}

# Configure Nginx
configure_nginx() {
    print_header "Configuring Nginx"
    
    print_message "Creating Nginx configuration..."
    sudo tee /etc/nginx/sites-available/$APP_NAME > /dev/null << EOF
# EchoMateLite Nginx Configuration

# Rate limiting zone
limit_req_zone \$binary_remote_addr zone=api_limit:10m rate=10r/s;
limit_req_zone \$binary_remote_addr zone=general_limit:10m rate=30r/s;

# Upstream Backend
upstream backend {
    server localhost:$BACKEND_PORT;
    keepalive 64;
}

# Upstream Frontend
upstream frontend {
    server localhost:$FRONTEND_PORT;
    keepalive 64;
}

# HTTP Server - Redirect to HTTPS (if SSL is configured)
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;

    # For Let's Encrypt SSL certificate verification
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    # Comment out the redirect below if not using SSL
    # return 301 https://\$server_name\$request_uri;

    # If not using SSL, proxy to the application directly
    location / {
        proxy_pass http://frontend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # API Backend
    location /api {
        limit_req zone=api_limit burst=20 nodelay;
        
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Increase body size for file uploads
        client_max_body_size 10M;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Static files caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://frontend;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss application/rss+xml font/truetype font/opentype application/vnd.ms-fontobject image/svg+xml;
}

# HTTPS Server (Uncomment after setting up SSL)
# server {
#     listen 443 ssl http2;
#     listen [::]:443 ssl http2;
#     server_name $DOMAIN;
#
#     # SSL Configuration
#     ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
#     ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
#     ssl_session_timeout 1d;
#     ssl_session_cache shared:SSL:50m;
#     ssl_session_tickets off;
#
#     # Modern SSL configuration
#     ssl_protocols TLSv1.2 TLSv1.3;
#     ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
#     ssl_prefer_server_ciphers on;
#
#     # HSTS
#     add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
#
#     # Same proxy configuration as HTTP above
#     location / {
#         proxy_pass http://frontend;
#         # ... (same proxy settings)
#     }
#
#     location /api {
#         limit_req zone=api_limit burst=20 nodelay;
#         proxy_pass http://backend;
#         # ... (same proxy settings)
#     }
# }
EOF
    
    # Enable the site
    sudo ln -sf /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled/
    
    # Remove default site if exists
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Test Nginx configuration
    print_message "Testing Nginx configuration..."
    sudo nginx -t
    
    # Reload Nginx
    sudo systemctl reload nginx
    
    print_message "Nginx configured successfully"
}

# Setup firewall
setup_firewall() {
    print_header "Configuring Firewall (UFW)"
    
    print_message "Setting up UFW firewall..."
    sudo ufw --force enable
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw allow 'Nginx Full'
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    
    print_message "Firewall configured successfully"
}

# Build backend TypeScript
build_backend() {
    print_header "Building Backend"
    
    print_message "Compiling TypeScript..."
    cd backend
    npm run build
    cd ..
    
    print_message "Backend built successfully"
}

# Start applications with PM2
start_applications() {
    print_header "Starting Applications with PM2"
    
    # Stop any existing PM2 processes
    pm2 delete all 2>/dev/null || true
    
    # Start applications
    print_message "Starting backend and frontend..."
    pm2 start ecosystem.config.js
    
    # Save PM2 process list
    pm2 save
    
    # Show status
    pm2 status
    
    print_message "Applications started successfully"
}

# Setup MongoDB initial data
setup_mongodb() {
    print_header "Setting Up MongoDB"
    
    print_message "Creating MongoDB database and initial data..."
    
    # Check if createDefaultData script exists
    if [ -f "backend/dist/scripts/createDefaultData.js" ]; then
        cd backend
        node dist/scripts/createDefaultData.js
        cd ..
        print_message "Default data created successfully"
    else
        print_warning "createDefaultData script not found, skipping..."
    fi
}

# Display completion message
display_completion() {
    print_header "Deployment Complete! 🎉"
    
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Your EchoMateLite application is now running!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    echo -e "${BLUE}📱 Application URLs:${NC}"
    echo -e "   Frontend: ${YELLOW}http://$DOMAIN${NC}"
    echo -e "   Backend API: ${YELLOW}http://$DOMAIN/api${NC}\n"
    
    echo -e "${BLUE}🔐 Default Login Credentials:${NC}"
    echo -e "   Email: ${YELLOW}admin@echomate.com${NC}"
    echo -e "   Password: ${YELLOW}admin123${NC}\n"
    
    echo -e "${BLUE}📊 Useful PM2 Commands:${NC}"
    echo -e "   View logs:     ${YELLOW}pm2 logs${NC}"
    echo -e "   View status:   ${YELLOW}pm2 status${NC}"
    echo -e "   Restart apps:  ${YELLOW}pm2 restart all${NC}"
    echo -e "   Stop apps:     ${YELLOW}pm2 stop all${NC}"
    echo -e "   Monitor apps:  ${YELLOW}pm2 monit${NC}\n"
    
    echo -e "${BLUE}🔧 Nginx Commands:${NC}"
    echo -e "   Test config:   ${YELLOW}sudo nginx -t${NC}"
    echo -e "   Reload:        ${YELLOW}sudo systemctl reload nginx${NC}"
    echo -e "   Restart:       ${YELLOW}sudo systemctl restart nginx${NC}"
    echo -e "   View logs:     ${YELLOW}sudo tail -f /var/log/nginx/error.log${NC}\n"
    
    echo -e "${BLUE}🗄️  MongoDB Commands:${NC}"
    echo -e "   Connect:       ${YELLOW}mongosh${NC}"
    echo -e "   Status:        ${YELLOW}sudo systemctl status mongod${NC}"
    echo -e "   Restart:       ${YELLOW}sudo systemctl restart mongod${NC}\n"
    
    echo -e "${BLUE}🔒 Next Steps:${NC}"
    echo -e "   1. Update DOMAIN variable in this script with your domain/IP"
    echo -e "   2. Set up SSL with: ${YELLOW}sudo certbot --nginx -d $DOMAIN${NC}"
    echo -e "   3. Update frontend .env.local with production API URL"
    echo -e "   4. Configure your DNS to point to this EC2 instance\n"
    
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Main execution
main() {
    print_header "EchoMateLite - EC2 Ubuntu Deployment"
    
    print_message "Starting deployment process..."
    print_message "This may take several minutes...\n"
    
    check_sudo
    update_system
    install_nodejs
    install_mongodb
    install_pm2
    install_nginx
    setup_environment
    install_dependencies
    build_backend
    configure_pm2
    configure_nginx
    setup_firewall
    setup_mongodb
    start_applications
    display_completion
}

# Run main function
main
