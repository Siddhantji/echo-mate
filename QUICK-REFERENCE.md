# 📋 EchoMateLite - Quick Reference Card

## 🚀 Deployment Commands

```bash
# Pre-deployment check
./verify-system.sh

# One-click deployment
./deploy.sh

# Setup SSL certificate
./setup-ssl.sh yourdomain.com

# Update after code changes
./update.sh

# Create database backup
./backup.sh

# Check system health
./health-check.sh
```

---

## 🔧 PM2 Commands

```bash
# Process Management
pm2 start ecosystem.config.js    # Start applications
pm2 restart all                   # Restart all apps
pm2 stop all                      # Stop all apps
pm2 delete all                    # Remove all apps
pm2 reload all                    # Zero-downtime reload

# Monitoring
pm2 status                        # List all processes
pm2 monit                         # Interactive monitoring
pm2 logs                          # View all logs
pm2 logs echomate-backend         # Backend logs only
pm2 logs --lines 100              # Last 100 lines
pm2 flush                         # Clear all logs

# Information
pm2 info echomate-backend         # Detailed process info
pm2 describe echomate-backend     # Full description

# Save & Startup
pm2 save                          # Save process list
pm2 startup                       # Generate startup script
pm2 unstartup                     # Disable startup script
```

---

## 🌐 Nginx Commands

```bash
# Service Control
sudo systemctl start nginx        # Start Nginx
sudo systemctl stop nginx         # Stop Nginx
sudo systemctl restart nginx      # Restart Nginx
sudo systemctl reload nginx       # Reload config (no downtime)
sudo systemctl status nginx       # Check status

# Configuration
sudo nginx -t                     # Test configuration
sudo nano /etc/nginx/sites-available/echomate  # Edit config

# Logs
sudo tail -f /var/log/nginx/access.log   # Access log
sudo tail -f /var/log/nginx/error.log    # Error log
```

---

## 🗄️ MongoDB Commands

```bash
# Service Control
sudo systemctl start mongod       # Start MongoDB
sudo systemctl stop mongod        # Stop MongoDB
sudo systemctl restart mongod     # Restart MongoDB
sudo systemctl status mongod      # Check status

# MongoDB Shell
mongosh                           # Connect to MongoDB
mongosh --eval "db.stats()"       # Quick stats

# In mongosh:
show dbs                          # List databases
use echomate                      # Switch to database
show collections                  # List collections
db.users.find().pretty()          # View users
db.posts.find().limit(5)          # View last 5 posts
db.stats()                        # Database statistics
exit                              # Exit mongosh

# Backup & Restore
mongodump --db echomate --out ~/backup     # Backup
mongorestore --db echomate ~/backup/echomate  # Restore
```

---

## 🔥 Firewall (UFW) Commands

```bash
sudo ufw status                   # Check firewall status
sudo ufw enable                   # Enable firewall
sudo ufw disable                  # Disable firewall
sudo ufw allow 80/tcp            # Allow HTTP
sudo ufw allow 443/tcp           # Allow HTTPS
sudo ufw allow ssh               # Allow SSH
sudo ufw delete allow 80/tcp     # Remove rule
```

---

## 🔐 SSL (Certbot) Commands

```bash
# Certificate Management
sudo certbot certificates         # List certificates
sudo certbot renew               # Renew certificates
sudo certbot renew --dry-run     # Test renewal
sudo certbot delete              # Delete certificate

# Auto-renewal
sudo systemctl status certbot.timer    # Check auto-renewal
sudo systemctl enable certbot.timer    # Enable auto-renewal
```

---

## 📊 System Monitoring

```bash
# Resource Usage
htop                             # Interactive process viewer
free -h                          # Memory usage
df -h                            # Disk usage
du -sh *                         # Directory sizes
uptime                           # System uptime & load

# Network
netstat -tulpn                   # Active connections
ss -tulpn                        # Socket statistics
curl localhost:5000/api          # Test backend
curl localhost:3000              # Test frontend

# Processes
ps aux | grep node               # Node processes
lsof -i :5000                    # Process using port 5000
kill -9 PID                      # Force kill process
```

