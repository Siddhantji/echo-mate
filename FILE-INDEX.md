# 📚 EchoMateLite - Complete File Index

## 🚀 Deployment & Configuration Files

### Shell Scripts (.sh)

| File | Purpose | Usage |
|------|---------|-------|
| `deploy.sh` | One-click full deployment on EC2 Ubuntu | `./deploy.sh` |
| `setup-ssl.sh` | Install Let's Encrypt SSL certificate | `./setup-ssl.sh yourdomain.com` |
| `update.sh` | Quick update after code changes | `./update.sh` |
| `backup.sh` | Automated MongoDB backup | `./backup.sh` |
| `health-check.sh` | System health monitoring | `./health-check.sh` |
| `verify-system.sh` | Pre-deployment verification | `./verify-system.sh` |

**Make executable**: `chmod +x *.sh`

---

### Configuration Files

| File | Purpose | Location |
|------|---------|----------|
| `ecosystem.config.js` | PM2 process manager configuration | Root directory |
| `.gitignore` | Git ignore patterns | Root directory |
| `package.json` | Backend dependencies | `/backend/package.json` |
| `package.json` | Frontend dependencies | `/frontend/package.json` |
| `tsconfig.json` | TypeScript config (backend) | `/backend/tsconfig.json` |
| `tsconfig.json` | TypeScript config (frontend) | `/frontend/tsconfig.json` |
| `next.config.ts` | Next.js configuration | `/frontend/next.config.ts` |

---

### Documentation Files

| File | Description | Key Content |
|------|-------------|-------------|
| `README.md` | Main project documentation | Features, tech stack, setup instructions |
| `DEPLOYMENT.md` | Complete deployment guide | EC2 setup, SSL, monitoring, troubleshooting |
| `SCRIPTS.md` | All deployment scripts explained | Script details, workflows, customization |
| `QUICK-REFERENCE.md` | Command reference card | Common commands, workflows, troubleshooting |
| `INTERIM_REPORT.md` | Interim project report | Project progress, milestones |
| `PROJECT_SYNOPSIS.md` | Project synopsis | Project overview, objectives |
| `finalreport.txt` | Final MCA project report | Complete academic report |

---

## 📁 Project Structure

```
echomate/
├── 📄 Deployment Scripts
│   ├── deploy.sh                 # Main deployment script
│   ├── setup-ssl.sh             # SSL setup
│   ├── update.sh                # Quick update
│   ├── backup.sh                # Database backup
│   ├── health-check.sh          # Health monitoring
│   └── verify-system.sh         # Pre-deployment check
│
├── 📄 Configuration
│   ├── ecosystem.config.js      # PM2 configuration
│   └── .gitignore              # Git ignore rules
│
├── 📚 Documentation
│   ├── README.md               # Main documentation
│   ├── DEPLOYMENT.md           # Deployment guide
│   ├── SCRIPTS.md              # Scripts documentation
│   ├── QUICK-REFERENCE.md      # Command reference
│   ├── INTERIM_REPORT.md       # Interim report
│   ├── PROJECT_SYNOPSIS.md     # Project synopsis
│   └── finalreport.txt         # Final report
│
├── 🔧 Backend (Express.js + MongoDB)
│   ├── package.json
│   ├── tsconfig.json
│   ├── .env                    # Environment variables (create this)
│   └── src/
│       ├── index.ts            # Entry point
│       ├── middleware/
│       │   └── auth.ts         # JWT authentication
│       ├── models/
│       │   ├── User.ts         # User schema
│       │   └── Post.ts         # Post schema
│       ├── routes/
│       │   ├── auth.ts         # Authentication routes
│       │   ├── users.ts        # User routes
│       │   └── posts.ts        # Post routes
│       └── scripts/
│           └── createDefaultData.ts  # Seed data
│
└── 🎨 Frontend (Next.js + React)
    ├── package.json
    ├── tsconfig.json
    ├── next.config.ts
    ├── .env.local              # Environment variables (create this)
    ├── public/                 # Static assets
    └── src/
        ├── app/
        │   ├── globals.css     # Global styles
        │   ├── layout.tsx      # Root layout
        │   └── page.tsx        # Home page
        ├── components/
        │   ├── AuthPage.tsx    # Login/Register
        │   ├── Dashboard.tsx   # Main dashboard
        │   └── ProfileModal.tsx # Profile editor
        ├── contexts/
        │   └── AuthContext.tsx # Auth state management
        ├── lib/
        │   └── api.ts          # API client
        └── types/
            └── index.ts        # TypeScript types
```

---

## 🎯 Quick Start Guide

### For Local Development

1. **Clone Repository**
   ```bash
   git clone https://github.com/yourusername/echomate.git
   cd echomate
   ```

2. **Setup Backend**
   ```bash
   cd backend
   npm install
   # Create .env with MongoDB connection string
   npm run dev
   ```

3. **Setup Frontend**
   ```bash
   cd frontend
   npm install
   # Create .env.local with API URL
   npm run dev
   ```

### For EC2 Production Deployment

1. **SSH to EC2**
   ```bash
   ssh -i key.pem ubuntu@your-ec2-ip
   ```

2. **Clone & Verify**
   ```bash
   git clone https://github.com/yourusername/echomate.git
   cd echomate
   chmod +x *.sh
   ./verify-system.sh
   ```

3. **Configure & Deploy**
   ```bash
   nano deploy.sh  # Set DOMAIN variable
   ./deploy.sh
   ```

4. **Setup SSL (Optional)**
   ```bash
   ./setup-ssl.sh yourdomain.com
   ```

---

## 📦 What Gets Created During Deployment

