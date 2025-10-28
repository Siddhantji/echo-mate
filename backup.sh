#!/bin/bash

###############################################################################
# Automated Backup Script for EchoMateLite
# Backs up MongoDB database
###############################################################################

set -e

# Configuration
BACKUP_DIR="$HOME/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="echomate"
RETENTION_DAYS=7

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}EchoMateLite - Database Backup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Create backup directory
mkdir -p $BACKUP_DIR

echo -e "${GREEN}[1/4]${NC} Creating MongoDB backup..."
mongodump --db $DB_NAME --out $BACKUP_DIR/mongo-$DATE

# Compress backup
echo -e "${GREEN}[2/4]${NC} Compressing backup..."
tar -czf $BACKUP_DIR/mongo-$DATE.tar.gz -C $BACKUP_DIR mongo-$DATE
rm -rf $BACKUP_DIR/mongo-$DATE

# Calculate size
BACKUP_SIZE=$(du -h $BACKUP_DIR/mongo-$DATE.tar.gz | cut -f1)

# Clean old backups
echo -e "${GREEN}[3/4]${NC} Cleaning old backups (keeping last $RETENTION_DAYS days)..."
find $BACKUP_DIR -name "mongo-*.tar.gz" -type f -mtime +$RETENTION_DAYS -delete

# Count remaining backups
BACKUP_COUNT=$(ls -1 $BACKUP_DIR/mongo-*.tar.gz 2>/dev/null | wc -l)

echo -e "${GREEN}[4/4]${NC} Backup summary..."

echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Backup completed successfully!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "Backup file: ${YELLOW}mongo-$DATE.tar.gz${NC}"
echo -e "Backup size: ${YELLOW}$BACKUP_SIZE${NC}"
echo -e "Backup location: ${YELLOW}$BACKUP_DIR${NC}"
echo -e "Total backups: ${YELLOW}$BACKUP_COUNT${NC}\n"

echo -e "To restore this backup, run:"
echo -e "${YELLOW}tar -xzf $BACKUP_DIR/mongo-$DATE.tar.gz -C /tmp${NC}"
echo -e "${YELLOW}mongorestore --db $DB_NAME /tmp/mongo-$DATE/$DB_NAME${NC}\n"