---

## 🐛 Troubleshooting

```bash
# Application Issues
pm2 logs --err                   # Error logs only
pm2 restart all --update-env     # Restart with new env vars
pm2 delete all && pm2 start ecosystem.config.js  # Clean restart

# Permission Issues
sudo chown -R $USER:$USER ~/echomate   # Fix ownership
chmod +x *.sh                    # Make scripts executable

# Port Conflicts
sudo lsof -i :5000              # Check port 5000
sudo lsof -i :3000              # Check port 3000
sudo kill -9 $(lsof -ti:5000)   # Kill process on port 5000

# Disk Space
sudo apt clean                   # Clean package cache
sudo apt autoremove              # Remove unused packages
pm2 flush                        # Clear PM2 logs
find ~/backups -mtime +7 -delete # Delete old backups

# Clean Reinstall
pm2 delete all
sudo systemctl stop nginx
sudo systemctl stop mongod
# Then run deploy.sh again
```

---

## 📝 Environment Files

```bash
# Backend (.env)
nano backend/.env
# Variables:
# PORT=5000
# NODE_ENV=production
# MONGODB_URI=mongodb://localhost:27017/echomate
# JWT_SECRET=your-secret-key
# JWT_EXPIRE=7d
# FRONTEND_URL=http://yourdomain.com

# Frontend (.env.local)
nano frontend/.env.local
# Variables:
# NEXT_PUBLIC_API_URL=http://yourdomain.com/api
```

---

## 🔄 Git Commands

```bash
# Update Code
git pull origin master           # Pull latest changes
git status                       # Check status
git log --oneline -5            # View last 5 commits

# After pulling, run:
./update.sh                      # Rebuild and restart
```

---

## 📦 Package Management

```bash
# Backend
cd backend
npm install                      # Install dependencies
npm update                       # Update packages
npm run build                    # Build TypeScript
npm run dev                      # Development mode
npm start                        # Production mode

# Frontend
cd frontend
npm install                      # Install dependencies
npm update                       # Update packages
npm run build                    # Build for production
npm run dev                      # Development mode
npm start                        # Production mode
```

---

## 🎯 Common Workflows

### Deploy New Code
```bash
cd ~/echomate
git pull origin master
./update.sh
pm2 logs
```

### Check System Health
```bash
./health-check.sh
pm2 status
sudo systemctl status nginx
sudo systemctl status mongod
```

### Create Backup
```bash
./backup.sh
ls -lh ~/backups/
```

### View Live Logs
```bash
# All logs
pm2 logs

# Backend only
pm2 logs echomate-backend

# Frontend only
pm2 logs echomate-frontend

# Nginx errors
sudo tail -f /var/log/nginx/error.log
```

### Restart Everything
```bash
sudo systemctl restart mongod
pm2 restart all
sudo systemctl reload nginx
```

---

## 📱 Application URLs

```
Frontend:  http://yourdomain.com
           https://yourdomain.com (with SSL)
           
Backend:   http://yourdomain.com/api
           
Direct:    http://localhost:3000 (frontend)
           http://localhost:5000 (backend)
```

---

## 🔑 Default Credentials

```
Email:    admin@echomate.com
Password: admin123

⚠️ Change these after first login!
```

---

## 🆘 Emergency Contacts

```bash
# View all running processes
pm2 list
ps aux | grep node

# Stop everything
pm2 stop all
sudo systemctl stop nginx

# Start everything
sudo systemctl start mongod
sudo systemctl start nginx
pm2 start ecosystem.config.js

# Nuclear option (full restart)
sudo reboot
```

---

## 📊 Performance Tuning

```bash
# Enable PM2 cluster mode
nano ecosystem.config.js
# Set: instances: 'max'

# Monitor performance
pm2 monit
htop

# Clear logs regularly
pm2 flush
```

---

**Keep this card handy for quick reference! 📌**
