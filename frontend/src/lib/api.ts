import axios from 'axios';
import { AuthResponse, LoginData, RegisterData, User, Post } from '@/types';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
});

// Add token to requests if available
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Auth API
export const authAPI = {
  login: async (data: LoginData): Promise<AuthResponse> => {
    const response = await api.post('/auth/login', data);
    return response.data;
  },

  register: async (data: RegisterData): Promise<AuthResponse> => {
    const response = await api.post('/auth/register', data);
    return response.data;
  },

  getCurrentUser: async (): Promise<{ user: User }> => {
    const response = await api.get('/auth/me');
    return response.data;
  },
};

// User API
export const userAPI = {
  getProfile: async (username: string): Promise<{ user: User }> => {
    const response = await api.get(`/users/profile/${username}`);
    return response.data;
  },

  updateProfile: async (data: Partial<User>): Promise<{ user: User }> => {
    const response = await api.put('/users/profile', data);
    return response.data;
  },

  followUser: async (userId: string): Promise<{ message: string; isFollowing: boolean }> => {
    const response = await api.post(`/users/follow/${userId}`);
    return response.data;
  },

  searchUsers: async (query: string): Promise<{ users: User[] }> => {
    const response = await api.get(`/users/search?q=${encodeURIComponent(query)}`);
    return response.data;
  },
};

// Posts API
export const postsAPI = {
  createPost: async (data: { content: string; image?: string }): Promise<{ post: Post }> => {
    const response = await api.post('/posts', data);
    return response.data;
  },

  getFeed: async (page = 1, limit = 10): Promise<{ posts: Post[]; page: number; hasMore: boolean }> => {
    const response = await api.get(`/posts/feed?page=${page}&limit=${limit}`);
    return response.data;
  },

  getTimeline: async (page = 1, limit = 10): Promise<{ posts: Post[]; page: number; hasMore: boolean }> => {
    const response = await api.get(`/posts/timeline?page=${page}&limit=${limit}`);
    return response.data;
  },

  getUserPosts: async (username: string, page = 1, limit = 10): Promise<{ posts: Post[]; page: number; hasMore: boolean }> => {
    const response = await api.get(`/posts/user/${username}?page=${page}&limit=${limit}`);
    return response.data;
  },

  likePost: async (postId: string): Promise<{ message: string; isLiked: boolean; likesCount: number }> => {
    const response = await api.post(`/posts/${postId}/like`);
    return response.data;
  },

  addComment: async (postId: string, text: string): Promise<{ comment: Comment }> => {
    const response = await api.post(`/posts/${postId}/comment`, { text });
    return response.data;
  },

  deletePost: async (postId: string): Promise<{ message: string }> => {
    const response = await api.delete(`/posts/${postId}`);
    return response.data;
  },
};

export default api;
