#!/bin/bash

###############################################################################
# Quick Update Script for EchoMateLite
# Run this after pulling new changes from git
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}EchoMateLite - Quick Update${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Pull latest changes
echo -e "${GREEN}[1/5]${NC} Pulling latest changes from git..."
git pull origin master

# Update backend
echo -e "\n${GREEN}[2/5]${NC} Updating backend..."
cd backend
npm install
npm run build
cd ..

# Update frontend
echo -e "\n${GREEN}[3/5]${NC} Updating frontend..."
cd frontend
npm install
npm run build
cd ..

# Restart applications
echo -e "\n${GREEN}[4/5]${NC} Restarting applications with PM2..."
pm2 restart all

# Show status
echo -e "\n${GREEN}[5/5]${NC} Checking application status..."
pm2 status

echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Update completed successfully!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "View logs: ${YELLOW}pm2 logs${NC}"
echo -e "Check status: ${YELLOW}pm2 status${NC}\n"
