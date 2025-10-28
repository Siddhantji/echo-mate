# 🚀 EchoMateLite - EC2 Deployment Guide

Complete guide for deploying EchoMateLite on AWS EC2 Ubuntu with PM2 and Nginx.

## 📋 Prerequisites

### AWS EC2 Instance Requirements
- **OS**: Ubuntu 22.04 LTS
- **Instance Type**: t2.micro or larger (minimum 1GB RAM)
- **Storage**: 20GB minimum
- **Security Group Rules**:
  - SSH (Port 22) - Your IP
  - HTTP (Port 80) - Anywhere (0.0.0.0/0)
  - HTTPS (Port 443) - Anywhere (0.0.0.0/0)

### Before You Start
- EC2 instance running Ubuntu 22.04
- SSH access to the instance
- (Optional) Domain name pointing to EC2 public IP

---

## 🎯 One-Click Deployment

### Step 1: Connect to Your EC2 Instance

```bash
ssh -i your-key.pem ubuntu@your-ec2-public-ip
```

### Step 2: Clone the Repository

```bash
# Install git if not present
sudo apt update && sudo apt install -y git

# Clone your repository
git clone https://github.com/yourusername/echomate.git
cd echomate
```

### Step 3: Configure Domain/IP

Edit the deployment script to set your domain or EC2 public IP:

```bash
nano deploy.sh
```

Change this line:
```bash
DOMAIN="your-domain.com"  # Change to your domain or EC2 IP
```

To:
```bash
DOMAIN="ec2-54-123-45-67.compute-1.amazonaws.com"  # Your EC2 public DNS
# OR
DOMAIN="yourdomain.com"  # Your custom domain
```

Save and exit (Ctrl+X, Y, Enter)

### Step 4: Make Script Executable

```bash
chmod +x deploy.sh
chmod +x setup-ssl.sh
```

### Step 5: Run Deployment Script

```bash
./deploy.sh
```

This script will:
- ✅ Update system packages
- ✅ Install Node.js 20.x LTS
- ✅ Install MongoDB 7.0
- ✅ Install PM2 process manager
- ✅ Install Nginx web server
- ✅ Create environment files
- ✅ Install all project dependencies
- ✅ Build backend TypeScript
- ✅ Build frontend Next.js
- ✅ Configure PM2 with ecosystem file
- ✅ Configure Nginx reverse proxy
- ✅ Setup firewall (UFW)
- ✅ Start applications
- ✅ Create default user data

**Total Time**: ~10-15 minutes

---

## 🔐 Setup SSL Certificate (Optional but Recommended)

After successful deployment, set up HTTPS:

```bash
./setup-ssl.sh yourdomain.com
```

This will:
- Install Certbot
- Obtain Let's Encrypt SSL certificate
- Configure Nginx for HTTPS
- Setup auto-renewal

---

## 📱 Access Your Application

### Without SSL (HTTP)
```
http://your-domain.com
http://your-ec2-public-ip
```

### With SSL (HTTPS)
```
https://your-domain.com
```

### Default Login Credentials
```
Email: admin@echomate.com
Password: admin123
```

**⚠️ IMPORTANT**: Change the default password after first login!

---

## 🛠️ Post-Deployment Management

### PM2 Commands

```bash
# View application status
pm2 status

# View logs (real-time)
pm2 logs

# View logs for specific app
pm2 logs echomate-backend
pm2 logs echomate-frontend

# Restart applications
pm2 restart all
pm2 restart echomate-backend
pm2 restart echomate-frontend

# Stop applications
pm2 stop all

# Start applications
pm2 start ecosystem.config.js

# Monitor applications (interactive dashboard)
pm2 monit

# Save PM2 process list
pm2 save

# View detailed info
pm2 info echomate-backend
```

### Nginx Commands

```bash
# Test configuration
sudo nginx -t

# Reload configuration (no downtime)
sudo systemctl reload nginx

# Restart Nginx
sudo systemctl restart nginx

# Check status
sudo systemctl status nginx

# View error logs
sudo tail -f /var/log/nginx/error.log

# View access logs
sudo tail -f /var/log/nginx/access.log
```

### MongoDB Commands

```bash
# Connect to MongoDB shell
mongosh

# Check status
sudo systemctl status mongod

# Restart MongoDB
sudo systemctl restart mongod

# Stop MongoDB
sudo systemctl stop mongod

# Start MongoDB
sudo systemctl start mongod

# View logs
sudo tail -f /var/log/mongodb/mongod.log
```

---

## 🔄 Update/Redeploy Application

When you push code changes:

```bash
# Pull latest changes
git pull origin master

# Backend updates
cd backend
npm install  # If package.json changed
npm run build
cd ..

# Frontend updates
cd frontend
npm install  # If package.json changed
npm run build
cd ..

# Restart applications
pm2 restart all
```

### Quick Restart Script

Create a file `update.sh`:

```bash
#!/bin/bash
git pull origin master
cd backend && npm install && npm run build && cd ..
cd frontend && npm install && npm run build && cd ..
pm2 restart all
echo "Application updated and restarted!"
```

Make it executable:
```bash
chmod +x update.sh
./update.sh
```

---

## 🔍 Monitoring & Debugging

### Check Application Health

```bash
# Check if backend is responding
curl http://localhost:5000/api

# Check if frontend is responding
curl http://localhost:3000

# Check PM2 processes
pm2 list

# Check Nginx
sudo systemctl status nginx

# Check MongoDB
sudo systemctl status mongod
```

### View Application Logs

