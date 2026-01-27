'use client';

import React, { useState, useEffect } from 'react';
import Layout from '@/components/Layout';
import { motion, AnimatePresence } from 'framer-motion';
import { Plus, Minus, ShoppingBag, X } from 'lucide-react';
import { foodApi } from '@/services/api';
import { useCartStore } from '@/store/cartStore';
import type { FoodItem } from '@/types';
import toast from 'react-hot-toast';

export default function FoodPage() {
  const [foods, setFoods] = useState<FoodItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeCategory, setActiveCategory] = useState('all');
  const { addToCart, items } = useCartStore();

  const categories = [
    { id: 'all', label: 'Semua Menu' },
    { id: 'main_course', label: 'Main Course' },
    { id: 'appetizer', label: 'Appetizer' },
    { id: 'dessert', label: 'Dessert' },
    { id: 'beverage', label: 'Minuman' },
  ];

  useEffect(() => {
    loadFoods();
  }, [activeCategory]);

  const loadFoods = async () => {
    setLoading(true);
    try {
      const response = activeCategory === 'all' 
        ? await foodApi.getAll() 
        : await foodApi.getByCategory(activeCategory);
      
      if (response.success && response.data) {
        setFoods(response.data);
      }
    } catch (error) {
      console.error('Failed to load foods', error);
    } finally {
      setLoading(false);
    }
  };

  const handleAddToCart = (food: FoodItem) => {
    addToCart(food);
    toast.success(`${food.name} ditambahkan ke keranjang`, {
      style: {
        background: '#1E293B',
        color: '#fff',
        border: '1px solid rgba(255,255,255,0.1)',
      },
      iconTheme: {
        primary: '#FFD700',
        secondary: '#1E293B',
      },
    });
  };

  return (
    <Layout>
      <div className="space-y-8">
        
        {/* Header */}
        <div className="flex items-end justify-between">
          <div>
            <h1 className="text-3xl font-bold text-white font-display">Premium Dining</h1>
            <p className="text-gray-400">Nikmati hidangan kelas dunia dari chef terbaik kami</p>
          </div>
          
          <div className="flex gap-2 rounded-full bg-[#1E293B] p-1">
            {categories.map((cat) => (
              <button
                key={cat.id}
                onClick={() => setActiveCategory(cat.id)}
                className={`rounded-full px-6 py-2 text-sm font-medium transition-all ${
                  activeCategory === cat.id
                    ? 'bg-accent text-primary-900 shadow-gold'
                    : 'text-gray-400 hover:text-white'
                }`}
              >
                {cat.label}
              </button>
            ))}
          </div>
        </div>

        {/* Food Grid */}
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
          <AnimatePresence mode="popLayout">
            {loading ? (
              [...Array(8)].map((_, i) => (
                <div key={i} className="h-80 animate-pulse rounded-2xl bg-[#1E293B]" />
              ))
            ) : (
              foods.map((food) => (
                <motion.div
                  layout
                  initial={{ opacity: 0, scale: 0.9 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.9 }}
                  key={food.id}
                  className="group relative overflow-hidden rounded-2xl bg-[#1E293B] shadow-card transition-all hover:-translate-y-2 hover:shadow-cinema"
                >
                  {/* Image */}
                  <div className="aspect-square w-full overflow-hidden">
                    <img
                      src={food.image_url || 'https://via.placeholder.com/300'}
                      alt={food.name}
                      className="h-full w-full object-cover transition-transform duration-700 group-hover:scale-110"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-[#1E293B] via-transparent to-transparent opacity-80" />
                  </div>

                  {/* Content */}
                  <div className="absolute bottom-0 left-0 w-full p-5">
                    <h3 className="mb-1 text-lg font-bold text-white group-hover:text-accent font-display">
                      {food.name}
                    </h3>
                    <p className="mb-4 text-sm text-gray-400 line-clamp-2">
                      {food.description}
                    </p>
                    
                    <div className="flex items-center justify-between">
                      <p className="text-xl font-bold text-accent">{food.price_formatted}</p>
                      <button
                        onClick={() => handleAddToCart(food)}
                        className="flex h-10 w-10 items-center justify-center rounded-full bg-white/10 text-white backdrop-blur-md transition-colors hover:bg-accent hover:text-primary-900"
                        aria-label="Add to cart"
                      >
                        <Plus className="h-5 w-5" />
                      </button>
                    </div>
                  </div>
                </motion.div>
              ))
            )}
          </AnimatePresence>
        </div>

      </div>
    </Layout>
  );
}
