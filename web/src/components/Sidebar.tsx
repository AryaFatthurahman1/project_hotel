import React from 'react';
import { Home, Hotel, Utensils, Newspaper, User, LogOut, LayoutDashboard } from 'lucide-react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useCartStore } from '@/store/cartStore';

const Sidebar = () => {
  const pathname = usePathname();
  const cartItemsCount = useCartStore((state) => state.getTotalItems());

  const menuItems = [
    { icon: Home, label: 'Beranda', href: '/dashboard' },
    { icon: Hotel, label: 'Hotel', href: '/hotels' },
    { icon: Utensils, label: 'Restaurant', href: '/food' },
    { icon: Newspaper, label: 'Artikel', href: '/articles' },
    { icon: LayoutDashboard, label: 'Admin', href: '/admin' },
    { icon: User, label: 'Profil', href: '/profile' },
  ];

  return (
    <aside className="fixed left-0 top-0 z-40 h-screen w-64 border-r border-white/10 bg-primary-900 text-white shadow-cinema transition-transform">
      <div className="flex h-full flex-col">
        {/* Logo */}
        <div className="flex h-20 items-center justify-center border-b border-white/10 bg-cinema-gradient px-6">
          <h1 className="bg-gold-gradient bg-clip-text text-2xl font-bold text-transparent font-display">
            GRAND HOTEL
          </h1>
        </div>

        {/* Menu */}
        <nav className="flex-1 space-y-1 px-3 py-4">
          {menuItems.map((item) => {
            const isActive = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`group flex items-center rounded-lg px-3 py-3 text-sm font-medium transition-all duration-200 ${
                  isActive
                    ? 'bg-primary-800 text-accent shadow-lg shadow-primary-900/50'
                    : 'text-gray-400 hover:bg-primary-800/50 hover:text-white'
                }`}
              >
                <item.icon
                  className={`mr-3 h-5 w-5 flex-shrink-0 transition-colors ${
                    isActive ? 'text-accent' : 'text-gray-500 group-hover:text-white'
                  }`}
                />
                {item.label}
              </Link>
            );
          })}
        </nav>

        {/* User Info & Logout */}
        <div className="border-t border-white/10 p-4">
          <button className="flex w-full items-center rounded-lg px-3 py-2 text-sm font-medium text-red-400 transition-colors hover:bg-red-500/10 hover:text-red-300">
            <LogOut className="mr-3 h-5 w-5" />
            Logout
          </button>
        </div>
      </div>
    </aside>
  );
};

export default Sidebar;
