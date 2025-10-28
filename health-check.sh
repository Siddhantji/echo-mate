#!/bin/bash

###############################################################################
# Health Check Script for EchoMateLite
# Checks if all services are running properly
###############################################################################

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BACKEND_PORT=5000
FRONTEND_PORT=3000

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}EchoMateLite - Health Check${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Check MongoDB
echo -n "Checking MongoDB... "
if systemctl is-active --quiet mongod; then
    echo -e "${GREEN}✅ Running${NC}"
    MONGO_STATUS="OK"
else
    echo -e "${RED}❌ Not Running${NC}"
    MONGO_STATUS="FAILED"
fi

# Check Nginx
echo -n "Checking Nginx... "
if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}✅ Running${NC}"
    NGINX_STATUS="OK"
else
    echo -e "${RED}❌ Not Running${NC}"
    NGINX_STATUS="FAILED"
fi

# Check PM2
echo -n "Checking PM2... "
if command -v pm2 &> /dev/null; then
    PM2_COUNT=$(pm2 list | grep -c "online" || echo "0")
    if [ "$PM2_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✅ Running ($PM2_COUNT apps online)${NC}"
        PM2_STATUS="OK"
    else
        echo -e "${RED}❌ No apps running${NC}"
        PM2_STATUS="FAILED"
    fi
else
    echo -e "${RED}❌ Not Installed${NC}"
    PM2_STATUS="FAILED"
fi

# Check Backend Port
echo -n "Checking Backend (port $BACKEND_PORT)... "
if nc -z localhost $BACKEND_PORT 2>/dev/null; then
    echo -e "${GREEN}✅ Accessible${NC}"
    BACKEND_STATUS="OK"
else
    echo -e "${RED}❌ Not Accessible${NC}"
    BACKEND_STATUS="FAILED"
fi

# Check Frontend Port
echo -n "Checking Frontend (port $FRONTEND_PORT)... "
if nc -z localhost $FRONTEND_PORT 2>/dev/null; then
    echo -e "${GREEN}✅ Accessible${NC}"
    FRONTEND_STATUS="OK"
else
    echo -e "${RED}❌ Not Accessible${NC}"
    FRONTEND_STATUS="FAILED"
fi

# Check API Response
echo -n "Checking Backend API... "
HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$BACKEND_PORT/api 2>/dev/null || echo "000")
if [ "$HTTP_RESPONSE" = "200" ] || [ "$HTTP_RESPONSE" = "404" ]; then
    echo -e "${GREEN}✅ Responding${NC}"
    API_STATUS="OK"
else
    echo -e "${RED}❌ Not Responding (HTTP $HTTP_RESPONSE)${NC}"
    API_STATUS="FAILED"
fi

# Check Disk Space
echo -n "Checking Disk Space... "
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    echo -e "${GREEN}✅ ${DISK_USAGE}% used${NC}"
    DISK_STATUS="OK"
elif [ "$DISK_USAGE" -lt 90 ]; then
    echo -e "${YELLOW}⚠️  ${DISK_USAGE}% used${NC}"
    DISK_STATUS="WARNING"
else
    echo -e "${RED}❌ ${DISK_USAGE}% used${NC}"
    DISK_STATUS="CRITICAL"
fi

# Check Memory
echo -n "Checking Memory... "
MEMORY_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100)}')
if [ "$MEMORY_USAGE" -lt 80 ]; then
    echo -e "${GREEN}✅ ${MEMORY_USAGE}% used${NC}"
    MEMORY_STATUS="OK"
elif [ "$MEMORY_USAGE" -lt 90 ]; then
    echo -e "${YELLOW}⚠️  ${MEMORY_USAGE}% used${NC}"
    MEMORY_STATUS="WARNING"
else
    echo -e "${RED}❌ ${MEMORY_USAGE}% used${NC}"
    MEMORY_STATUS="CRITICAL"
fi

# Overall Status
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

FAILED_COUNT=0
WARNING_COUNT=0

[[ "$MONGO_STATUS" == "FAILED" ]] && ((FAILED_COUNT++))
[[ "$NGINX_STATUS" == "FAILED" ]] && ((FAILED_COUNT++))
[[ "$PM2_STATUS" == "FAILED" ]] && ((FAILED_COUNT++))
[[ "$BACKEND_STATUS" == "FAILED" ]] && ((FAILED_COUNT++))
[[ "$FRONTEND_STATUS" == "FAILED" ]] && ((FAILED_COUNT++))
[[ "$API_STATUS" == "FAILED" ]] && ((FAILED_COUNT++))
[[ "$DISK_STATUS" == "CRITICAL" ]] && ((FAILED_COUNT++))
[[ "$MEMORY_STATUS" == "CRITICAL" ]] && ((FAILED_COUNT++))

[[ "$DISK_STATUS" == "WARNING" ]] && ((WARNING_COUNT++))
[[ "$MEMORY_STATUS" == "WARNING" ]] && ((WARNING_COUNT++))

if [ $FAILED_COUNT -eq 0 ] && [ $WARNING_COUNT -eq 0 ]; then
    echo -e "${GREEN}✅ Overall Status: ALL SYSTEMS OPERATIONAL${NC}"
elif [ $FAILED_COUNT -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Overall Status: SOME WARNINGS${NC}"
else
    echo -e "${RED}❌ Overall Status: CRITICAL ISSUES DETECTED${NC}"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Show PM2 status if available
if [ "$PM2_STATUS" == "OK" ]; then
    echo -e "${BLUE}PM2 Process Status:${NC}"
    pm2 status
    echo ""
fi

# Suggestions if issues found
if [ $FAILED_COUNT -gt 0 ] || [ $WARNING_COUNT -gt 0 ]; then
    echo -e "${YELLOW}Suggested Actions:${NC}"
    
    [[ "$MONGO_STATUS" == "FAILED" ]] && echo "  • Restart MongoDB: sudo systemctl restart mongod"
    [[ "$NGINX_STATUS" == "FAILED" ]] && echo "  • Restart Nginx: sudo systemctl restart nginx"
    [[ "$PM2_STATUS" == "FAILED" ]] && echo "  • Start PM2 apps: pm2 start ecosystem.config.js"
    [[ "$BACKEND_STATUS" == "FAILED" ]] && echo "  • Check backend logs: pm2 logs echomate-backend"
    [[ "$FRONTEND_STATUS" == "FAILED" ]] && echo "  • Check frontend logs: pm2 logs echomate-frontend"
    [[ "$API_STATUS" == "FAILED" ]] && echo "  • Check API logs: pm2 logs echomate-backend"
    [[ "$DISK_STATUS" == "CRITICAL" || "$DISK_STATUS" == "WARNING" ]] && echo "  • Clean up disk space: sudo apt clean && sudo apt autoremove"
    [[ "$MEMORY_STATUS" == "CRITICAL" || "$MEMORY_STATUS" == "WARNING" ]] && echo "  • Check memory usage: free -h && pm2 monit"
    
    echo ""
fi

# Exit with error code if critical issues
[ $FAILED_COUNT -gt 0 ] && exit 1
exit 0
