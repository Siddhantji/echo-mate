A study on "EchoMateLite: A Lightweight Social Media Platform for Cloud Deployment"

A Project submitted to Jain Online (Deemed-to-be University)
In partial fulfillment of the requirements for the award of:
Master of Computer Application

Submitted by:
[Your Name Here]

USN: [Your USN Here]

Under the guidance of:
[Your Guide's Name]
(Faculty-JAIN Online)

Jain Online (Deemed-to-be University)
Bangalore
2024-25

DECLARATION

I, [Your Name], hereby declare that the Interim Project Report titled "EchoMateLite: A Lightweight Social Media Platform for Cloud Deployment" has been prepared by me under the guidance of [Faculty Name]. I declare that this Project work is towards the partial fulfillment of the University Regulations for the award of the degree of Master of Computer Application by Jain University, Bengaluru. I have undergone a project for a period of Eight Weeks. I further declare that this Project is based on the original study undertaken by me and has not been submitted for the award of any degree/diploma from any other University / Institution.

Place: [Your City]                                        ______________________
Date: [Current Date]                                     [Your Name]
                                                        USN: [Your USN]

EXECUTIVE SUMMARY

EchoMateLite is a comprehensive social media platform developed as a college project to demonstrate modern web development practices and cloud deployment capabilities using AWS infrastructure. The project addresses the growing need for students to gain hands-on experience with full-stack development, cloud services, and scalable application architecture.

The platform implements core social media functionalities including secure user authentication, profile management, post creation and interaction, real-time content feeds, and social networking features. Built using the MERN stack with Next.js for frontend and Express.js with MongoDB for backend, the application showcases industry-standard development practices including TypeScript implementation, JWT-based authentication, password hashing with bcrypt, and responsive design using Tailwind CSS.

The project is specifically designed for AWS deployment, utilizing services such as Amazon EC2 for application hosting, Amazon DocumentDB for database management, Amazon S3 for static file storage, and Amazon CloudFront for content delivery. The architecture demonstrates cost-effective implementation strategies suitable for educational environments while maintaining professional-grade security and scalability standards.

TABLE OF CONTENTS

Title                               Page Nos.
Executive Summary                   i
List of Tables                      ii
List of Graphs                      iii
Chapter 1: Introduction             1-3
Chapter 2: Literature Review        4-11
Chapter 3: Solution Architecture    12-15
References                          16
Annexures                          17

List of Tables
Table No.   Table Title                         Page No.
1          Technology Stack Components          5
2          AWS Services Comparison              7
3          Feature Requirements Matrix          8
4          Cost Analysis Summary               14
5          Performance Metrics                 15

List of Graphs
Graph No.   Graph Title                        Page No.
1          Architecture Flow Diagram           12
2          AWS Services Integration            13
3          Cost Projection Analysis            14
4          User Interaction Flow               15

CHAPTER 1 - INTRODUCTION

1.1 Background Information of the Project

The digital landscape has transformed significantly with the rise of social media platforms, creating an unprecedented need for developers to understand the complexities of building scalable, secure, and interactive web applications. EchoMateLite emerges as an educational project designed to bridge the gap between theoretical knowledge and practical implementation in modern web development and cloud computing.

Social media platforms represent some of the most complex software systems, requiring expertise in user authentication, real-time data processing, scalable architecture, and cloud deployment. For computer science students, particularly those pursuing Master of Computer Application degrees, gaining hands-on experience with these technologies is crucial for career preparation and industry readiness.

The project addresses several critical learning objectives: understanding full-stack development methodologies, implementing secure authentication systems, designing scalable database schemas, creating responsive user interfaces, and deploying applications on cloud infrastructure. These skills are essential in today's technology-driven job market where cloud computing and social media technologies dominate the software development landscape.

1.2 Goals and Objectives

The primary goal of EchoMateLite is to design and implement a comprehensive social media platform using modern web technologies with cloud deployment readiness, providing students with practical experience in full-stack development and AWS cloud services.

Specific Objectives:
- Develop a secure user authentication system implementing JWT token-based authentication with bcrypt password hashing
- Create comprehensive user profile management capabilities including bio management, social connections, and follower/following relationships
- Implement core social media functionalities including post creation, content interaction through likes and comments, and real-time feed generation
- Structure the application for seamless AWS deployment utilizing EC2, S3, DocumentDB, and CloudFront services

1.3 Key Requirements of the Project

User Authentication and Security:
- Secure user registration system with email validation and unique username enforcement
- Robust login system with JWT token-based session management
- Password security implementation using bcrypt hashing with appropriate salt rounds
- Protected route middleware for authenticated user access control

Profile Management System:
- Complete user profile creation with username, email, full name, and biographical information
- Profile editing capabilities allowing users to update personal information
- Social connection management including follow/unfollow functionality
- Follower and following count tracking and display

Content Creation and Management:
- Post creation functionality with character limit validation (280 characters)
- Content sanitization and input validation for security
- Post editing and deletion capabilities for content authors
- Social feed generation showing posts from followed users

CHAPTER 2 - LITERATURE REVIEW

2.1 Significance and Rationale for the Chosen Technology Stack

The selection of the MERN stack with Next.js enhancement for EchoMateLite is based on comprehensive analysis of modern web development requirements, industry standards, and educational value for aspiring developers.

Next.js Frontend Framework Selection:
Next.js represents the evolution of React development, providing server-side rendering (SSR), static site generation (SSG), and optimized performance out of the box. The framework's built-in optimization features, including automatic code splitting, image optimization, and font optimization, directly address the performance requirements of social media applications where user experience and loading speeds are paramount.

TypeScript Integration Benefits:
The implementation of TypeScript across the entire application stack provides type safety that is crucial for complex social media applications. TypeScript's compile-time error detection significantly reduces runtime errors, particularly important in user authentication systems, data validation, and API communication.

Express.js Backend Selection:
Express.js remains the most widely adopted Node.js framework for RESTful API development, making it an ideal choice for educational projects. Its minimalist approach allows students to understand fundamental web server concepts while providing sufficient flexibility for complex social media backend requirements.

MongoDB Database Rationale:
MongoDB's document-based structure aligns naturally with social media data patterns where user profiles, posts, and social relationships often contain nested and varying data structures. The JSON-like document structure seamlessly integrates with JavaScript-based frontend and backend.

2.2 Significance and Rationale for the Chosen AWS Services

Amazon EC2 for Application Hosting:
Amazon Elastic Compute Cloud (EC2) provides the fundamental infrastructure for hosting both frontend and backend components of EchoMateLite. EC2's flexibility allows for easy scaling based on user demand, which is crucial for social media applications that may experience variable traffic patterns.

Amazon DocumentDB for Database Management:
Amazon DocumentDB offers MongoDB compatibility while providing managed database benefits including automated backups, monitoring, and scaling. This choice addresses the dual requirements of maintaining familiar MongoDB development experience while introducing students to managed cloud database concepts.

Amazon S3 for Static Asset Storage:
Amazon Simple Storage Service (S3) provides scalable object storage ideal for user-generated content including profile pictures, post images, and static website assets. S3's integration with CloudFront CDN ensures global content delivery performance crucial for social media user experience.

2.3 Problems Addressed by Using the Selected Stack

Scalability and Performance Challenges:
Next.js server-side rendering and static generation capabilities significantly improve initial page load times, crucial for user retention in social media applications. MongoDB's horizontal scaling capabilities, enhanced by DocumentDB's managed scaling features, address the data growth challenges typical of social media platforms.

Security and Authentication Complexity:
JWT token-based authentication with bcrypt password hashing addresses authentication security while maintaining stateless server architecture suitable for cloud deployment. Express.js middleware ecosystem provides comprehensive security tools including CORS protection and input validation.

Development Complexity and Maintainability:
TypeScript implementation across the entire stack provides type safety that reduces bugs and improves code maintainability, essential for collaborative development environments typical of real-world projects.

CHAPTER 3 - SOLUTION ARCHITECTURE

3.1 Architecture Diagram

The EchoMateLite platform follows a modern three-tier architecture pattern optimized for cloud deployment and scalability.

Frontend Layer (Presentation Tier):
- Next.js 15 application with TypeScript and Tailwind CSS
- Authentication Pages with form validation
- Dashboard Component with post creation and feed display
- Profile Management capabilities
- Real-time Feed with dynamic content loading

Backend Layer (Logic Tier):
- Node.js Express.js server with TypeScript
- Authentication Service with JWT and bcrypt
- User Management Service for profiles and social features
- Post Management Service for content operations
- Database Abstraction Layer using Mongoose ODM

Database Layer (Data Tier):
- MongoDB with optimized collections for users and posts
- Indexed queries for performance optimization
- Social relationship tracking and engagement metrics

AWS Cloud Integration:
- Amazon EC2: Application hosting with auto-scaling
- Amazon DocumentDB: Managed MongoDB-compatible database
- Amazon S3: Static asset storage and user uploads
- Amazon CloudFront: Global CDN for content delivery
- AWS Certificate Manager: SSL/TLS certificate management

3.2 Cost Analysis and Financial Implications

Development Phase Cost Structure (Monthly):
- EC2 t3.micro instance: $0 (Free Tier)
- DocumentDB db.t3.medium: $57.00
- S3 storage (5GB): $0.115
- CloudFront data transfer: $0.085
- Total Development Cost: ~$75-80/month

Production Scaling Projections:
Moderate Usage (1,000 users): ~$278/month
High Usage (10,000 users): ~$849/month

Cost Optimization Strategies:
- Free Tier maximization for development
- Reserved instances for production savings
- Auto-scaling for variable load management
- S3 lifecycle policies for storage optimization

REFERENCES

Amazon Web Services. (2024). AWS Documentation. Retrieved from https://docs.aws.amazon.com/
Next.js Team. (2024). Next.js Documentation. Retrieved from https://nextjs.org/docs
MongoDB Inc. (2024). MongoDB Manual. Retrieved from https://docs.mongodb.com/
Node.js Foundation. (2024). Node.js Documentation. Retrieved from https://nodejs.org/docs/
TypeScript Team. (2024). TypeScript Handbook. Retrieved from https://www.typescriptlang.org/docs/

ANNEXURES

Annexure A: Project Source Code Repository Structure
Annexure B: AWS Services Configuration Details  
Annexure C: Database Schema Documentation