'use client';

import React from 'react';
import Layout from '@/components/Layout';
import { useCartStore } from '@/store/cartStore';
import { motion, AnimatePresence } from 'framer-motion';
import { Trash2, Plus, Minus, CreditCard, Wallet } from 'lucide-react';
import toast from 'react-hot-toast';

export default function CartPage() {
  const { items, removeFromCart, updateQuantity, getTotalPrice } = useCartStore();

  const handleCheckout = () => {
    toast.loading('Memproses pembayaran...', {
      style: {
        background: '#1E293B',
        color: '#fff',
      }
    });
    // Simulate checkout
    setTimeout(() => {
      toast.dismiss();
      toast.success('Pembayaran Berhasil! Pesanan diproses.', {
        style: {
          background: '#1E293B',
          color: '#fff',
        }
      });
    }, 2000);
  };

  return (
    <Layout>
      <div className="mx-auto max-w-6xl">
        <h1 className="mb-8 text-3xl font-bold text-white font-display">Keranjang Belanja</h1>

        <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
          {/* Cart Items */}
          <div className="lg:col-span-2 space-y-4">
            <AnimatePresence>
              {items.length === 0 ? (
                <motion.div 
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="flex h-64 flex-col items-center justify-center rounded-2xl bg-[#1E293B] border border-white/5"
                >
                  <div className="mb-4 rounded-full bg-white/5 p-4">
                    <Trash2 className="h-8 w-8 text-gray-400" />
                  </div>
                  <p className="text-gray-400">Keranjang masih kosong</p>
                </motion.div>
              ) : (
                items.map((item) => (
                  <motion.div
                    key={item.id}
                    layout
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, x: -20 }}
                    className="flex items-center gap-4 rounded-xl bg-[#1E293B] p-4 shadow-card border border-white/5"
                  >
                    <div className="h-24 w-24 flex-shrink-0 overflow-hidden rounded-lg bg-gray-800">
                      <img
                        src={item.image_url || 'https://via.placeholder.com/150'}
                        alt={item.name}
                        className="h-full w-full object-cover"
                      />
                    </div>
                    
                    <div className="flex-1">
                      <h3 className="text-lg font-bold text-white">{item.name}</h3>
                      <p className="text-accent">{item.category}</p>
                    </div>

                    <div className="flex items-center gap-3 rounded-lg bg-black/20 p-2">
                      <button 
                        onClick={() => updateQuantity(item.id, item.quantity - 1)}
                        className="rounded p-1 hover:bg-white/10 text-white"
                        aria-label="Decrease quantity"
                      >
                        <Minus className="h-4 w-4" />
                      </button>
                      <span className="w-8 text-center font-bold text-white">{item.quantity}</span>
                      <button 
                        onClick={() => updateQuantity(item.id, item.quantity + 1)}
                        className="rounded p-1 hover:bg-white/10 text-white"
                        aria-label="Increase quantity"
                      >
                        <Plus className="h-4 w-4" />
                      </button>
                    </div>

                    <div className="w-32 text-right">
                      <p className="text-lg font-bold text-white">
                        Rp {(item.price * item.quantity).toLocaleString('id-ID')}
                      </p>
                    </div>

                    <button 
                      onClick={() => removeFromCart(item.id)}
                      className="rounded-full p-2 text-gray-400 hover:bg-red-500/10 hover:text-red-500"
                      aria-label="Remove item"
                    >
                      <Trash2 className="h-5 w-5" />
                    </button>
                  </motion.div>
                ))
              )}
            </AnimatePresence>
          </div>

          {/* Checkout Summary */}
          <div className="h-fit rounded-2xl bg-[#1E293B] p-6 border border-white/5 shadow-cinema">
            <h2 className="mb-6 text-xl font-bold text-white">Ringkasan Pembayaran</h2>
            
            <div className="space-y-4 border-b border-white/10 pb-6">
              <div className="flex justify-between text-gray-400">
                <span>Subtotal</span>
                <span>Rp {getTotalPrice().toLocaleString('id-ID')}</span>
              </div>
              <div className="flex justify-between text-gray-400">
                <span>Pajak (10%)</span>
                <span>Rp {(getTotalPrice() * 0.1).toLocaleString('id-ID')}</span>
              </div>
              <div className="flex justify-between text-gray-400">
                <span>Layanan (5%)</span>
                <span>Rp {(getTotalPrice() * 0.05).toLocaleString('id-ID')}</span>
              </div>
            </div>

            <div className="mt-6 mb-8 flex justify-between">
              <span className="text-lg font-bold text-white">Total</span>
              <span className="text-2xl font-bold text-accent">
                Rp {(getTotalPrice() * 1.15).toLocaleString('id-ID')}
              </span>
            </div>

            <div className="mb-6 space-y-3">
              <p className="text-sm font-medium text-gray-400">Metode Pembayaran</p>
              <button className="flex w-full items-center gap-3 rounded-xl border border-accent bg-accent/10 p-3 text-accent transition-colors">
                <CreditCard className="h-5 w-5" />
                <span className="flex-1 text-left font-bold">Kartu Kredit</span>
                <div className="h-4 w-4 rounded-full border border-accent bg-accent" />
              </button>
              <button className="flex w-full items-center gap-3 rounded-xl border border-white/10 bg-white/5 p-3 text-gray-400 transition-colors hover:bg-white/10">
                <Wallet className="h-5 w-5" />
                <span className="flex-1 text-left font-medium">E-Wallet (GoPay/OVO)</span>
                <div className="h-4 w-4 rounded-full border border-gray-600" />
              </button>
            </div>

            <button
              onClick={handleCheckout}
              disabled={items.length === 0}
              className="w-full rounded-full bg-gradient-to-r from-accent to-orange-400 py-4 font-bold text-primary-900 shadow-gold transition-transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Bayar Sekarang
            </button>
          </div>
        </div>
      </div>
    </Layout>
  );
}
