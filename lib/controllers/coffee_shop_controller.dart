import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../models/coffee_shop.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

class CoffeeShopController extends GetxController {
  // Observable lists
  final RxList<CoffeeShop> favoriteCoffeeShops = <CoffeeShop>[].obs;
  final RxList<CoffeeShop> allCoffeeShops = <CoffeeShop>[].obs;
  final Rx<Position?> currentLocation = Rx<Position?>(null);
  final RxBool isLoading = false.obs;

  // Hardcoded coffee shop locations
  final List<CoffeeShop> _hardcodedShops = [
    CoffeeShop(
      name: "Thiruvilwamala Coffee Point",
      latitude: 10.6788,
      longitude: 76.4623,
    ),
    CoffeeShop(name: "Pazhayannur Cafe", latitude: 10.6422, longitude: 76.4698),
    CoffeeShop(
      name: "Chelakkara Coffee House",
      latitude: 10.6923,
      longitude: 76.4201,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    initializeData();
  }

  Future<void> initializeData() async {
    isLoading.value = true;
    await loadFavoriteCoffeeShops();
    await loadAllCoffeeShops();
    await getCurrentLocation();
    isLoading.value = false;
  }

  Future<void> loadFavoriteCoffeeShops() async {
    try {
      final favorites = await DatabaseService.getFavoriteCoffeeShops();
      favoriteCoffeeShops.assignAll(favorites);
    } catch (e) {
      print('Error loading favorite coffee shops: $e');
    }
  }

  Future<void> loadAllCoffeeShops() async {
    try {
      List<CoffeeShop> updatedShops = [];

      for (CoffeeShop shop in _hardcodedShops) {
        bool isFav = await DatabaseService.isCoffeeShopFavorite(shop.name);
        updatedShops.add(shop.copyWith(isFavorite: isFav));
      }

      allCoffeeShops.assignAll(updatedShops);
    } catch (e) {
      print('Error loading all coffee shops: $e');
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position? position = await LocationService.getCurrentLocation();
      currentLocation.value = position;
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> addToFavorites(CoffeeShop coffeeShop) async {
    try {
      isLoading.value = true;

      // Check if already favorite
      bool isAlreadyFavorite = await DatabaseService.isCoffeeShopFavorite(
        coffeeShop.name,
      );
      if (isAlreadyFavorite) {
        Get.snackbar('Info', '${coffeeShop.name} is already in favorites!');
        isLoading.value = false;
        return;
      }

      // Add to database
      await DatabaseService.insertCoffeeShop(
        coffeeShop.copyWith(isFavorite: true),
      );

      // Reload data
      await loadFavoriteCoffeeShops();
      await loadAllCoffeeShops();

      Get.snackbar('Success', '${coffeeShop.name} added to favorites!');
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to add to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(CoffeeShop coffeeShop) async {
    try {
      isLoading.value = true;

      if (coffeeShop.id != null) {
        await DatabaseService.deleteCoffeeShop(coffeeShop.id!);
      }

      // Reload data
      await loadFavoriteCoffeeShops();
      await loadAllCoffeeShops();

      Get.snackbar('Success', '${coffeeShop.name} removed from favorites!');
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to remove from favorites: $e');
    }
  }

  String getDistanceToShop(CoffeeShop shop) {
    if (currentLocation.value == null) return 'Unknown';

    double distance = LocationService.calculateDistance(
      currentLocation.value!.latitude,
      currentLocation.value!.longitude,
      shop.latitude,
      shop.longitude,
    );

    return LocationService.formatDistance(distance);
  }

  bool isFavorite(CoffeeShop shop) {
    return favoriteCoffeeShops.any((fav) => fav.name == shop.name);
  }
}
