import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';

class SettingsPage extends StatefulWidget {
  final User user;
  const SettingsPage({super.key, required this.user});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  File? _image;
  final picker = ImagePicker();
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _noteController = TextEditingController();

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              onPrimary: Colors.black,
              surface: Color(0xFF1B3022),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showPriceList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B3022),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('DAFTAR HARGA LAYANAN', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 20),
              _buildPriceRow('Emerald Suite', 'Rp 2.500.000'),
              _buildPriceRow('Sapphire Room', 'Rp 1.850.000'),
              _buildPriceRow('Ruby Boutique', 'Rp 950.000'),
              _buildPriceRow('Spa & Wellness', 'Rp 500.000'),
              _buildPriceRow('Dinner Package', 'Rp 750.000'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('TUTUP', style: TextStyle(color: Colors.white24))),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildPriceRow(String name, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 13)),
          Text(price, style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B14),
      appBar: AppBar(
        title: const Text('PROFIL & ANALITIK', style: TextStyle(letterSpacing: 2, fontSize: 13, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B3022),
        elevation: 0,
        foregroundColor: const Color(0xFFD4AF37),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Profile Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                      image: _image != null
                          ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                          : const DecorationImage(
                              image: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80'),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _getImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFD4AF37),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              widget.user.name.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 3),
            ),
            Text(
              widget.user.email,
              style: const TextStyle(color: Colors.white38, fontSize: 13, letterSpacing: 1),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFFD4AF37).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(
                widget.user.role?.toUpperCase() ?? 'MEMBER',
                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ),

            const SizedBox(height: 35),
            
            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _buildSimpleStat('LOYALTY', 'GOLD')),
                  const SizedBox(width: 15),
                  Expanded(child: _buildSimpleStat('POINTS', '1,250')),
                  const SizedBox(width: 15),
                  Expanded(child: _buildSimpleStat('SESSIONS', '24')),
                ],
              ),
            ),

            const SizedBox(height: 15),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                onPressed: _showPriceList,
                icon: const Icon(Icons.list_alt, color: Color(0xFFD4AF37), size: 16),
                label: const Text('LIHAT DAFTAR HARGA LAYANAN', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Statistics Chart Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3022),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ANALISIS AKTIVITAS', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12)),
                        const Icon(Icons.show_chart, color: Color(0xFFD4AF37), size: 18),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('Perkembangan pemesanan dalam 5 bulan terakhir', style: TextStyle(color: Colors.white24, fontSize: 10)),
                    const SizedBox(height: 35),
                    SizedBox(
                      height: 180,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const titles = ['JAN', 'FEB', 'MAR', 'APR', 'MEI'];
                                  if (value % 1 == 0 && value >= 0 && value < 5) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(titles[value.toInt()], style: const TextStyle(color: Colors.white24, fontSize: 9)),
                                    );
                                  }
                                  return const Text('');
                                },
                                interval: 1,
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                const FlSpot(0, 3),
                                const FlSpot(1, 5),
                                const FlSpot(2, 4),
                                const FlSpot(3, 8),
                                const FlSpot(4, 6),
                              ],
                              isCurved: true,
                              color: const Color(0xFFD4AF37),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Notes Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3022),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CATATAN PERJALANAN', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12)),
                    const SizedBox(height: 20),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('TANGGAL RENCANA BERIKUTNYA', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
                      subtitle: Text(DateFormat('EEEE, d MMMM yyyy').format(_selectedDate), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_month, color: Color(0xFFD4AF37), size: 22),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    const Divider(color: Colors.white10, height: 30),
                    TextFormField(
                      controller: _noteController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan preferensi kamar atau akomodasi...',
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.2),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Catatan Anda telah diperbarui')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: const Text('UPDATE PROFIL & CATATAN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleStat(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(val, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