```bash
# PM2 logs (all apps)
pm2 logs

# Backend logs only
pm2 logs echomate-backend --lines 100

# Frontend logs only
pm2 logs echomate-frontend --lines 100

# Nginx error log
sudo tail -f /var/log/nginx/error.log

# MongoDB log
sudo tail -f /var/log/mongodb/mongod.log
```

### Common Issues

#### Issue: Application not starting

```bash
# Check PM2 logs
pm2 logs

# Check if ports are in use
sudo netstat -tulpn | grep :5000
sudo netstat -tulpn | grep :3000

# Restart PM2
pm2 restart all
```

#### Issue: MongoDB connection error

```bash
# Check MongoDB status
sudo systemctl status mongod

# Restart MongoDB
sudo systemctl restart mongod

# Check MongoDB logs
sudo tail -f /var/log/mongodb/mongod.log
```

#### Issue: Nginx 502 Bad Gateway

```bash
# Check if backend is running
pm2 status

# Restart applications
pm2 restart all

# Check Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

---

## 🔒 Security Best Practices

### 1. Change Default Credentials
After first login, change the default admin password.

### 2. Update JWT Secret
In `backend/.env`, update `JWT_SECRET` with a strong random value:
```bash
openssl rand -base64 32
```

### 3. Configure Firewall
```bash
# Check UFW status
sudo ufw status

# Allow only necessary ports
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 4. Keep System Updated
```bash
# Update packages regularly
sudo apt update && sudo apt upgrade -y

# Update Node.js packages
cd backend && npm update && cd ..
cd frontend && npm update && cd ..
```

### 5. Setup MongoDB Authentication
```bash
mongosh
use admin
db.createUser({
  user: "echomate_admin",
  pwd: "strong_password_here",
  roles: ["readWrite", "dbAdmin"]
})
```

Update `backend/.env`:
```
MONGODB_URI=mongodb://echomate_admin:strong_password_here@localhost:27017/echomate
```

---

## 📊 Performance Optimization

### Enable PM2 Cluster Mode

Edit `ecosystem.config.js`:

```javascript
{
  name: 'echomate-backend',
  instances: 2,  // Change from 1 to 2 or 'max'
  exec_mode: 'cluster',
  // ... other settings
}
```

Restart:
```bash
pm2 restart ecosystem.config.js
```

### Nginx Caching

Nginx is already configured with:
- Gzip compression
- Static file caching (1 year)
- Rate limiting

### MongoDB Indexing

```bash
mongosh
use echomate

# Create indexes for better performance
db.users.createIndex({ username: 1 })
db.users.createIndex({ email: 1 })
db.posts.createIndex({ createdAt: -1 })
db.posts.createIndex({ author: 1 })
```

---

## 💾 Backup & Recovery

### Backup MongoDB

```bash
# Create backup directory
mkdir -p ~/backups

# Backup database
mongodump --db echomate --out ~/backups/mongo-backup-$(date +%Y%m%d)

# Compress backup
cd ~/backups
tar -czf mongo-backup-$(date +%Y%m%d).tar.gz mongo-backup-$(date +%Y%m%d)
```

### Restore MongoDB

```bash
# Extract backup
tar -xzf mongo-backup-20250101.tar.gz

# Restore database
mongorestore --db echomate mongo-backup-20250101/echomate
```

### Automated Backup Script

Create `backup.sh`:

```bash
#!/bin/bash
BACKUP_DIR="$HOME/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup MongoDB
mongodump --db echomate --out $BACKUP_DIR/mongo-$DATE

# Compress
tar -czf $BACKUP_DIR/mongo-$DATE.tar.gz -C $BACKUP_DIR mongo-$DATE
rm -rf $BACKUP_DIR/mongo-$DATE

# Keep only last 7 backups
cd $BACKUP_DIR
ls -t mongo-*.tar.gz | tail -n +8 | xargs -r rm

echo "Backup completed: mongo-$DATE.tar.gz"
```

Schedule daily backups:
```bash
chmod +x backup.sh
crontab -e

# Add this line (backup at 2 AM daily)
0 2 * * * /home/ubuntu/echomate/backup.sh
```

---

## 📞 Support & Troubleshooting

### Get Help

If you encounter issues:

1. Check application logs: `pm2 logs`
2. Check Nginx logs: `sudo tail -f /var/log/nginx/error.log`
3. Check MongoDB logs: `sudo tail -f /var/log/mongodb/mongod.log`
4. Check system resources: `htop` or `free -h`

### Clean Restart

If things go wrong, clean restart:

```bash
# Stop all PM2 processes
pm2 stop all
pm2 delete all

# Restart MongoDB
sudo systemctl restart mongod

# Restart Nginx
sudo systemctl restart nginx

# Start applications
pm2 start ecosystem.config.js
pm2 save
```

---

## ✅ Deployment Checklist

- [ ] EC2 instance created with Ubuntu 22.04
- [ ] Security group configured (ports 22, 80, 443)
- [ ] SSH access working
- [ ] Repository cloned
- [ ] Domain/IP configured in `deploy.sh`
- [ ] Deployment script executed successfully
- [ ] Application accessible via browser
- [ ] SSL certificate installed (if using domain)
- [ ] Default password changed
- [ ] JWT secret updated
- [ ] MongoDB authentication configured
- [ ] Firewall enabled
- [ ] Backup script configured
- [ ] Monitoring setup (PM2, logs)

---

## 🎉 Success!

Your EchoMateLite application should now be running on EC2!

**Frontend**: http://your-domain.com  
**API**: http://your-domain.com/api

Enjoy your deployed application! 🚀
