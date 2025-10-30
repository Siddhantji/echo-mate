'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { Post } from '@/types';
import { postsAPI } from '@/lib/api';
import { Heart, MessageCircle, User as UserIcon, LogOut, Home, Edit } from 'lucide-react';
import ProfileModal from './ProfileModal';

export default function Dashboard() {
  const { user, logout } = useAuth();
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);
  const [newPost, setNewPost] = useState('');
  const [isCreatingPost, setIsCreatingPost] = useState(false);
  const [isProfileModalOpen, setIsProfileModalOpen] = useState(false);

  const loadPosts = async () => {
    try {
      setLoading(true);
      const response = await postsAPI.getTimeline();
      setPosts(response.posts);
    } catch (error) {
      console.error('Error loading posts:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadPosts();
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const handleCreatePost = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newPost.trim()) return;

    try {
      setIsCreatingPost(true);
      const response = await postsAPI.createPost({ content: newPost });
      setPosts([response.post, ...posts]);
      setNewPost('');
    } catch (error) {
      console.error('Error creating post:', error);
    } finally {
      setIsCreatingPost(false);
    }
  };

  const handleLikePost = async (postId: string) => {
    try {
      const response = await postsAPI.likePost(postId);
      setPosts(posts.map(post => {
        if (post._id === postId) {
          return {
            ...post,
            likes: response.isLiked 
              ? [...post.likes, user?.id || '']
              : post.likes.filter(id => id !== user?.id)
          };
        }
        return post;
      }));
    } catch (error) {
      console.error('Error liking post:', error);
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-4xl mx-auto px-4 py-3">
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-bold text-blue-600">EchoMateLite</h1>
            <div className="flex items-center space-x-4">
              <span className="text-gray-700">Welcome, {user?.fullName}</span>
              <button
                onClick={logout}
                className="flex items-center space-x-1 text-gray-600 hover:text-red-600"
              >
                <LogOut size={20} />
                <span>Logout</span>
              </button>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-4xl mx-auto px-4 py-6">
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
          {/* Sidebar */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-lg shadow p-6">
              <div className="text-center mb-4">
                <div className="w-16 h-16 rounded-full mx-auto mb-2 overflow-hidden bg-gray-200 flex items-center justify-center">
                  {user?.profilePicture ? (
                    <img
                      src={user.profilePicture}
                      alt={user.fullName}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <UserIcon size={32} className="text-gray-400" />
                  )}
                </div>
                <h3 className="font-semibold text-gray-900">{user?.fullName}</h3>
                <p className="text-gray-600">@{user?.username}</p>
                {user?.bio && (
                  <p className="text-sm text-gray-500 mt-2">{user.bio}</p>
                )}
                <button
                  onClick={() => setIsProfileModalOpen(true)}
                  className="mt-3 flex items-center justify-center space-x-1 text-blue-600 hover:text-blue-700 text-sm mx-auto"
                >
                  <Edit size={16} />
                  <span>Edit Profile</span>
                </button>
              </div>

              <nav className="space-y-2">
                <button
                  className="w-full flex items-center space-x-2 px-3 py-2 rounded-lg text-left bg-blue-100 text-blue-700"
                >
                  <Home size={20} />
                  <div className="flex-1">
                    <div className="font-medium">Timeline</div>
                    <div className="text-xs opacity-75">All posts</div>
                  </div>
                </button>
              </nav>
            </div>
          </div>

          {/* Main Content */}
          <div className="lg:col-span-3">
            {/* Create Post */}
            <div className="bg-white rounded-lg shadow p-6 mb-6">
              <form onSubmit={handleCreatePost}>
                <textarea
                  value={newPost}
                  onChange={(e) => setNewPost(e.target.value)}
                  placeholder="What's on your mind?"
                  className="w-full p-3 border border-gray-300 rounded-lg resize-none focus:outline-none focus:ring-2 focus:ring-blue-500"
                  rows={3}
                  maxLength={280}
                />
                <div className="flex justify-between items-center mt-3">
                  <span className="text-sm text-gray-500">{280 - newPost.length} characters remaining</span>
                  <button
                    type="submit"
                    disabled={!newPost.trim() || isCreatingPost}
                    className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isCreatingPost ? 'Posting...' : 'Post'}
                  </button>
                </div>
              </form>
            </div>

            {/* Posts Feed */}
            <div className="space-y-6">
              {loading ? (
                <div className="text-center py-8">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
                  <p className="mt-2 text-gray-600">Loading posts...</p>
                </div>
              ) : posts.length === 0 ? (
                <div className="text-center py-8 bg-white rounded-lg shadow p-6">
                  <p className="text-gray-600 mb-2">
                    No posts yet. Be the first to post!
                  </p>
                </div>
              ) : (
                posts.map((post) => (
                  <div key={post._id} className="bg-white rounded-lg shadow p-6">
                    {/* Post Header */}
                    <div className="flex items-center mb-4">
                      <div className="w-10 h-10 rounded-full overflow-hidden bg-gray-200 flex items-center justify-center">
                        {post.author.profilePicture ? (
                          <img
                            src={post.author.profilePicture}
                            alt={post.author.fullName}
                            className="w-full h-full object-cover"
                          />
                        ) : (
                          <UserIcon size={20} className="text-gray-400" />
                        )}
                      </div>
                      <div className="ml-3">
                        <h4 className="font-semibold text-gray-900">{post.author.fullName}</h4>
                        <p className="text-gray-600 text-sm">@{post.author.username} • {formatDate(post.createdAt)}</p>
                      </div>
                    </div>

                    {/* Post Content */}
                    <p className="text-gray-800 mb-4">{post.content}</p>

                    {/* Post Actions */}
                    <div className="flex items-center space-x-6 pt-4 border-t border-gray-100">
                      <button
                        onClick={() => handleLikePost(post._id)}
                        className={`flex items-center space-x-2 ${
                          post.likes.includes(user?.id || '') 
                            ? 'text-red-500' 
                            : 'text-gray-600 hover:text-red-500'
                        }`}
                      >
                        <Heart 
                          size={20} 
                          fill={post.likes.includes(user?.id || '') ? 'currentColor' : 'none'} 
                        />
                        <span>{post.likes.length}</span>
                      </button>
                      
                      <button className="flex items-center space-x-2 text-gray-600 hover:text-blue-500">
                        <MessageCircle size={20} />
                        <span>{post.comments.length}</span>
                      </button>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Profile Modal */}
      <ProfileModal
        isOpen={isProfileModalOpen}
        onClose={() => setIsProfileModalOpen(false)}
        onUpdate={() => {
          // Profile updated successfully
        }}
      />
    </div>
  );
}
