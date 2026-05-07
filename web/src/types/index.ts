// Type Definitions for Grand Hotel Web App

export interface User {
  id: number;
  full_name: string;
  email: string;
  phone?: string;
  role: 'user' | 'admin';
  is_active: boolean;
  created_at: string;
}

export interface Hotel {
  id: number;
  name: string;
  description: string;
  address: string;
  city: string;
  price_per_night: number;
  price_formatted: string;
  rating: number;
  image_url: string;
  facilities: string;
  facilities_list: string[];
  room_type: 'standard' | 'deluxe' | 'suite' | 'presidential';
  is_available: boolean;
  total_rooms: number;
}

export interface FoodItem {
  id: number;
  name: string;
  description: string;
  price: number;
  price_formatted: string;
  category: 'appetizer' | 'main_course' | 'dessert' | 'beverage' | 'snack';
  image_url: string;
  is_available: boolean;
  is_featured: boolean;
}

export interface CartItem extends FoodItem {
  quantity: number;
  subtotal: number;
}

export interface Reservation {
  id: number;
  user_id: number;
  hotel_id: number;
  check_in_date: string;
  check_out_date: string;
  total_nights: number;
  total_price: number;
  total_price_formatted: string;
  guest_count: number;
  special_request?: string;
  status: 'pending' | 'confirmed' | 'checked_in' | 'checked_out' | 'cancelled';
  payment_status: 'unpaid' | 'paid' | 'refunded';
  created_at: string;
  hotel_name?: string;
  hotel_image_url?: string;
  hotel_address?: string;
  guest_name?: string;
  guest_email?: string;
}

export interface Article {
  id: number;
  title: string;
  content: string;
  excerpt: string;
  image_url: string;
  author: string;
  category: 'promo' | 'tips' | 'event' | 'news';
  views: number;
  created_at: string;
  created_at_formatted: string;
}

export interface PaymentMethod {
  id: string;
  name: string;
  type: 'credit_card' | 'e_wallet' | 'bank_transfer';
  icon: string;
  description: string;
}

export interface Transaction {
  id: number;
  user_id: number;
  reservation_id?: number;
  food_order_id?: number;
  amount: number;
  payment_method: string;
  payment_status: 'pending' | 'success' | 'failed' | 'refunded';
  transaction_date: string;
  description: string;
}

export interface DashboardStats {
  total_users: number;
  total_hotels: number;
  total_revenue: string;
  active_bookings: number;
  recent_activities: Reservation[];
  popular_hotels: Hotel[];
  revenue_chart: {
    labels: string[];
    data: number[];
  };
}

export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data?: T;
  token?: string;
}
