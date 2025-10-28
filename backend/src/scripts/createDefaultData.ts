import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import User from '../models/User';
import Post from '../models/Post';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const defaultUsers = [
  {
    username: 'admin',
    email: 'admin@echomate.com',
    password: 'admin123',
    fullName: 'Admin User',
    bio: 'Platform administrator and community manager. Welcome to EchoMateLite!',
  },
  {
    username: 'johndoe',
    email: 'john@example.com',
    password: 'password123',
    fullName: 'John Doe',
    bio: 'Tech enthusiast and developer. Love coding and sharing knowledge with the community.',
  },
  {
    username: 'jansmith',
    email: 'jane@example.com',
    password: 'password123',
    fullName: 'Jane Smith',
    bio: 'Designer and creative thinker. Passionate about user experience and beautiful interfaces.',
  },
  {
    username: 'miketech',
    email: 'mike@example.com',
    password: 'password123',
    fullName: 'Mike Johnson',
    bio: 'Full-stack developer and AWS enthusiast. Building the future one app at a time.',
  },
  {
    username: 'sarahdev',
    email: 'sarah@example.com',
    password: 'password123',
    fullName: 'Sarah Wilson',
    bio: 'Frontend developer specializing in React and modern web technologies.',
  }
];

const defaultPosts = [
  {
    content: "Welcome to EchoMateLite! 🎉 This is our new social media platform built with Next.js and Express. Looking forward to connecting with everyone!",
    authorUsername: 'admin'
  },
  {
    content: "Just finished implementing the authentication system. JWT tokens and bcrypt hashing working perfectly! #WebDev #Security",
    authorUsername: 'johndoe'
  },
  {
    content: "The UI design for EchoMateLite is coming together nicely. Tailwind CSS makes responsive design so much easier! 🎨",
    authorUsername: 'jansmith'
  },
  {
    content: "Deployed my first app on AWS today! EC2, S3, and DocumentDB working in harmony. Cloud computing is amazing! ☁️",
    authorUsername: 'miketech'
  },
  {
    content: "TypeScript + React is such a powerful combination. Type safety makes development so much more reliable! 💻",
    authorUsername: 'sarahdev'
  },
  {
    content: "The real-time features in EchoMateLite are working great. Likes and comments update instantly! ⚡",
    authorUsername: 'johndoe'
  },
  {
    content: "Love how clean and intuitive the interface is. Great job on the UX design team! 👍",
    authorUsername: 'miketech'
  },
  {
    content: "MongoDB Atlas integration is seamless. Cloud databases make scaling so much easier! 🚀",
    authorUsername: 'sarahdev'
  }
];

async function createDefaultData() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/echomate');
    console.log('Connected to MongoDB');

    // Clear existing data
    await User.deleteMany({});
    await Post.deleteMany({});
    console.log('Cleared existing data');

    // Create users
    const createdUsers: any[] = [];
    
    for (const userData of defaultUsers) {
      const user = new User({
        username: userData.username,
        email: userData.email,
        password: userData.password, // Let the pre-save hook handle hashing
        fullName: userData.fullName,
        bio: userData.bio
      });

      const savedUser = await user.save();
      createdUsers.push(savedUser);
      console.log(`Created user: ${userData.username}`);
    }

    // Create some follow relationships
    const admin = createdUsers.find(u => u.username === 'admin');
    const john = createdUsers.find(u => u.username === 'johndoe');
    const jane = createdUsers.find(u => u.username === 'jansmith');
    const mike = createdUsers.find(u => u.username === 'miketech');
    const sarah = createdUsers.find(u => u.username === 'sarahdev');

    // Admin follows everyone
    admin.following = [john._id, jane._id, mike._id, sarah._id];
    await admin.save();

    // Everyone follows admin
    john.following.push(admin._id);
    jane.following.push(admin._id);
    mike.following.push(admin._id);
    sarah.following.push(admin._id);

    // Cross follows
    john.following.push(jane._id, sarah._id);
    jane.following.push(john._id, mike._id);
    mike.following.push(jane._id, sarah._id);
    sarah.following.push(john._id, mike._id);

    // Update followers
    admin.followers = [john._id, jane._id, mike._id, sarah._id];
    john.followers = [admin._id, jane._id, sarah._id];
    jane.followers = [admin._id, john._id, mike._id];
    mike.followers = [admin._id, jane._id, sarah._id];
    sarah.followers = [admin._id, john._id, mike._id];

    await Promise.all([john.save(), jane.save(), mike.save(), sarah.save(), admin.save()]);
    console.log('Created follow relationships');

    // Create posts
    for (const postData of defaultPosts) {
      const author = createdUsers.find(u => u.username === postData.authorUsername);
      
      const post = new Post({
        author: author._id,
        content: postData.content,
        likes: [], // Start with no likes
        comments: []
      });

      await post.save();
      console.log(`Created post by ${postData.authorUsername}`);
    }

    // Add some likes to posts randomly
    const posts = await Post.find().populate('author');
    for (const post of posts) {
      const randomUsers = createdUsers.sort(() => 0.5 - Math.random()).slice(0, Math.floor(Math.random() * 3) + 1);
      post.likes = randomUsers.map(u => u._id);
      await post.save();
    }

    console.log('\n🎉 Default data created successfully!');
    console.log('\n📝 Default Login Credentials:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('👑 Admin Account:');
    console.log('   Email: admin@echomate.com');
    console.log('   Password: admin123');
    console.log('');
    console.log('👤 Test Users:');
    console.log('   Email: john@example.com | Password: password123');
    console.log('   Email: jane@example.com | Password: password123');
    console.log('   Email: mike@example.com | Password: password123');
    console.log('   Email: sarah@example.com | Password: password123');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('\n✨ You can now login with any of these accounts!');

  } catch (error) {
    console.error('Error creating default data:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  }
}

// Run the script
createDefaultData();
