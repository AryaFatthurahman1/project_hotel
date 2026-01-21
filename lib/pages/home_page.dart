import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/hotel.dart';
import '../models/article.dart';
import '../models/booking.dart';
import 'login_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  final User user;
  
  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Hotel> _hotels = [];
  List<Article> _articles = [];
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final hotels = await ApiService.getHotels();
      final articles = await ApiService.getArticles();
      final bookings = await ApiService.getBookings(widget.user.id);
      
      setState(() {
        _hotels = hotels;
        _articles = articles;
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Error', 'Gagal memuat data: $e');
    }
  }

  void _showMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          )
        ],
      )
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Berhasil logout')),
    );
  }

  // 5 Menu Utama
  List<Widget> _buildPages() {
    return [
      _buildHomePage(),
      _buildHotelsPage(),
      _buildBookingsPage(),
      _buildArticlesPage(),
      SettingsPage(user: widget.user),
    ];
  }

  // Menu 1: Home
  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Luxury Greeting Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B3022), Color(0xFF0F1B14)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,'.toUpperCase(),
                            style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 10, letterSpacing: 2),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.user.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const CircleAvatar(
                      backgroundColor: Color(0xFFD4AF37),
                      child: Icon(Icons.person, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white10),
                const SizedBox(height: 10),
                const Text(
                  'NIKMATI PENGALAMAN MENGINAP TAK TERLUPAKAN',
                  style: TextStyle(color: Colors.white30, fontSize: 9, letterSpacing: 1),
                ),
              ],
            ),
          ),

          // Promotions Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PENAWARAN EKSKLUSIF',
                  style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12),
                ),
                Icon(Icons.star, color: Color(0xFFD4AF37), size: 16),
              ],
            ),
          ),
          
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _buildOfferCard('PRESIDENTIAL SUITE', 'Diskon 30% untuk pemesanan hari ini', 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?auto=format&fit=crop&q=80'),
                _buildOfferCard('DINING EXPERIENCE', 'Makan malam romantis di rooftop', 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?auto=format&fit=crop&q=80'),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Artikel Section
          if (_articles.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'BERITA & ARTIKEL',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 220,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  final article = _articles[index];
                  return Container(
                    width: 300,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (article.imageUrl != null)
                              Image.network(
                                article.imageUrl!,
                                height: 80,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            SizedBox(height: 10),
                            Text(
                              article.title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (article.content != null)
                              Expanded(
                                child: Text(
                                  article.content!,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
          
          // Hotel Preview
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hotel Rekomendasi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 10),
          ..._hotels.take(3).map((hotel) => _buildHotelCard(hotel)),
        ],
      ),
    );
  }

  // Menu 2: Hotels (List Data - Poin f)
  Widget _buildHotelsPage() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Daftar Hotel',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: _isLoading 
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _hotels.length,
                itemBuilder: (context, index) {
                  return _buildHotelCard(_hotels[index]);
                },
              ),
        ),
      ],
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          if (hotel.imageUrl != null)
            Image.network(
              hotel.imageUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16),
                    SizedBox(width: 5),
                    Text(hotel.location),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  'Rp ${hotel.price.toStringAsFixed(0)}/malam',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                if (hotel.description != null) ...[
                  SizedBox(height: 10),
                  Text(hotel.description!),
                ],
                SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Booking ${hotel.name} - Fitur coming soon!')),
                      );
                    },
                    child: Text('Booking Sekarang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Menu 3: Bookings
  Widget _buildBookingsPage() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Booking Saya',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: _bookings.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.book_online, size: 80, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('Belum ada booking', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _bookings.length,
                itemBuilder: (context, index) {
                  final booking = _bookings[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.hotel),
                      title: Text(booking.hotelName ?? 'Hotel'),
                      subtitle: Text(
                        'Check-in: ${booking.checkin?.toString().split(' ')[0] ?? '-'}\n'
                        'Status: ${booking.status}',
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: booking.status == 'confirmed' ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          booking.status,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildOfferCard(String title, String subtitle, String imageUrl) {
    return Container(
      width: 280,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // Menu 4: Articles
  Widget _buildArticlesPage() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Artikel & Tips',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _articles.length,
            itemBuilder: (context, index) {
              final article = _articles[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article.imageUrl != null)
                        Image.network(
                          article.imageUrl!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      SizedBox(height: 10),
                      Text(
                        article.title,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (article.content != null) ...[
                        SizedBox(height: 10),
                        Text(
                          article.content!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          _showMessage(article.title, article.content ?? 'Konten tidak tersedia');
                        },
                        child: Text('Baca Selengkapnya'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Menu 5: Profile

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B14),
      appBar: AppBar(
        title: const Text('ARYA HOTEL', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF1B3022),
        elevation: 0,
        foregroundColor: const Color(0xFFD4AF37),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            onPressed: () => _logout(),
          ),
        ],
      ),
      body: _buildPages()[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1B3022),
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.white24,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.hotel_outlined), activeIcon: Icon(Icons.hotel), label: 'HOTEL'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), activeIcon: Icon(Icons.bookmark), label: 'PESANAN'),
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), activeIcon: Icon(Icons.article), label: 'ARTIKEL'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'PROFIL'),
        ],
      ),
    );
  }
}