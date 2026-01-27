import React from 'react';
import Sidebar from './Sidebar';
import { ShoppingCart, Bell, Search } from 'lucide-react';
import { useCartStore } from '@/store/cartStore';
import Link from 'next/link';

interface LayoutProps {
  children: React.ReactNode;
}

const Layout: React.FC<LayoutProps> = ({ children }) => {
  const cartItemsCount = useCartStore((state) => state.getTotalItems());

  return (
    <div className="min-h-screen bg-[#0F172A]">
      <Sidebar />
      
      <main className="ml-64 min-h-screen transition-all">
        {/* Top Navbar */}
        <header className="sticky top-0 z-30 border-b border-white/10 bg-[#0F172A]/80 px-8 py-4 backdrop-blur-md">
          <div className="flex items-center justify-between">
            {/* Search Bar */}
            <div className="relative w-96">
              <input
                type="text"
                placeholder="Cari hotel, makanan, atau event..."
                className="w-full rounded-full border border-white/10 bg-white/5 py-2 pl-10 pr-4 text-sm text-white placeholder-gray-400 focus:border-accent focus:outline-none focus:ring-1 focus:ring-accent"
              />
              <Search className="absolute left-3 top-2.5 h-4 w-4 text-gray-400" />
            </div>

            {/* Right Actions */}
            <div className="flex items-center space-x-6">
              <button 
                className="relative text-gray-400 transition-colors hover:text-white"
                aria-label="Notifications"
              >
                <Bell className="h-6 w-6" />
                <span className="absolute -right-1 -top-1 block h-2.5 w-2.5 rounded-full bg-red-500 ring-2 ring-[#0F172A]" />
              </button>

              <Link href="/cart" className="relative text-gray-400 transition-colors hover:text-accent">
                <ShoppingCart className="h-6 w-6" />
                {cartItemsCount > 0 && (
                  <span className="absolute -right-2 -top-2 flex h-5 w-5 items-center justify-center rounded-full bg-accent text-xs font-bold text-primary-900 ring-2 ring-[#0F172A]">
                    {cartItemsCount}
                  </span>
                )}
              </Link>

              <div className="h-8 w-[1px] bg-white/10" />

              <div className="flex items-center gap-3">
                <div className="h-9 w-9 rounded-full bg-gradient-to-br from-accent to-orange-500 p-[2px]">
                  <div className="h-full w-full rounded-full bg-[#0F172A] p-[2px]">
                    <img
                      src="https://via.placeholder.com/150"
                      alt="User"
                      className="h-full w-full rounded-full object-cover"
                    />
                  </div>
                </div>
                <div className="hidden md:block">
                  <p className="text-sm font-medium text-white">Arya Fatthurahman</p>
                  <p className="text-xs text-gray-400">Premium Member</p>
                </div>
              </div>
            </div>
          </div>
        </header>

        {/* Content */}
        <div className="p-8">
          {children}
        </div>
      </main>
    </div>
  );
};

export default Layout;
