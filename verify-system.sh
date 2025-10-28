#!/bin/bash

###############################################################################
# Pre-Deployment Verification Script
# Checks if EC2 instance meets all requirements before deployment
###############################################################################

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}EchoMateLite - Pre-Deployment Verification${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

CHECKS_PASSED=0
CHECKS_FAILED=0

# Check Ubuntu version
echo -n "Checking Ubuntu version... "
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$VERSION_ID" == "22.04" ]] || [[ "$VERSION_ID" == "20.04" ]]; then
        echo -e "${GREEN}✅ $PRETTY_NAME${NC}"
        ((CHECKS_PASSED++))
    else
        echo -e "${YELLOW}⚠️  $PRETTY_NAME (Recommended: 22.04)${NC}"
        ((CHECKS_PASSED++))
    fi
else
    echo -e "${RED}❌ Cannot detect OS${NC}"
    ((CHECKS_FAILED++))
fi

# Check memory
echo -n "Checking available memory... "
TOTAL_MEM=$(free -m | awk 'NR==2{print $2}')
if [ "$TOTAL_MEM" -ge 900 ]; then
    echo -e "${GREEN}✅ ${TOTAL_MEM}MB (Recommended: 1GB+)${NC}"
    ((CHECKS_PASSED++))
else
    echo -e "${RED}❌ ${TOTAL_MEM}MB (Minimum: 1GB required)${NC}"
    ((CHECKS_FAILED++))
fi

# Check disk space
echo -n "Checking disk space... "
AVAILABLE_SPACE=$(df -BG / | awk 'NR==2{print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -ge 15 ]; then
    echo -e "${GREEN}✅ ${AVAILABLE_SPACE}GB available (Recommended: 20GB+)${NC}"
    ((CHECKS_PASSED++))
else
    echo -e "${RED}❌ ${AVAILABLE_SPACE}GB available (Minimum: 15GB required)${NC}"
    ((CHECKS_FAILED++))
fi

# Check internet connectivity
echo -n "Checking internet connectivity... "
if ping -c 1 google.com &> /dev/null; then
    echo -e "${GREEN}✅ Connected${NC}"
    ((CHECKS_PASSED++))
else
    echo -e "${RED}❌ No internet connection${NC}"
    ((CHECKS_FAILED++))
fi

# Check if running as root
echo -n "Checking user privileges... "
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}❌ Running as root (Run as ubuntu user with sudo)${NC}"
    ((CHECKS_FAILED++))
else
    echo -e "${GREEN}✅ Running as non-root user${NC}"
    ((CHECKS_PASSED++))
fi

# Check sudo access
echo -n "Checking sudo access... "
if sudo -n true 2>/dev/null; then
    echo -e "${GREEN}✅ Sudo access available${NC}"
    ((CHECKS_PASSED++))
else
    echo -e "${YELLOW}⚠️  May need sudo password${NC}"
    ((CHECKS_PASSED++))
fi

# Check if ports 80 and 443 are available
echo -n "Checking if port 80 is available... "
if ! sudo lsof -i :80 &> /dev/null; then
    echo -e "${GREEN}✅ Available${NC}"
    ((CHECKS_PASSED++))
else
    echo -e "${YELLOW}⚠️  Port 80 is in use${NC}"
    ((CHECKS_PASSED++))
fi

echo -n "Checking if port 443 is available... "
if ! sudo lsof -i :443 &> /dev/null; then
    echo -e "${GREEN}✅ Available${NC}"
    ((CHECKS_PASSED++))
else
    echo -e "${YELLOW}⚠️  Port 443 is in use${NC}"
    ((CHECKS_PASSED++))
fi

# Check if deployment files exist
echo -n "Checking deployment script... "
if [ -f "deploy.sh" ]; then
    echo -e "${GREEN}✅ Found${NC}"
    ((CHECKS_PASSED++))
else
    echo -e "${RED}❌ deploy.sh not found${NC}"
    ((CHECKS_FAILED++))
fi

echo -n "Checking ecosystem config... "
if [ -f "ecosystem.config.js" ]; then
    echo -e "${GREEN}✅ Found${NC}"
    ((CHECKS_PASSED++))
else
    echo -e "${RED}❌ ecosystem.config.js not found${NC}"
    ((CHECKS_FAILED++))
fi

# Check if backend and frontend directories exist
echo -n "Checking backend directory... "
if [ -d "backend" ]; then
    echo -e "${GREEN}✅ Found${NC}"
    ((CHECKS_PASSED++))
else
    echo -e "${RED}❌ backend directory not found${NC}"
    ((CHECKS_FAILED++))
fi

echo -n "Checking frontend directory... "
if [ -d "frontend" ]; then
    echo -e "${GREEN}✅ Found${NC}"
    ((CHECKS_PASSED++))
else
    echo -e "${RED}❌ frontend directory not found${NC}"
    ((CHECKS_FAILED++))
fi

# Summary
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

TOTAL_CHECKS=$((CHECKS_PASSED + CHECKS_FAILED))

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed ($CHECKS_PASSED/$TOTAL_CHECKS)${NC}"
    echo -e "${GREEN}System is ready for deployment!${NC}"
    echo -e "\nRun: ${YELLOW}./deploy.sh${NC} to start deployment"
else
    echo -e "${RED}❌ Some checks failed ($CHECKS_FAILED/$TOTAL_CHECKS)${NC}"
    echo -e "${YELLOW}Please fix the issues above before deploying.${NC}"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Exit with error code if checks failed
[ $CHECKS_FAILED -gt 0 ] && exit 1
exit 0
