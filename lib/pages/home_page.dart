import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/hotel.dart';
import '../models/article.dart';
import '../models/booking.dart';
import 'login_page.dart';
import 'settings_page.dart';
import 'hotel_detail_page.dart';
import 'article_detail_page.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Hotel> _hotels = [];
  List<Article> _articles = [];
  List<Booking> _bookings = [];
  bool _isLoading = true;
  String _searchQuery = "";
  final List<int> _wishlistIds = [];
  bool _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final hotels = await ApiService.getHotels();
      final articles = await ApiService.getArticles();
      final bookings = await ApiService.getBookings(widget.user.id);
      
      if (mounted) {
        setState(() {
          _hotels = hotels;
          _articles = articles;
          _bookings = bookings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showMessage('Koneksi Gagal', 'Gagal memuat data dari server. Detail: $e');
      }
    }
  }

  Future<void> _deleteBooking(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B3022),
        title: const Text('Hapus Pesanan', style: TextStyle(color: Color(0xFFD4AF37))),
        content: const Text('Apakah Anda yakin ingin membatalkan pesanan ini?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('BATAL', style: TextStyle(color: Colors.white24))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('HAPUS', style: TextStyle(color: Colors.redAccent))),
        ],
      )
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final res = await ApiService.deleteBooking(id, widget.user.apiToken ?? '');
      if (res['status'] == true) {
        _loadData();
      } else {
        setState(() => _isLoading = false);
        _showMessage('Gagal', res['message'] ?? 'Gagal menghapus pesanan');
      }
    }
  }

  void _showMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B3022),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16)),
        content: Text(message, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFFD4AF37))),
          )
        ],
      )
    );
  }

  void _toggleWishlist(int id) {
    setState(() {
      if (_wishlistIds.contains(id)) {
        _wishlistIds.remove(id);
      } else {
        _wishlistIds.add(id);
      }
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B14),
      appBar: AppBar(
        title: const Text('THE EMERALD IMPERIAL', style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900, fontSize: 14)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B3022),
        elevation: 0,
        foregroundColor: const Color(0xFFD4AF37),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFFD4AF37),
        backgroundColor: const Color(0xFF1B3022),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : _buildPages()[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF1B3022),
          selectedItemColor: const Color(0xFFD4AF37),
          unselectedItemColor: Colors.white24,
          selectedFontSize: 9,
          unselectedFontSize: 9,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'BERANDA'),
            BottomNavigationBarItem(icon: Icon(Icons.hotel_outlined), activeIcon: Icon(Icons.hotel), label: 'HOTEL'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), activeIcon: Icon(Icons.bookmark), label: 'PESANAN'),
            BottomNavigationBarItem(icon: Icon(Icons.article_outlined), activeIcon: Icon(Icons.article), label: 'ARTIKEL'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'PROFIL'),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPages() {
    return [
      _buildHomeContent(),
      _buildHotelsContent(),
      _buildBookingsContent(),
      _buildArticlesContent(),
      SettingsPage(user: widget.user),
    ];
  }

  // --- SUB-PAGES ---

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Welcome Header
          Container(
            padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1B3022), Color(0xFF0F1B14)],
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Analysis stats row
                Row(
                  children: [
                    _buildMiniStat('HOTELS', _hotels.length.toString()),
                    const SizedBox(width: 15),
                    _buildMiniStat('TRIPS', _bookings.length.toString()),
                    const SizedBox(width: 15),
                    _buildMiniStat('STARS', '4.9'),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Halo, ${widget.user.name.split(' ')[0]}!', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 5),
                        const Text('Temukan kemewahan menginap Anda', style: TextStyle(color: Colors.white38, fontSize: 13)),
                      ],
                    ),
                    const CircleAvatar(
                      backgroundColor: Color(0xFFD4AF37),
                      child: Icon(Icons.person, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                // Premium Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Cari hotel, lokasi, atau artikel...',
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                      icon: Icon(Icons.search, color: Color(0xFFD4AF37), size: 20),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          _buildSectionTitle('PENAWARAN EKSKLUSIF'),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildPromoCard('EMERALD SUITE', 'Diskon 30% hari ini', 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&q=80'),
                _buildPromoCard('SPA LUXURY', 'Voucher Rp 500k', 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?auto=format&fit=crop&q=80'),
                _buildPromoCard('DINING ACCESS', 'Gratis Dinner VIP', 'https://images.unsplash.com/photo-1550966842-28ca9268e3e4?auto=format&fit=crop&q=80'),
              ],
            ),
          ),

          const SizedBox(height: 35),
          _buildSectionTitle('HOTEL PILIHAN'),
          const SizedBox(height: 20),
          if (_hotels.isEmpty) 
             const Center(child: Padding(padding: EdgeInsets.all(50), child: Text("Memuat hotel...", style: TextStyle(color: Colors.white24))))
          else 
             ...(_hotels.where((h) => !_showOnlyFavorites || _wishlistIds.contains(h.id)).take(4)).map((h) => _buildHotelCard(h)),
          
          const SizedBox(height: 35),
          _buildSectionTitle('ARTIKEL TERBARU'),
          const SizedBox(height: 20),
          if (_articles.isEmpty)
             const Center(child: Padding(padding: EdgeInsets.all(50), child: Text("Memuat artikel...", style: TextStyle(color: Colors.white24))))
          else
             ..._articles.take(3).map((a) => _buildArticleCard(a)),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(val, style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: const TextStyle(color: Colors.white24, fontSize: 8, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildHotelsContent() {
    var filtered = _hotels.where((h) => h.name.toLowerCase().contains(_searchQuery.toLowerCase()) || h.location.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    if (_showOnlyFavorites) {
      filtered = filtered.where((h) => _wishlistIds.contains(h.id)).toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DAFTAR HOTEL (${filtered.length})', style: const TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2)),
              GestureDetector(
                onTap: () => setState(() => _showOnlyFavorites = !_showOnlyFavorites),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _showOnlyFavorites ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, size: 12, color: _showOnlyFavorites ? Colors.black : const Color(0xFFD4AF37)),
                      const SizedBox(width: 5),
                      Text('FAVORIT', style: TextStyle(color: _showOnlyFavorites ? Colors.black : Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty 
            ? _buildEmptyState(Icons.hotel_outlined, _showOnlyFavorites ? 'Belum ada hotel favorit' : 'Tidak ada hotel ditemukan')
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: filtered.length,
                itemBuilder: (context, index) => _buildHotelCard(filtered[index]),
              ),
        ),
      ],
    );
  }

  Widget _buildBookingsContent() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('RIWAYAT PESANAN ANDA', style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2)),
          ),
        ),
        Expanded(
          child: _bookings.isEmpty
            ? _buildEmptyState(Icons.bookmark_border, 'Belum ada pesanan aktif')
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _bookings.length,
                itemBuilder: (context, index) => _buildBookingCard(_bookings[index]),
              ),
        ),
      ],
    );
  }

  Widget _buildArticlesContent() {
    final filtered = _articles.where((article) => article.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      itemCount: filtered.isEmpty ? 0 : filtered.length,
      itemBuilder: (context, index) => _buildArticleCard(filtered[index]),
    );
  }

  // --- COMPONENTS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 11),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white10, size: 10),
        ],
      ),
    );
  }

  Widget _buildPromoCard(String title, String subtitle, String img) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
        image: DecorationImage(
          image: NetworkImage(img), 
          fit: BoxFit.cover, 
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken)
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(8)),
              child: Text(title, style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
            const SizedBox(height: 10),
            Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    final isFav = _wishlistIds.contains(hotel.id);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HotelDetailPage(hotel: hotel, user: widget.user))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B3022),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                  child: Hero(
                    tag: 'hotel-${hotel.id}',
                    child: hotel.imageUrl != null 
                      ? Image.network(hotel.imageUrl!, height: 200, width: double.infinity, fit: BoxFit.cover)
                      : Container(height: 200, color: Colors.grey[850]),
                  ),
                ),
                Positioned(
                  top: 15, right: 15,
                  child: GestureDetector(
                    onTap: () => _toggleWishlist(hotel.id),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                      child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: const Color(0xFFD4AF37), size: 18),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 15, left: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFD4AF37), size: 12),
                        const SizedBox(width: 4),
                        Text(hotel.stars.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hotel.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white24, size: 14),
                      const SizedBox(width: 5),
                      Text(hotel.location, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('HARGA MULAI', style: TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 1)),
                          Text('Rp ${hotel.price.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.3), blurRadius: 10)]
                        ),
                        child: const Text('LIHAT & PESAN', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3022),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                child: const Icon(Icons.hotel, color: Color(0xFFD4AF37), size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.hotelName ?? 'Nama Hotel', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text('Total: Rp ${booking.totalPrice.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.qr_code_2, color: Colors.white24, size: 28),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: booking.status.toLowerCase() == 'confirmed' ? Colors.green.withOpacity(0.2) : const Color(0xFFD4AF37).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Text(
                  booking.status.toUpperCase(), 
                  style: TextStyle(
                    color: booking.status.toLowerCase() == 'confirmed' ? Colors.greenAccent : const Color(0xFFD4AF37), 
                    fontSize: 10, 
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
              TextButton.icon(
                onPressed: () => _deleteBooking(booking.id!),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 16),
                label: const Text('BATALKAN', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleDetailPage(article: article))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1B3022), 
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: article.imageUrl != null 
                ? Image.network(article.imageUrl!, height: 160, width: double.infinity, fit: BoxFit.cover) 
                : Container(height: 160, color: Colors.grey[850]),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(article.category ?? 'Travel', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const Icon(Icons.star, color: Color(0xFFD4AF37), size: 12),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(article.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Text(article.content ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white38, fontSize: 12, height: 1.5)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String txt) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white12, size: 80),
          const SizedBox(height: 15),
          Text(txt, style: const TextStyle(color: Colors.white12, letterSpacing: 1)),
          const SizedBox(height: 25),
          if (_showOnlyFavorites)
            ElevatedButton(
              onPressed: () => setState(() => _showOnlyFavorites = false),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
              child: const Text('LIHAT SEMUA HOTEL'),
            ),
        ],
      ),
    );
  }
}