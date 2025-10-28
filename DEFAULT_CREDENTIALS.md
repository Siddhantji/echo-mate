# Default Credentials for EchoMateLite

## 🚀 Quick Start

To populate your database with default users and posts, run:

```bash
cd backend
npm run seed
```

## 👤 Default Login Credentials

### Admin Account
- **Email:** `admin@echomate.com`
- **Password:** `admin123`
- **Role:** Platform administrator with full access

### Test User Accounts
| Name | Email | Password | Username |
|------|--------|----------|----------|
| John Doe | `john@example.com` | `password123` | `johndoe` |
| Jane Smith | `jane@example.com` | `password123` | `jansmith` |
| Mike Johnson | `mike@example.com` | `password123` | `miketech` |
| Sarah Wilson | `sarah@example.com` | `password123` | `sarahdev` |

## 📝 What Gets Created

### Users
- 5 default users with complete profiles
- Pre-established follow relationships between users
- Realistic bio information for each user

### Posts
- 8 sample posts covering various topics
- Posts from different users showing platform diversity
- Random likes distribution across posts

### Social Connections
- Admin follows all users
- All users follow admin
- Cross-following relationships between users
- Realistic social network structure

## 🔄 Reset Database

To reset and recreate the default data:

```bash
npm run seed
```

This will:
1. Clear all existing users and posts
2. Create fresh default accounts
3. Establish new social connections
4. Generate sample content

## 🛡️ Security Notes

⚠️ **Important:** These are development credentials only!

- Change all passwords before production deployment
- Use strong, unique passwords for real users
- The admin account should be secured or removed in production
- Consider using environment variables for admin credentials

## 📱 Testing the Platform

1. **Login as Admin:** Use admin credentials to see full platform functionality
2. **Test User Interactions:** Login as different users to test social features
3. **Follow/Unfollow:** Try following and unfollowing between accounts
4. **Create Posts:** Test post creation with different accounts
5. **Like Posts:** Test the like functionality across different users

## 🔧 Customization

To modify default data, edit:
- `backend/src/scripts/createDefaultData.ts`
- Add more users, posts, or modify relationships
- Run `npm run seed` after changes to apply them
