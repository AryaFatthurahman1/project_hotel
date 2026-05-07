import 'package:flutter/material.dart';
import 'package:project_hotel1/services/api_service.dart';
import 'package:project_hotel1/utils/colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {
    'total_users': 0,
    'total_hotels': 0,
    'total_revenue': 'Rp 0',
    'recent_activities': []
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    try {
      final result = await ApiService.get("/dashboard");

      if (result['status'] == true) {
        setState(() {
          _stats = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error loading stats: $e");
      setState(() => _isLoading = false);
      // Fallback data for demo if API fails
      _stats = {
        'total_users': 150,
        'total_hotels': 12,
        'total_revenue': 'Rp 15.000.000',
        'recent_activities': []
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                _loadStats();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard('Total Users', _stats['total_users'].toString(), Icons.people, Colors.blue),
                        _buildStatCard('Total Hotels', _stats['total_hotels'].toString(), Icons.hotel, Colors.orange),
                        _buildStatCard('Revenue', _stats['total_revenue'], Icons.attach_money, Colors.green),
                        _buildStatCard('Active Booking', '5', Icons.calendar_today, Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Recent Activities',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildActivityList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Fitur Tambah Data (CRUD) akan membuka Form Input"))
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    final activities = _stats['recent_activities'] as List;
    if (activities.isEmpty) {
      return Center(
        child: Text(
          'Belum ada aktivitas baru.',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final item = activities[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: const Icon(Icons.receipt, color: AppColors.primary),
            ),
            title: Text(item['hotel_name'] ?? 'Hotel'),
            subtitle: Text('${item['full_name']} • IDR ${item['total_price']}'),
            trailing: Chip(
              label: Text(
                item['status'],
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              backgroundColor: item['status'] == 'confirmed' ? Colors.green : Colors.orange,
            ),
          ),
        );
      },
    );
  }
}
