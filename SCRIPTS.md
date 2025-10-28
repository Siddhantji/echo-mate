# 🚀 Deployment Scripts Overview

This directory contains all the automation scripts needed for deploying and managing EchoMateLite on AWS EC2.

## 📜 Available Scripts

### 1. `deploy.sh` - One-Click Full Deployment
**Purpose**: Complete application setup on fresh EC2 Ubuntu instance

**What it does**:
- Installs Node.js 20.x LTS
- Installs MongoDB 7.0
- Installs PM2 process manager
- Installs Nginx web server
- Creates environment files
- Installs project dependencies
- Builds backend and frontend
- Configures PM2 ecosystem
- Sets up Nginx reverse proxy
- Configures firewall (UFW)
- Starts applications
- Creates default user data

**Usage**:
```bash
chmod +x deploy.sh
./deploy.sh
```

**Duration**: ~10-15 minutes

**Requirements**: Fresh Ubuntu 22.04 EC2 instance

---

### 2. `setup-ssl.sh` - SSL Certificate Setup
**Purpose**: Install Let's Encrypt SSL certificate for HTTPS

**What it does**:
- Installs Certbot
- Obtains SSL certificate from Let's Encrypt
- Configures Nginx for HTTPS
- Sets up automatic certificate renewal

**Usage**:
```bash
chmod +x setup-ssl.sh
./setup-ssl.sh yourdomain.com
```

**Duration**: ~2-3 minutes

**Requirements**: 
- Domain name pointing to EC2 instance
- Port 80 and 443 open
- Nginx already installed

---

### 3. `update.sh` - Quick Update & Restart
**Purpose**: Update application after code changes

**What it does**:
- Pulls latest code from git
- Installs new dependencies
- Rebuilds backend and frontend
- Restarts PM2 applications
- Shows application status

**Usage**:
```bash
chmod +x update.sh
./update.sh
```

**Duration**: ~3-5 minutes

**When to use**: After pushing code changes to git repository

---

### 4. `backup.sh` - Database Backup
**Purpose**: Create MongoDB database backups

**What it does**:
- Creates MongoDB dump
- Compresses backup with tar.gz
- Stores in ~/backups directory
- Cleans old backups (keeps last 7 days)
- Shows backup summary

**Usage**:
```bash
chmod +x backup.sh
./backup.sh
```

**Duration**: ~1-2 minutes

**Schedule with cron** (daily at 2 AM):
```bash
crontab -e
# Add this line:
0 2 * * * /home/ubuntu/echomate/backup.sh
```

**Restore a backup**:
```bash
tar -xzf ~/backups/mongo-20250128_020000.tar.gz -C /tmp
mongorestore --db echomate /tmp/mongo-20250128_020000/echomate
```

---

### 5. `health-check.sh` - System Health Monitor
**Purpose**: Check if all services are running properly

**What it does**:
- Checks MongoDB status
- Checks Nginx status
- Checks PM2 processes
- Checks backend port accessibility
- Checks frontend port accessibility
- Checks API response
- Monitors disk space usage
- Monitors memory usage
- Provides troubleshooting suggestions

**Usage**:
```bash
chmod +x health-check.sh
./health-check.sh
```

**Duration**: ~5 seconds

**Schedule with cron** (every hour):
```bash
crontab -e
# Add this line:
0 * * * * /home/ubuntu/echomate/health-check.sh >> /home/ubuntu/health-check.log 2>&1
```

---

### 6. `ecosystem.config.js` - PM2 Configuration
**Purpose**: PM2 process manager configuration file

**What it defines**:
- Backend process configuration
- Frontend process configuration
- Log file locations
- Memory limits
- Auto-restart settings
- Environment variables

**Usage**: Automatically used by PM2
```bash
pm2 start ecosystem.config.js
pm2 restart ecosystem.config.js
```

**Modify for**:
- Changing number of instances (cluster mode)
- Adjusting memory limits
- Changing log paths
- Adding environment variables

---

## 🎯 Typical Deployment Workflow

### Initial Deployment (Day 1)

1. **Setup EC2 Instance**
   ```bash
   # Create Ubuntu 22.04 EC2 instance
   # Configure Security Groups (ports 22, 80, 443)
   # SSH into instance
   ssh -i key.pem ubuntu@ec2-ip-address
   ```

2. **Clone & Deploy**
   ```bash
   git clone https://github.com/yourusername/echomate.git
   cd echomate
   nano deploy.sh  # Set your domain/IP
   chmod +x *.sh
   ./deploy.sh
   ```

3. **Setup SSL (if using domain)**
   ```bash
   ./setup-ssl.sh yourdomain.com
   ```

4. **Setup Automated Backups**
   ```bash
   crontab -e
   # Add: 0 2 * * * /home/ubuntu/echomate/backup.sh
   ```

