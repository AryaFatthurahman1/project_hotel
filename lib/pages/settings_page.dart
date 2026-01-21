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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B14),
      appBar: AppBar(
        title: const Text('PENGATURAN & STATISTIK', style: TextStyle(letterSpacing: 2, fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B3022),
        elevation: 0,
        foregroundColor: const Color(0xFFD4AF37),
      ),
      body: SingleChildScrollView(
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
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            Text(
              widget.user.email,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),

            const SizedBox(height: 40),

            // Statistics Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3022),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('STATISTIK PEMESANAN', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const Icon(Icons.bar_chart, color: Color(0xFFD4AF37), size: 18),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 20,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const titles = ['JAN', 'FEB', 'MAR', 'APR', 'MEI'];
                                  return Text(titles[value.toInt() % titles.length], style: const TextStyle(color: Colors.white38, fontSize: 10));
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: const Color(0xFFD4AF37), width: 15)]),
                            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 15, color: const Color(0xFFD4AF37), width: 15)]),
                            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 10, color: const Color(0xFFD4AF37), width: 15)]),
                            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 18, color: const Color(0xFFD4AF37), width: 15)]),
                            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 12, color: const Color(0xFFD4AF37), width: 15)]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Date & Notes Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3022),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CATATAN PERJALANAN', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 20),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('TANGGAL RENCANA', style: TextStyle(color: Colors.white60, fontSize: 10)),
                      subtitle: Text(DateFormat('EEEE, d MMMM yyyy').format(_selectedDate), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today, color: Color(0xFFD4AF37), size: 20),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _noteController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan catatan atau keinginan Anda di sini...',
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Catatan berhasil disimpan')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('SIMPAN PERUBAHAN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
}
