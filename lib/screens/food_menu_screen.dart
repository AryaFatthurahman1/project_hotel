import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project_hotel1/models/food_model.dart';
import 'package:project_hotel1/services/api_service.dart';
import 'package:project_hotel1/utils/colors.dart';

class FoodMenuScreen extends StatefulWidget {
  const FoodMenuScreen({super.key});

  @override
  State<FoodMenuScreen> createState() => _FoodMenuScreenState();
}

class _FoodMenuScreenState extends State<FoodMenuScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FoodItem> _allFoods = [];
  bool _isLoading = true;
  final List<Map<String, String>> _categories = [
    {'key': 'all', 'label': 'Semua'},
    {'key': 'main_course', 'label': 'Hidangan Utama'},
    {'key': 'appetizer', 'label': 'Appetizer'},
    {'key': 'dessert', 'label': 'Dessert'},
    {'key': 'beverage', 'label': 'Minuman'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadFoodMenu();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadFoodMenu() async {
    setState(() => _isLoading = true);

    final result = await ApiService.getFoodMenu();

    if (result['success'] == true && result['data'] != null) {
      setState(() {
        _allFoods = (result['data'] as List)
            .map((e) => FoodItem.fromJson(e))
            .toList();
      });
    } else {
      // Use sample data if API fails
      setState(() {
        _allFoods = _getSampleFoods();
      });
    }

    setState(() => _isLoading = false);
  }

  List<FoodItem> _getSampleFoods() {
    return [
      FoodItem(
        id: 1,
        name: 'Nasi Goreng Seafood',
        description: 'Nasi goreng spesial dengan udang, cumi, dan sayuran segar',
        price: 85000,
        priceFormatted: 'Rp 85.000',
        category: 'main_course',
        imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800',
        isAvailable: true,
        isFeatured: true,
      ),
      FoodItem(
        id: 2,
        name: 'Sate Ayam',
        description: 'Sate ayam premium dengan bumbu kacang khas',
        price: 65000,
        priceFormatted: 'Rp 65.000',
        category: 'main_course',
        imageUrl: 'https://images.unsplash.com/photo-1529563021893-cc83c992d28f?w=800',
        isAvailable: true,
        isFeatured: true,
      ),
      FoodItem(
        id: 3,
        name: 'Es Teler',
        description: 'Minuman segar dengan alpukat, kelapa muda, dan nangka',
        price: 35000,
        priceFormatted: 'Rp 35.000',
        category: 'beverage',
        imageUrl: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=800',
        isAvailable: true,
        isFeatured: false,
      ),
      FoodItem(
        id: 4,
        name: 'Chocolate Lava Cake',
        description: 'Kue coklat lumer dengan es krim vanilla',
        price: 55000,
        priceFormatted: 'Rp 55.000',
        category: 'dessert',
        imageUrl: 'https://images.unsplash.com/photo-1624353365286-3f8d62daad51?w=800',
        isAvailable: true,
        isFeatured: true,
      ),
      FoodItem(
        id: 5,
        name: 'Caesar Salad',
        description: 'Salad segar dengan dressing caesar dan crouton',
        price: 45000,
        priceFormatted: 'Rp 45.000',
        category: 'appetizer',
        imageUrl: 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?w=800',
        isAvailable: true,
        isFeatured: false,
      ),
    ];
  }

  List<FoodItem> _getFilteredFoods(String category) {
    if (category == 'all') return _allFoods;
    return _allFoods.where((f) => f.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Menu Restaurant'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _categories.map((c) => Tab(text: c['label'])).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _categories.map((c) {
                final foods = _getFilteredFoods(c['key']!);
                return foods.isEmpty
                    ? _buildEmptyState()
                    : _buildFoodGrid(foods);
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCart,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Keranjang'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada menu',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodGrid(List<FoodItem> foods) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: foods.length,
      itemBuilder: (context, index) => _buildFoodCard(foods[index]),
    );
  }

  Widget _buildFoodCard(FoodItem food) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        onTap: () => _showFoodDetail(food),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Featured Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: food.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant, size: 40),
                    ),
                  ),
                ),
                if (food.isFeatured)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '★ Best',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      food.categoryLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          food.priceFormatted,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFoodDetail(FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: food.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              food.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                food.categoryLabel,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              food.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  food.priceFormatted,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${food.name} ditambahkan ke keranjang'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.shopping_cart, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Keranjang'),
          ],
        ),
        content: const Text('Keranjang Anda masih kosong. Silakan pilih menu untuk memesan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
