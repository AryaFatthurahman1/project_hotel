import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import type { CartItem, FoodItem, Hotel } from '@/types';

interface CartStore {
  items: CartItem[];
  favorites: Hotel[];
  addToCart: (item: FoodItem) => void;
  removeFromCart: (itemId: number) => void;
  updateQuantity: (itemId: number, quantity: number) => void;
  clearCart: () => void;
  getTotalItems: () => number;
  getTotalPrice: () => number;
  addToFavorites: (hotel: Hotel) => void;
  removeFromFavorites: (hotelId: number) => void;
  isFavorite: (hotelId: number) => boolean;
}

export const useCartStore = create<CartStore>()(
  persist(
    (set, get) => ({
      items: [],
      favorites: [],

      addToCart: (item: FoodItem) => {
        const existingItem = get().items.find((i) => i.id === item.id);
        if (existingItem) {
          set({
            items: get().items.map((i) =>
              i.id === item.id
                ? { ...i, quantity: i.quantity + 1, subtotal: (i.quantity + 1) * i.price }
                : i
            ),
          });
        } else {
          set({
            items: [...get().items, { ...item, quantity: 1, subtotal: item.price }],
          });
        }
      },

      removeFromCart: (itemId: number) => {
        set({ items: get().items.filter((i) => i.id !== itemId) });
      },

      updateQuantity: (itemId: number, quantity: number) => {
        if (quantity <= 0) {
          get().removeFromCart(itemId);
        } else {
          set({
            items: get().items.map((i) =>
              i.id === itemId ? { ...i, quantity, subtotal: quantity * i.price } : i
            ),
          });
        }
      },

      clearCart: () => set({ items: [] }),

      getTotalItems: () => get().items.reduce((sum, item) => sum + item.quantity, 0),

      getTotalPrice: () => get().items.reduce((sum, item) => sum + item.subtotal, 0),

      addToFavorites: (hotel: Hotel) => {
        if (!get().favorites.find((h) => h.id === hotel.id)) {
          set({ favorites: [...get().favorites, hotel] });
        }
      },

      removeFromFavorites: (hotelId: number) => {
        set({ favorites: get().favorites.filter((h) => h.id !== hotelId) });
      },

      isFavorite: (hotelId: number) => {
        return get().favorites.some((h) => h.id === hotelId);
      },
    }),
    {
      name: 'grand-hotel-cart',
    }
  )
);
