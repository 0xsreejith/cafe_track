import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/coffee_shop_controller.dart';
import '../models/coffee_shop.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CoffeeShopController coffeeController = Get.find<CoffeeShopController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Coffee Shops'),
        backgroundColor: Colors.brown[600],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (coffeeController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (coffeeController.favoriteCoffeeShops.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 20),
                Text(
                  'No favorite coffee shops yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Add some favorites from the map!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.map, color: Colors.white),
                  label: const Text(
                    'Go to Map',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[600],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: coffeeController.favoriteCoffeeShops.length,
          itemBuilder: (context, index) {
            final CoffeeShop shop = coffeeController.favoriteCoffeeShops[index];
            return _buildFavoriteCard(shop, coffeeController);
          },
        );
      }),
    );
  }

  Widget _buildFavoriteCard(CoffeeShop shop, CoffeeShopController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.brown[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.coffee,
                color: Colors.brown[600],
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Distance: ${controller.getDistanceToShop(shop)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lat: ${shop.latitude.toStringAsFixed(4)}, Lng: ${shop.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () => _showRemoveConfirmation(shop, controller),
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  tooltip: 'Remove from favorites',
                ),
                IconButton(
                  onPressed: () => _navigateToShopOnMap(shop),
                  icon: Icon(
                    Icons.map,
                    color: Colors.brown[600],
                  ),
                  tooltip: 'View on map',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveConfirmation(CoffeeShop shop, CoffeeShopController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove from Favorites'),
        content: Text('Are you sure you want to remove "${shop.name}" from your favorites?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeFromFavorites(shop);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToShopOnMap(CoffeeShop shop) {
    Get.back(); // Go back to map screen
    // You could add logic here to center the map on the specific shop
    Get.snackbar(
      'Navigation',
      'Returning to map to view ${shop.name}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
