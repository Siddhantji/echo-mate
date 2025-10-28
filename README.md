# EchoMateLite - Social Media Platform

A lightweight social media platform built with Next.js, Express.js, and MongoDB for a college project. This platform demonstrates cloud deployment capabilities with AWS and includes essential social media features.

## 🚀 Features

### Core Functionality
- **User Authentication**: Secure registration and login system with JWT tokens
- **Profile Management**: Create and edit user profiles with basic information
- **Post Creation**: Share thoughts and updates with the community (280 character limit)
- **Social Feed**: View posts from all users on the public timeline
- **Personal Feed**: Follow other users and see their posts in your personal feed
- **Interactions**: Like posts and view engagement metrics
- **Responsive Design**: Mobile-friendly interface with Tailwind CSS

### Security Features
- Password hashing with bcrypt
- JWT-based authentication
- CORS protection
- Input validation and sanitization

## 🛠 Tech Stack

### Frontend
- **Next.js 15** - React framework with App Router
- **TypeScript** - Type safety and better development experience
- **Tailwind CSS** - Utility-first CSS framework
- **React Hook Form** - Form validation and handling
- **Zod** - Schema validation
- **Axios** - HTTP client for API calls
- **Lucide React** - Beautiful icons

### Backend
- **Node.js** - JavaScript runtime
- **Express.js** - Web framework
- **TypeScript** - Type safety
- **MongoDB** - NoSQL database
- **Mongoose** - MongoDB object modeling
- **JWT** - JSON Web Tokens for authentication
- **bcrypt** - Password hashing
- **CORS** - Cross-origin resource sharing
- **Multer** - File upload handling

## 📋 Prerequisites

Before running this project, make sure you have the following installed:

- **Node.js** (v18 or higher)
- **npm** or **yarn**
- **MongoDB** (local installation or MongoDB Atlas)
- **Git**

## 🚀 Getting Started

### 1. Clone the Repository
\`\`\`bash
git clone <repository-url>
cd echo-mate
\`\`\`

### 2. Setup Backend

\`\`\`bash
cd backend
npm install
\`\`\`

Create a \`.env\` file in the backend directory:
\`\`\`env
MONGODB_URI=mongodb://localhost:27017/echomate
JWT_SECRET=your_jwt_secret_key_change_this_in_production
PORT=5000
NODE_ENV=development
CORS_ORIGIN=http://localhost:3000
\`\`\`

### 3. Setup Frontend

\`\`\`bash
cd frontend
npm install
\`\`\`

Create a \`.env.local\` file in the frontend directory:
\`\`\`env
NEXT_PUBLIC_API_URL=http://localhost:5000/api
\`\`\`

### 4. Start MongoDB

Make sure MongoDB is running on your local machine:
\`\`\`bash
# If installed via Homebrew (macOS)
brew services start mongodb-community

# If installed via package manager (Linux)
sudo systemctl start mongod

# If using MongoDB Compass or Atlas, ensure your connection string is correct
\`\`\`

### 5. Run the Application

#### Option 1: Using VS Code Tasks (Recommended)
1. Open the project in VS Code
2. Press \`Ctrl+Shift+P\` (or \`Cmd+Shift+P\` on macOS)
3. Type "Tasks: Run Task"
4. Select "Start Full Stack" to run both frontend and backend

#### Option 2: Manual Setup
Open two terminal windows:

**Terminal 1 (Backend):**
\`\`\`bash
cd backend
npm run dev
\`\`\`

**Terminal 2 (Frontend):**
\`\`\`bash
cd frontend
npm run dev
\`\`\`

### 6. Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000
- **API Health Check**: http://localhost:5000/api/health

## 📝 API Documentation

### Authentication Endpoints
- \`POST /api/auth/register\` - Register a new user
- \`POST /api/auth/login\` - Login user
- \`GET /api/auth/me\` - Get current user info

### User Endpoints
- \`GET /api/users/profile/:username\` - Get user profile
- \`PUT /api/users/profile\` - Update user profile
- \`POST /api/users/follow/:userId\` - Follow/unfollow user
- \`GET /api/users/search?q=query\` - Search users

### Post Endpoints
- \`POST /api/posts\` - Create a new post
- \`GET /api/posts/feed\` - Get personalized feed
- \`GET /api/posts/timeline\` - Get public timeline
- \`GET /api/posts/user/:username\` - Get user's posts
- \`POST /api/posts/:postId/like\` - Like/unlike a post
- \`POST /api/posts/:postId/comment\` - Add comment to post
- \`DELETE /api/posts/:postId\` - Delete a post

## 🏗 Project Structure

\`\`\`
echo-mate/
├── backend/                 # Express.js backend
│   ├── src/
│   │   ├── models/         # MongoDB models
│   │   ├── routes/         # API routes
│   │   ├── middleware/     # Authentication middleware
│   │   └── index.ts        # Server entry point
│   ├── .env                # Environment variables
│   └── package.json
├── frontend/               # Next.js frontend
│   ├── src/
│   │   ├── app/           # Next.js app directory
│   │   ├── components/    # React components
│   │   ├── contexts/      # React contexts
│   │   ├── lib/          # Utility functions
│   │   └── types/        # TypeScript type definitions
│   ├── .env.local        # Environment variables
│   └── package.json
└── README.md
\`\`\`

## 🌙 Development Features

- **Hot Reload**: Both frontend and backend support hot reloading
- **TypeScript**: Full type safety across the entire stack
- **ESLint**: Code linting for consistency
- **Prettier**: Code formatting (can be added)
- **Error Handling**: Comprehensive error handling and validation

## 🚀 Deployment (AWS)

This project is designed to be deployed on AWS. Here are the recommended services:

### Frontend (Next.js)
- **AWS Amplify** or **Vercel** for easy deployment
- **Amazon S3 + CloudFront** for static hosting

### Backend (Express.js)
- **Amazon EC2** for server hosting
- **AWS Elastic Beanstalk** for managed deployment
- **Amazon ECS** with Docker containers

### Database
- **Amazon DocumentDB** (MongoDB-compatible)
- **MongoDB Atlas** (cloud MongoDB service)

### Additional AWS Services
- **AWS Route 53** for domain management
- **AWS Certificate Manager** for SSL certificates
- **Amazon CloudWatch** for monitoring
- **AWS IAM** for access management

## 🔒 Security Considerations

- JWT tokens expire after 7 days
- Passwords are hashed using bcrypt with salt rounds
- Input validation on both client and server
- CORS configured for frontend domain
- Environment variables for sensitive data

## 🤝 Contributing

This is a college project, but contributions are welcome:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the ISC License.

## 🆘 Troubleshooting

### Common Issues

1. **MongoDB Connection Error**
   - Ensure MongoDB is running
   - Check the connection string in \`.env\`
   - For MongoDB Atlas, whitelist your IP address

2. **Port Already in Use**
   - Change the port in the environment variables
   - Kill the process using the port: \`lsof -ti:5000 | xargs kill\`

3. **CORS Errors**
   - Ensure the frontend URL is correctly set in backend CORS configuration
   - Check that API URLs match in frontend environment variables

4. **Authentication Issues**
   - Clear browser local storage
   - Check JWT secret consistency
   - Verify token expiration

## 📞 Support

For questions or issues related to this college project, please create an issue in the repository or contact the development team.

---

**EchoMateLite** - A lightweight social media platform showcasing modern web development practices and cloud deployment readiness. 🚀
