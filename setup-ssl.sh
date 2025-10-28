#!/bin/bash

###############################################################################
# SSL Setup Script for EchoMateLite
# This script sets up SSL certificates using Let's Encrypt
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if domain is provided
if [ -z "$1" ]; then
    print_error "Usage: ./setup-ssl.sh your-domain.com"
    exit 1
fi

DOMAIN=$1
EMAIL="admin@$DOMAIN"  # Change this to your email

print_message "Setting up SSL for domain: $DOMAIN"

# Install Certbot
print_message "Installing Certbot..."
sudo apt update
sudo apt install -y certbot python3-certbot-nginx

# Get SSL certificate
print_message "Obtaining SSL certificate..."
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL

# Setup auto-renewal
print_message "Setting up auto-renewal..."
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Update Nginx configuration to use SSL
print_message "Updating Nginx configuration..."
sudo sed -i 's/# return 301 https/return 301 https/g' /etc/nginx/sites-available/echomate
sudo sed -i 's/# server {/server {/g' /etc/nginx/sites-available/echomate
sudo sed -i 's/#     listen 443/    listen 443/g' /etc/nginx/sites-available/echomate
sudo sed -i 's/#     ssl_/    ssl_/g' /etc/nginx/sites-available/echomate
sudo sed -i 's/#     add_header/    add_header/g' /etc/nginx/sites-available/echomate
sudo sed -i "s/# }/}/g" /etc/nginx/sites-available/echomate

# Test and reload Nginx
print_message "Testing Nginx configuration..."
sudo nginx -t

print_message "Reloading Nginx..."
sudo systemctl reload nginx

print_message "SSL setup complete! Your site is now accessible via HTTPS"
print_message "Visit: https://$DOMAIN"
