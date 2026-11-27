import '../models/restaurant.dart';
import '../models/food_item.dart';
import '../models/review.dart';

class MockDataService {
  static final List<Restaurant> restaurants = [
    Restaurant(
      id: 'res_1',
      name: 'Phở Bò Gia Truyền',
      address: '123 Lê Lợi, Quận 1, TP.HCM',
      category: 'Món Việt',
      deliveryTime: 25,
      description: 'Phở bò nước dùng hầm xương 12 tiếng, thịt bò tươi ngon.',
      imageUrl: 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=600',
      latitude: 10.7769,
      longitude: 106.7009,
      rating: 4.8,
    ),
    Restaurant(
      id: 'res_2',
      name: 'Burger & Pizza House',
      address: '45 Nguyễn Huệ, Quận 1, TP.HCM',
      category: 'Đồ ăn nhanh',
      deliveryTime: 30,
      description: 'Burger bò Mỹ nướng than và Pizza đế mỏng kiểu Ý.',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600',
      latitude: 10.7731,
      longitude: 106.7038,
      rating: 4.5,
    ),
    Restaurant(
      id: 'res_3',
      name: 'Trà Sữa & Ăn Vặt Koi',
      address: '88 Pasteur, Quận 3, TP.HCM',
      category: 'Đồ uống',
      deliveryTime: 15,
      description: 'Trà sữa trân châu đường đen và các món ăn vặt hấp dẫn.',
      imageUrl: 'https://images.unsplash.com/photo-1558857563-b371033873b8?w=600',
      latitude: 10.7800,
      longitude: 106.6950,
      rating: 4.7,
    ),
  ];

  static final List<FoodItem> foodItems = [
    FoodItem(
      id: 'food_1',
      restaurantId: 'res_1',
      name: 'Phở Tái Nạm',
      description: 'Bánh phở mềm, thịt bò tái nạm thơm ngọt.',
      price: 55000,
      imageUrl: 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=400',
      category: 'Món chính',
    ),
    FoodItem(
      id: 'food_2',
      restaurantId: 'res_1',
      name: 'Phở Đặc Biệt',
      description: 'Đầy đủ tái, nạm, gầu, gân, bò viên.',
      price: 70000,
      imageUrl: 'https://images.unsplash.com/photo-1576577445504-6af96477db52?w=400',
      category: 'Món chính',
    ),
    FoodItem(
      id: 'food_3',
      restaurantId: 'res_2',
      name: 'Burger Bò Phô Mai',
      description: 'Thịt bò nướng kèm phô mai Cheddar tan chảy.',
      price: 65000,
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      category: 'Burger',
    ),
    FoodItem(
      id: 'food_4',
      restaurantId: 'res_2',
      name: 'Pizza Hải Sản',
      description: 'Tôm, mực tươi kèm sốt cà chua và phô mai Mozzarella.',
      price: 120000,
      imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
      category: 'Pizza',
    ),
    FoodItem(
      id: 'food_5',
      restaurantId: 'res_3',
      name: 'Trà Sữa Trân Châu Đường Đen',
      description: 'Sữa tươi nguyên chất kết hợp trân châu đường đen dẻo.',
      price: 45000,
      imageUrl: 'https://images.unsplash.com/photo-1558857563-b371033873b8?w=400',
      category: 'Trà sữa',
    ),
  ];

  static final List<Review> reviews = [
    Review(
      id: 'rev_1',
      restaurantId: 'res_1',
      userName: 'Nguyễn Văn A',
      rating: 5.0,
      comment: 'Nước dùng rất đậm đà, giao hàng nhanh còn nóng hổi!',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Review(
      id: 'rev_2',
      restaurantId: 'res_2',
      userName: 'Trần Thị B',
      rating: 4.5,
      comment: 'Burger ngon, thịt mềm nhưng khoai tây hơi ít.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static List<FoodItem> getFoodsByRestaurant(String restaurantId) {
    return foodItems.where((f) => f.restaurantId == restaurantId).toList();
  }

  static List<Review> getReviewsByRestaurant(String restaurantId) {
    return reviews.where((r) => r.restaurantId == restaurantId).toList();
  }
}