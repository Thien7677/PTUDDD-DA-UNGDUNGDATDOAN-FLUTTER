import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/restaurant.dart';
import '../models/food_item.dart';
import '../models/order.dart';
import '../models/review.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._init();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseService._init();

  // Collection references
  CollectionReference get _restaurantsCol => _db.collection('restaurants');
  CollectionReference get _foodItemsCol => _db.collection('food_items');
  CollectionReference get _ordersCol => _db.collection('orders');
  CollectionReference get _reviewsCol => _db.collection('reviews');

  // ========== RESTAURANTS ==========
  Future<List<Restaurant>> getAllRestaurants() async {
    try {
      final snapshot = await _restaurantsCol.get();
      return snapshot.docs.map((doc) {
        return Restaurant.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Firebase getAllRestaurants error: $e');
      return [];
    }
  }
    Stream<List<Restaurant>> getRestaurantsStream() {
    return _restaurantsCol.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Restaurant.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
  Stream<List<Order>> getOrdersStream() {
    return _ordersCol
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Order.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
  Future<Restaurant?> getRestaurantById(String id) async {
    try {
      final doc = await _restaurantsCol.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Restaurant.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Firebase getRestaurantById error: $e');
      return null;
    }
  }

  Future<List<Restaurant>> searchRestaurants(String query) async {
    try {
      final snapshot = await _restaurantsCol.get();
      final q = query.toLowerCase().trim();
      return snapshot.docs
          .map((doc) => Restaurant.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((r) =>
              r.name.toLowerCase().contains(q) ||
              r.category.toLowerCase().contains(q) ||
              r.address.toLowerCase().contains(q))
          .toList();
    } catch (e) {
      print('Firebase searchRestaurants error: $e');
      return [];
    }
  }

  // ========== FOOD ITEMS ==========
  Future<List<FoodItem>> getFoodItemsByRestaurant(String restaurantId) async {
    try {
      final snapshot = await _foodItemsCol
          .where('restaurantId', isEqualTo: restaurantId)
          .get();
      return snapshot.docs.map((doc) {
        return FoodItem.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Firebase getFoodItemsByRestaurant error: $e');
      return [];
    }
  }

  Stream<List<FoodItem>> getFoodItemsStream(String restaurantId) {
    return _foodItemsCol
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FoodItem.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // ========== ORDERS ==========
  Future<String> insertOrder(Order order) async {
    try {
      final docRef = await _ordersCol.add(order.toMap());
      return docRef.id;
    } catch (e) {
      print('Firebase insertOrder error: $e');
      rethrow;
    }
  }

  Future<List<Order>> getAllOrders() async {
    try {
      final snapshot = await _ordersCol.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) {
        return Order.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Firebase getAllOrders error: $e');
      return [];
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _ordersCol.doc(orderId).update({'status': status});
    } catch (e) {
      print('Firebase updateOrderStatus error: $e');
    }
  }

  // ========== REVIEWS ==========
  Future<List<Review>> getReviewsByRestaurant(String restaurantId) async {
    try {
      final snapshot = await _reviewsCol
          .where('restaurantId', isEqualTo: restaurantId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        return Review.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Firebase getReviewsByRestaurant error: $e');
      return [];
    }
  }

  Future<void> insertReview(Review review) async {
    try {
      await _reviewsCol.add(review.toMap());
    } catch (e) {
      print('Firebase insertReview error: $e');
    }
  }

  // ========== SEED SAMPLE DATA TO FIREBASE ==========
  /// Đẩy toàn bộ dữ liệu mẫu lên Firestore
  Future<bool> uploadSampleDataToFirebase() async {
    try {
      final batch = _db.batch();

      // Danh sách 5 nhà hàng mẫu
      final restaurants = [
        {
          'id': 'res_1',
          'name': 'Phở Hà Nội',
          'address': '123 Nguyễn Huệ, Quận 1, TP.HCM',
          'imageUrl': 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=400',
          'rating': 4.5,
          'category': 'Món Việt',
          'latitude': 10.7769,
          'longitude': 106.7009,
          'description': 'Phở bò truyền thống Hà Nội ngon nhất Sài Gòn',
          'deliveryTime': 25,
        },
        {
          'id': 'res_2',
          'name': 'Pizza Hut',
          'address': '45 Lê Lợi, Quận 1, TP.HCM',
          'imageUrl': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
          'rating': 4.2,
          'category': 'Pizza',
          'latitude': 10.7731,
          'longitude': 106.7015,
          'description': 'Pizza Ý chính gốc với nhiều topping hấp dẫn',
          'deliveryTime': 30,
        },
        {
          'id': 'res_3',
          'name': 'KFC',
          'address': '78 Pasteur, Quận 3, TP.HCM',
          'imageUrl': 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400',
          'rating': 4.0,
          'category': 'Gà rán',
          'latitude': 10.7825,
          'longitude': 106.6958,
          'description': 'Gà rán giòn tan, sốt đậm đà',
          'deliveryTime': 20,
        },
        {
          'id': 'res_4',
          'name': 'Bún Chả Hà Nội',
          'address': '56 Võ Văn Tần, Quận 3, TP.HCM',
          'imageUrl': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
          'rating': 4.7,
          'category': 'Món Việt',
          'latitude': 10.7780,
          'longitude': 106.6900,
          'description': 'Bún chả chuẩn vị Hà Nội',
          'deliveryTime': 25,
        },
        {
          'id': 'res_5',
          'name': 'Sushi Tokyo',
          'address': '12 Nguyễn Thị Minh Khai, Quận 1, TP.HCM',
          'imageUrl': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400',
          'rating': 4.6,
          'category': 'Nhật Bản',
          'latitude': 10.7800,
          'longitude': 106.6980,
          'description': 'Sushi tươi ngon mỗi ngày',
          'deliveryTime': 35,
        },
      ];

      for (var r in restaurants) {
        final id = r['id'] as String;
        final docRef = _restaurantsCol.doc(id);
        batch.set(docRef, r);
      }

      // Danh sách món ăn mẫu
      final foods = [
        // Phở Hà Nội
        {'restaurantId': 'res_1', 'name': 'Phở Bò Tái', 'description': 'Phở bò tái chín, nước dùng đậm đà', 'price': 55000.0, 'imageUrl': 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=300', 'category': 'Món chính'},
        {'restaurantId': 'res_1', 'name': 'Phở Bò Nạm', 'description': 'Phở bò nạm mềm, thơm ngon', 'price': 60000.0, 'imageUrl': 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=300', 'category': 'Món chính'},
        {'restaurantId': 'res_1', 'name': 'Phở Gà', 'description': 'Phở gà ta, nước dùng trong', 'price': 50000.0, 'imageUrl': 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=300', 'category': 'Món chính'},
        {'restaurantId': 'res_1', 'name': 'Trà Đá', 'description': 'Trà đá mát lạnh', 'price': 10000.0, 'imageUrl': 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=300', 'category': 'Đồ uống'},

        // Pizza Hut
        {'restaurantId': 'res_2', 'name': 'Pizza Hải Sản', 'description': 'Pizza hải sản cao cấp', 'price': 189000.0, 'imageUrl': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=300', 'category': 'Pizza'},
        {'restaurantId': 'res_2', 'name': 'Pizza Pepperoni', 'description': 'Pizza pepperoni truyền thống', 'price': 159000.0, 'imageUrl': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=300', 'category': 'Pizza'},
        {'restaurantId': 'res_2', 'name': 'Pizza Rau Củ', 'description': 'Pizza chay rau củ tươi', 'price': 139000.0, 'imageUrl': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=300', 'category': 'Pizza'},
        {'restaurantId': 'res_2', 'name': 'Coca Cola', 'description': 'Nước ngọt có ga', 'price': 25000.0, 'imageUrl': 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=300', 'category': 'Đồ uống'},

        // KFC
        {'restaurantId': 'res_3', 'name': 'Gà Rán (2 miếng)', 'description': 'Gà rán giòn tan', 'price': 69000.0, 'imageUrl': 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=300', 'category': 'Gà rán'},
        {'restaurantId': 'res_3', 'name': 'Combo Gà + Khoai', 'description': 'Gà rán + khoai tây chiên', 'price': 99000.0, 'imageUrl': 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=300', 'category': 'Combo'},
        {'restaurantId': 'res_3', 'name': 'Burger Gà', 'description': 'Burger gà giòn', 'price': 45000.0, 'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300', 'category': 'Burger'},

        // Bún Chả Hà Nội
        {'restaurantId': 'res_4', 'name': 'Bún Chả Hà Nội', 'description': 'Bún chả thịt nướng thơm lừng', 'price': 65000.0, 'imageUrl': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=300', 'category': 'Món chính'},
        {'restaurantId': 'res_4', 'name': 'Nem Rán', 'description': 'Nem rán giòn', 'price': 35000.0, 'imageUrl': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=300', 'category': 'Khai vị'},

        // Sushi Tokyo
        {'restaurantId': 'res_5', 'name': 'Sushi Cá Hồi', 'description': 'Sushi cá hồi tươi', 'price': 89000.0, 'imageUrl': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=300', 'category': 'Sushi'},
        {'restaurantId': 'res_5', 'name': 'Sashimi Tổng Hợp', 'description': 'Sashimi cá hồi, cá ngừ, bạch tuộc', 'price': 199000.0, 'imageUrl': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=300', 'category': 'Sashimi'},
        {'restaurantId': 'res_5', 'name': 'Miso Soup', 'description': 'Súp miso truyền thống', 'price': 35000.0, 'imageUrl': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=300', 'category': 'Súp'},
      ];

      for (int i = 0; i < foods.length; i++) {
        final f = foods[i];
        final docRef = _foodItemsCol.doc('food_${i + 1}');
        batch.set(docRef, {
          ...f,
          'id': 'food_${i + 1}',
        });
      }

      // Đánh giá mẫu
      final reviews = [
        {
          'id': 'rev_1',
          'restaurantId': 'res_1',
          'userName': 'Nguyễn Văn A',
          'rating': 5.0,
          'comment': 'Phở ngon quá, nước dùng đậm đà!',
          'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        },
        {
          'id': 'rev_2',
          'restaurantId': 'res_1',
          'userName': 'Trần Thị B',
          'rating': 4.5,
          'comment': 'Giao hàng nhanh, món nóng hổi',
          'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        },
        {
          'id': 'rev_3',
          'restaurantId': 'res_2',
          'userName': 'Lê Văn C',
          'rating': 4.0,
          'comment': 'Pizza ngon nhưng hơi mặn',
          'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
        {
          'id': 'rev_4',
          'restaurantId': 'res_3',
          'userName': 'Phạm Thị D',
          'rating': 4.5,
          'comment': 'Gà rán giòn, giao nhanh',
          'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        },
      ];

      for (var rev in reviews) {
        final id = rev['id'] as String;
        final docRef = _reviewsCol.doc(id);
        batch.set(docRef, rev);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Firebase seed data error: $e');
      return false;
    }
  }
}
