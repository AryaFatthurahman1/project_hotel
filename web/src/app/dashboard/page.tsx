import Image from 'next/image';
import Layout from '@/components/Layout';
import { PlayCircle, Star, Calendar } from 'lucide-react';
import { motion } from 'framer-motion';

export default function Dashboard() {
  return (
    <Layout>
      <div className="space-y-10">
        
        {/* Hero Section (Cinema Style Banner) */}
        <section className="relative h-[400px] w-full overflow-hidden rounded-2xl shadow-cinema">
          <Image
            src="https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=1600"
            alt="Luxury Hotel"
            fill
            className="object-cover"
            priority
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#0F172A] via-[#0F172A]/50 to-transparent" />
          
          <div className="absolute bottom-0 left-0 p-10 z-10">
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
            >
              <span className="mb-2 inline-block rounded-full bg-accent/20 px-3 py-1 text-xs font-bold text-accent backdrop-blur-sm">
                RECOMMENDED
              </span>
              <h1 className="mb-4 text-5xl font-bold text-white font-display leading-tight">
                Luxury Ocean View <br />
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-accent to-orange-400">Suite Collection</span>
              </h1>
              <p className="mb-6 max-w-xl text-lg text-gray-300">
                Rasakan pengalaman menginap tak terlupakan dengan pemandangan laut lepas dan fasilitas bintang 5.
              </p>
              <div className="flex gap-4">
                <button className="flex items-center gap-2 rounded-full bg-accent px-8 py-3 font-bold text-primary-900 shadow-gold transition-transform hover:scale-105">
                  <PlayCircle className="h-5 w-5" />
                  Booking Sekarang
                </button>
                <button className="rounded-full border border-white/20 bg-white/10 px-8 py-3 font-semibold text-white backdrop-blur-sm transition-colors hover:bg-white/20">
                  Lihat Detail
                </button>
              </div>
            </motion.div>
          </div>
        </section>

        {/* Featured Hotels */}
        <section>
          <div className="mb-6 flex items-center justify-between">
            <h2 className="text-2xl font-bold text-white font-display">Hotel Terpopuler</h2>
            <button className="text-sm font-medium text-accent hover:underline">Lihat Semua</button>
          </div>
          
          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {[1, 2, 3, 4].map((item) => (
              <motion.div
                key={item}
                whileHover={{ scale: 1.05 }}
                className="group relative overflow-hidden rounded-xl bg-[#1E293B] shadow-card"
              >
                <div className="aspect-[4/3] w-full overflow-hidden">
                  <img
                    src={`https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&q=80`}
                    alt="Hotel"
                    className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-110"
                  />
                  <div className="absolute top-3 right-3 rounded-lg bg-black/50 px-2 py-1 backdrop-blur-sm">
                    <div className="flex items-center gap-1">
                      <Star className="h-3 w-3 fill-accent text-accent" />
                      <span className="text-xs font-bold text-white">4.9</span>
                    </div>
                  </div>
                </div>
                
                <div className="p-4">
                  <h3 className="text-lg font-bold text-white">Grand Deluxe Room</h3>
                  <p className="text-sm text-gray-400">Jakarta Pusat</p>
                  <div className="mt-4 flex items-center justify-between">
                    <div>
                      <p className="text-xs text-gray-500">Mulai dari</p>
                      <p className="text-lg font-bold text-accent">Rp 1.500.000</p>
                    </div>
                    <button 
                      className="rounded-lg bg-primary-600 p-2 text-white transition-colors hover:bg-primary-500"
                      aria-label="Book Now"
                    >
                      <Calendar className="h-5 w-5" />
                    </button>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </section>

      </div>
    </Layout>
  );
}
