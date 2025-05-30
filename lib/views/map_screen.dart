import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/coffee_shop_controller.dart';
import '../models/coffee_shop.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final CoffeeShopController coffeeController =
      Get.find<CoffeeShopController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee Shop Finder'),
        backgroundColor: Colors.brown[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Get.toNamed('/favorites'),
          ),
        ],
      ),
      body: Obx(() {
        if (coffeeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: coffeeController.currentLocation.value != null
                ? LatLng(
                    coffeeController.currentLocation.value!.latitude,
                    coffeeController.currentLocation.value!.longitude,
                  )
                : const LatLng(
                    10.6788,
                    76.4623,
                  ), // Default to Thiruvilwamala area
            zoom: 14.0,
          ),
          markers: _buildMarkers(),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          coffeeController.getCurrentLocation();
          _moveToCurrentLocation();
        },
        backgroundColor: Colors.brown[600],
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};

    // Add coffee shop markers
    for (CoffeeShop shop in coffeeController.allCoffeeShops) {
      markers.add(
        Marker(
          markerId: MarkerId(shop.name),
          position: LatLng(shop.latitude, shop.longitude),
          icon: coffeeController.isFavorite(shop)
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
              : BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange,
                ),
          onTap: () => _showCoffeeShopBottomSheet(shop),
          infoWindow: InfoWindow(
            title: shop.name,
            snippet: 'Distance: ${coffeeController.getDistanceToShop(shop)}',
          ),
        ),
      );
    }

    return markers;
  }

  void _moveToCurrentLocation() {
    if (coffeeController.currentLocation.value != null &&
        mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            coffeeController.currentLocation.value!.latitude,
            coffeeController.currentLocation.value!.longitude,
          ),
        ),
      );
    }
  }

  void _showCoffeeShopBottomSheet(CoffeeShop shop) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.coffee, color: Colors.brown[600], size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    shop.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[600], size: 20),
                const SizedBox(width: 5),
                Text(
                  'Distance: ${coffeeController.getDistanceToShop(shop)}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                bool isFav = coffeeController.isFavorite(shop);
                return ElevatedButton.icon(
                  onPressed: () {
                    if (isFav) {
                      // Find the favorite shop with ID to remove it
                      CoffeeShop? favoriteShop = coffeeController
                          .favoriteCoffeeShops
                          .firstWhereOrNull((fav) => fav.name == shop.name);
                      if (favoriteShop != null) {
                        coffeeController.removeFromFavorites(favoriteShop);
                      }
                    } else {
                      coffeeController.addToFavorites(shop);
                    }
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                  ),
                  label: Text(
                    isFav ? 'Remove from Favorites' : 'Add to Favorites',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFav
                        ? Colors.red[600]
                        : Colors.brown[600],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