### Installed Software
- Node.js 20.x LTS
- MongoDB 7.0
- PM2 (global npm package)
- Nginx web server
- UFW firewall
- Certbot (if SSL setup)

### Created Files
- `backend/.env` - Backend environment variables
- `frontend/.env.local` - Frontend environment variables
- `logs/` - Directory for PM2 logs
- `/etc/nginx/sites-available/echomate` - Nginx configuration
- `/etc/systemd/system/pm2-*.service` - PM2 startup service

### Created Directories
- `~/backups/` - Database backups
- `logs/` - Application logs
- `node_modules/` - Dependencies (backend & frontend)
- `backend/dist/` - Compiled TypeScript
- `frontend/.next/` - Next.js build

---

## 🔧 Environment Variables

### Backend (.env)
```env
PORT=5000
NODE_ENV=production
MONGODB_URI=mongodb://localhost:27017/echomate
JWT_SECRET=<auto-generated>
JWT_EXPIRE=7d
FRONTEND_URL=http://yourdomain.com
```

### Frontend (.env.local)
```env
NEXT_PUBLIC_API_URL=http://yourdomain.com/api
```

---

## 📊 Service Ports

| Service | Port | Description |
|---------|------|-------------|
| Frontend | 3000 | Next.js app (internal) |
| Backend | 5000 | Express API (internal) |
| MongoDB | 27017 | Database (internal) |
| Nginx HTTP | 80 | Public web server |
| Nginx HTTPS | 443 | Public web server (SSL) |
| SSH | 22 | Server access |

**Note**: Only ports 22, 80, 443 should be exposed in EC2 Security Group.

---

## 🎛️ PM2 Applications

| Name | Script | Port | Directory |
|------|--------|------|-----------|
| echomate-backend | `npm start` | 5000 | `./backend` |
| echomate-frontend | `npm start` | 3000 | `./frontend` |

View with: `pm2 status`

---

## 📝 Log Files

### Application Logs (PM2)
- `logs/backend-error.log` - Backend errors
- `logs/backend-out.log` - Backend output
- `logs/frontend-error.log` - Frontend errors
- `logs/frontend-out.log` - Frontend output

### System Logs
- `/var/log/nginx/access.log` - Nginx access
- `/var/log/nginx/error.log` - Nginx errors
- `/var/log/mongodb/mongod.log` - MongoDB logs

---

## 🔐 Security Configuration

### Firewall (UFW)
```bash
Port 22   - SSH (your IP only, recommended)
Port 80   - HTTP (0.0.0.0/0)
Port 443  - HTTPS (0.0.0.0/0)
```

### Nginx Security Headers
- X-Frame-Options: SAMEORIGIN
- X-Content-Type-Options: nosniff
- X-XSS-Protection: 1; mode=block
- Referrer-Policy: no-referrer-when-downgrade

### Rate Limiting
- API: 10 requests/second (burst: 20)
- General: 30 requests/second

---

## 🔄 Update Workflow

1. **Make Changes Locally**
2. **Commit & Push**
   ```bash
   git add .
   git commit -m "Your changes"
   git push origin master
   ```
3. **Deploy to EC2**
   ```bash
   ssh ubuntu@your-ec2-ip
   cd echomate
   ./update.sh
   ```

---

## 💾 Backup Strategy

### Automated Backups
```bash
# Add to crontab
crontab -e

# Daily backup at 2 AM
0 2 * * * /home/ubuntu/echomate/backup.sh
```

### Manual Backup
```bash
./backup.sh
```

### Backup Location
```
~/backups/mongo-YYYYMMDD_HHMMSS.tar.gz
```

**Retention**: 7 days (configurable)

---

## 🆘 Troubleshooting Resources

### Check Health
```bash
./health-check.sh
```

### View Logs
```bash
pm2 logs                    # All application logs
sudo tail -f /var/log/nginx/error.log  # Nginx errors
```

### Common Issues
See `DEPLOYMENT.md` Section: Troubleshooting

### Quick Reference
See `QUICK-REFERENCE.md` for all commands

---

## 📞 Support & Resources

### Documentation Files
1. `README.md` - Start here
2. `DEPLOYMENT.md` - Deployment details
3. `SCRIPTS.md` - Script documentation
4. `QUICK-REFERENCE.md` - Command cheatsheet

### External Resources
- [PM2 Documentation](https://pm2.keymetrics.io/docs/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [Next.js Documentation](https://nextjs.org/docs)

---

## ✅ Deployment Checklist

Before deploying:
- [ ] EC2 instance ready (Ubuntu 22.04)
- [ ] Security groups configured
- [ ] Domain/DNS configured (optional)
- [ ] Repository cloned
- [ ] Scripts executable (`chmod +x *.sh`)
- [ ] Run `./verify-system.sh`

After deploying:
- [ ] Application accessible
- [ ] SSL configured (if applicable)
- [ ] Default password changed
- [ ] Backups configured
- [ ] Monitoring configured

---

## 📈 Next Steps After Deployment

1. **Change Default Credentials**
   - Login with admin@echomate.com / admin123
   - Update password immediately

2. **Setup Automated Backups**
   ```bash
   crontab -e
   0 2 * * * /home/ubuntu/echomate/backup.sh
   ```

3. **Setup Health Monitoring**
   ```bash
   crontab -e
   0 * * * * /home/ubuntu/echomate/health-check.sh >> ~/health.log
   ```

4. **Configure Domain/DNS**
   - Point your domain to EC2 IP
   - Update `deploy.sh` DOMAIN variable
   - Run `./setup-ssl.sh yourdomain.com`

5. **Monitor Application**
   ```bash
   pm2 monit
   ./health-check.sh
   ```

---

**🎉 You're all set! Happy deploying!**

For questions or issues, refer to the documentation files listed above.
