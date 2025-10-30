export interface User {
  id: string;
  username: string;
  email: string;
  fullName: string;
  bio?: string;
  profilePicture?: string;
  followers?: number;
  following?: number;
  createdAt?: string;
}

export interface Post {
  _id: string;
  author: {
    _id: string;
    username: string;
    fullName: string;
    profilePicture?: string;
  };
  content: string;
  image?: string;
  likes: string[];
  comments: Comment[];
  createdAt: string;
}

export interface Comment {
  _id: string;
  user: {
    _id: string;
    username: string;
    fullName: string;
    profilePicture?: string;
  };
  text: string;
  createdAt: string;
}

export interface AuthResponse {
  message: string;
  token: string;
  user: User;
}

export interface LoginData {
  email: string;
  password: string;
}

export interface RegisterData {
  username: string;
  email: string;
  password: string;
  fullName: string;
}
