class AppPrices {
  static const Map<String, int> roomRates = {
    'DELUXE_ROOM': 1200000,
    'SUITE_ROOM': 2500000,
    'GRAND_SUITE': 5000000,
    'PRESIDENTIAL': 15000000,
  };

  static const Map<String, int> additionalServices = {
    'SPA_MASSAGE': 500000,
    'AIRPORT_PICKUP': 350000,
    'LATE_CHECKOUT': 200000,
    'BREAKFAST_EXTRA': 150000,
  };

  static const List<Map<String, dynamic>> hotelListPrice = [
    {
      'name': 'The Emerald Imperial Jakarta',
      'price': 2500000,
      'discount': '30%',
    },
    {
      'name': 'Sapphire Garden Bali',
      'price': 1850000,
      'discount': '10%',
    },
    {
      'name': 'Ruby City Bandung',
      'price': 950000,
      'discount': 'FREE SPA',
    }
  ];
}
