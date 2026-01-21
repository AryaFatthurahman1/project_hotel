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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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
      if (mounted) setState(() => _isLoading = false);
      _showMessage('Koneksi Gagal', 'Gagal memuat data dari server. Periksa koneksi internet Anda. Detail: $e');
    }
  }

  void _showMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B3022),
        title: Text(title, style: const TextStyle(color: Color(0xFFD4AF37))),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFFD4AF37))),
          )
        ],
      )
    );
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
            icon: const Icon(Icons.notifications_none, size: 22),
            onPressed: () {},
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
          selectedFontSize: 10,
          unselectedFontSize: 10,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Container(
            padding: const EdgeInsets.all(25),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1B3022),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sore, ${widget.user.name.split(' ')[0]}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                const Text('Temukan kemewahan menginap Anda', style: TextStyle(color: Colors.white38, fontSize: 13)),
                const SizedBox(height: 25),
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Cari hotel atau lokasi...',
                      hintStyle: TextStyle(color: Colors.white12, fontSize: 14),
                      icon: Icon(Icons.search, color: Color(0xFFD4AF37), size: 18),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          _buildSectionTitle('PENAWARAN KHUSUS'),
          const SizedBox(height: 15),
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                _buildPromoCard('DISCOUNT 30%', 'Emerald Suite', 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461'),
                _buildPromoCard('GIFT VOUCHER', 'Spa & Wellness', 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874'),
              ],
            ),
          ),

          const SizedBox(height: 30),
          _buildSectionTitle('REKOMENDASI HOTEL'),
          const SizedBox(height: 15),
          ..._hotels.take(3).map((h) => _buildHotelCard(h)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHotelsContent() {
    final filtered = _hotels.where((h) => h.name.toLowerCase().contains(_searchQuery.toLowerCase()) || h.location.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildHotelCard(filtered[index]),
    );
  }

  Widget _buildBookingsContent() {
    return _bookings.isEmpty
      ? _buildEmptyState(Icons.bookmark_border, 'Belum ada pesanan aktif')
      : ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _bookings.length,
          itemBuilder: (context, index) => _buildBookingCard(_bookings[index]),
        );
  }

  Widget _buildArticlesContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _articles.length,
      itemBuilder: (context, index) => _buildArticleCard(_articles[index]),
    );
  }

  // --- COMPONENTS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Text(
        title,
        style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 11),
      ),
    );
  }

  Widget _buildPromoCard(String title, String subtitle, String img) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              color: const Color(0xFFD4AF37),
              child: Text(title, style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HotelDetailPage(hotel: hotel, user: widget.user))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1B3022),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: Hero(
                tag: 'hotel-${hotel.id}',
                child: hotel.imageUrl != null 
                  ? Image.network(hotel.imageUrl!, height: 180, width: double.infinity, fit: BoxFit.cover)
                  : Container(height: 180, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(hotel.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFD4AF37), size: 16),
                          const SizedBox(width: 4),
                          Text(hotel.stars.toString(), style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(hotel.location, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rp ${hotel.price.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD4AF37)), borderRadius: BorderRadius.circular(10)),
                        child: const Text('LIHAT DETAIL', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 9, fontWeight: FontWeight.bold)),
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
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3022),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.hotel, color: Color(0xFFD4AF37)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.hotelName ?? 'Hotel', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Status: ${booking.status.toUpperCase()}', style: TextStyle(color: booking.status == 'confirmed' ? Colors.green : Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.qr_code, color: Colors.white24, size: 24),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleDetailPage(article: article))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(color: const Color(0xFF1B3022), borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              child: article.imageUrl != null ? Image.network(article.imageUrl!, height: 150, width: double.infinity, fit: BoxFit.cover) : Container(height: 150, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(article.content ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white38, fontSize: 12)),
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
          Text(txt, style: const TextStyle(color: Colors.white12)),
        ],
      ),
    );
  }
}