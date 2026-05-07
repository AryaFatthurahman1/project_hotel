import axios from 'axios';
import type { ApiResponse, User, Hotel, FoodItem, Reservation, Article, DashboardStats, Transaction } from '@/types';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'https://kilimanjaro.iixcp.rumahweb.net/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('auth_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('auth_token');
      localStorage.removeItem('user_data');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// ==================== AUTH API ====================
export const authApi = {
  login: async (email: string, password: string): Promise<ApiResponse<User>> => {
    const { data } = await api.post('/users.php?action=login', { email, password });
    if (data.success && data.token) {
      localStorage.setItem('auth_token', data.token);
      localStorage.setItem('user_data', JSON.stringify(data.data));
    }
    return data;
  },

  register: async (userData: {
    full_name: string;
    email: string;
    password: string;
    phone?: string;
  }): Promise<ApiResponse<User>> => {
    const { data } = await api.post('/users.php?action=register', userData);
    return data;
  },

  logout: () => {
    localStorage.removeItem('auth_token');
    localStorage.removeItem('user_data');
  },

  getCurrentUser: (): User | null => {
    const userData = localStorage.getItem('user_data');
    return userData ? JSON.parse(userData) : null;
  },
};

// ==================== HOTELS API ====================
export const hotelsApi = {
  getAll: async (): Promise<ApiResponse<Hotel[]>> => {
    const { data } = await api.get('/hotels.php');
    return data;
  },

  getDetail: async (id: number): Promise<ApiResponse<Hotel>> => {
    const { data } = await api.get(`/hotels.php?action=detail&id=${id}`);
    return data;
  },

  search: async (params: {
    city?: string;
    room_type?: string;
    min_price?: number;
    max_price?: number;
    keyword?: string;
  }): Promise<ApiResponse<Hotel[]>> => {
    const queryString = new URLSearchParams(
      Object.entries(params).reduce((acc, [key, value]) => {
        if (value !== undefined) acc[key] = String(value);
        return acc;
      }, {} as Record<string, string>)
    ).toString();
    const { data } = await api.get(`/hotels.php?action=search&${queryString}`);
    return data;
  },
};

// ==================== FOOD API ====================
export const foodApi = {
  getAll: async (): Promise<ApiResponse<FoodItem[]>> => {
    const { data } = await api.get('/food.php');
    return data;
  },

  getFeatured: async (): Promise<ApiResponse<FoodItem[]>> => {
    const { data } = await api.get('/food.php?action=featured');
    return data;
  },

  getByCategory: async (category: string): Promise<ApiResponse<FoodItem[]>> => {
    const { data } = await api.get(`/food.php?action=category&category=${category}`);
    return data;
  },
};

// ==================== RESERVATIONS API ====================
export const reservationsApi = {
  create: async (reservationData: {
    user_id: number;
    hotel_id: number;
    check_in_date: string;
    check_out_date: string;
    guest_count: number;
    special_request?: string;
  }): Promise<ApiResponse<Reservation>> => {
    const { data } = await api.post('/reservations.php?action=create', reservationData);
    return data;
  },

  getUserReservations: async (userId: number): Promise<ApiResponse<Reservation[]>> => {
    const { data } = await api.get(`/reservations.php?action=user&user_id=${userId}`);
    return data;
  },

  cancel: async (id: number): Promise<ApiResponse<any>> => {
    const { data } = await api.post('/reservations.php?action=cancel', { id });
    return data;
  },
};

// ==================== ARTICLES API ====================
export const articlesApi = {
  getAll: async (): Promise<ApiResponse<Article[]>> => {
    const { data } = await api.get('/articles.php');
    return data;
  },

  getDetail: async (id: number): Promise<ApiResponse<Article>> => {
    const { data } = await api.get(`/articles.php?action=detail&id=${id}`);
    return data;
  },

  getByCategory: async (category: string): Promise<ApiResponse<Article[]>> => {
    const { data } = await api.get(`/articles.php?action=category&category=${category}`);
    return data;
  },
};

// ==================== DASHBOARD API ====================
export const dashboardApi = {
  getStats: async (): Promise<ApiResponse<DashboardStats>> => {
    const { data } = await api.get('/dashboard.php');
    return data;
  },
};

// ==================== UPLOAD API ====================
export const uploadApi = {
  uploadImage: async (file: File): Promise<ApiResponse<{ url: string }>> => {
    const formData = new FormData();
    formData.append('image', file);
    const { data } = await api.post('/upload.php', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return data;
  },
};

export default api;