5. **Setup Health Monitoring**
   ```bash
   crontab -e
   # Add: 0 * * * * /home/ubuntu/echomate/health-check.sh >> /home/ubuntu/health-check.log
   ```

---

### Regular Updates (Ongoing)

1. **Make code changes locally**
2. **Commit and push to git**
   ```bash
   git add .
   git commit -m "Your changes"
   git push origin master
   ```

3. **SSH to EC2 and update**
   ```bash
   ssh -i key.pem ubuntu@ec2-ip-address
   cd echomate
   ./update.sh
   ```

---

### Monitoring & Maintenance

**Daily Health Check**:
```bash
./health-check.sh
```

**View Logs**:
```bash
pm2 logs                    # All logs
pm2 logs echomate-backend   # Backend only
pm2 logs echomate-frontend  # Frontend only
```

**Create Manual Backup**:
```bash
./backup.sh
```

**Check Application Status**:
```bash
pm2 status
pm2 monit  # Interactive monitoring
```

---

## 🔧 Customization

### Modify Domain/IP

Edit `deploy.sh`:
```bash
DOMAIN="your-domain.com"
```

### Change Ports

Edit `deploy.sh`:
```bash
BACKEND_PORT=5000
FRONTEND_PORT=3000
```

Then regenerate environment files and restart.

### Enable Cluster Mode (Multiple Instances)

Edit `ecosystem.config.js`:
```javascript
{
  name: 'echomate-backend',
  instances: 2,  // or 'max' for CPU cores
  exec_mode: 'cluster',
}
```

Restart:
```bash
pm2 restart ecosystem.config.js
```

### Adjust Memory Limits

Edit `ecosystem.config.js`:
```javascript
max_memory_restart: '1G',  // Default is 500M
```

### Change Backup Retention

Edit `backup.sh`:
```bash
RETENTION_DAYS=30  # Default is 7
```

---

## 📊 Monitoring Dashboard

**PM2 Web Interface**:
```bash
pm2 web
# Access at http://your-server:9615
```

**Real-time Monitoring**:
```bash
pm2 monit  # Interactive CPU/Memory monitoring
```

**View Metrics**:
```bash
pm2 describe echomate-backend
```

---

## 🆘 Troubleshooting

### Application Won't Start

```bash
# Check PM2 status
pm2 status

# View logs
pm2 logs

# Restart
pm2 restart all

# If still failing, check individual services
sudo systemctl status mongod
sudo systemctl status nginx
```

### MongoDB Connection Issues

```bash
# Check MongoDB status
sudo systemctl status mongod

# Restart MongoDB
sudo systemctl restart mongod

# View MongoDB logs
sudo tail -f /var/log/mongodb/mongod.log
```

### Nginx 502 Bad Gateway

```bash
# Check if apps are running
pm2 status

# Restart apps
pm2 restart all

# Check Nginx config
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

### Out of Disk Space

```bash
# Check disk usage
df -h

# Clean up
sudo apt clean
sudo apt autoremove
pm2 flush  # Clear PM2 logs

# Remove old backups
find ~/backups -name "*.tar.gz" -mtime +7 -delete
```

### High Memory Usage

```bash
# Check memory
free -h

# Monitor processes
pm2 monit

# Reduce PM2 instances in ecosystem.config.js
# or increase EC2 instance size
```

---

## 📚 Additional Resources

- [Complete Deployment Guide](./DEPLOYMENT.md)
- [Main README](./README.md)
- [PM2 Documentation](https://pm2.keymetrics.io/docs/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [MongoDB Documentation](https://docs.mongodb.com/)

---

## ✅ Pre-flight Checklist

Before running `deploy.sh`:

- [ ] EC2 instance running Ubuntu 22.04
- [ ] Security group allows ports 22, 80, 443
- [ ] SSH access working
- [ ] Repository cloned to instance
- [ ] `DOMAIN` variable updated in deploy.sh
- [ ] All scripts have execute permission (`chmod +x *.sh`)

After deployment:

- [ ] Application accessible in browser
- [ ] Can login with default credentials
- [ ] PM2 processes running (`pm2 status`)
- [ ] Nginx serving requests (`sudo systemctl status nginx`)
- [ ] MongoDB running (`sudo systemctl status mongod`)
- [ ] SSL certificate installed (if applicable)
- [ ] Backups configured (cron job)
- [ ] Health checks configured (cron job)

---

**Need help?** Check the logs:
```bash
pm2 logs                           # Application logs
sudo tail -f /var/log/nginx/error.log   # Nginx logs
sudo tail -f /var/log/mongodb/mongod.log  # MongoDB logs
```

🎉 Happy Deploying!
