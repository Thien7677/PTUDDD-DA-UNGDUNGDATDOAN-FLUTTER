import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/restaurant.dart';
import '../models/food_item.dart';
import '../models/order.dart';
import '../models/review.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('food_order.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Bảng nhà hàng
    await db.execute('''
      CREATE TABLE restaurants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        imageUrl TEXT,
        rating REAL,
        category TEXT,
        latitude REAL,
        longitude REAL,
        description TEXT,
        deliveryTime INTEGER
      )
    ''');

    // Bảng món ăn
    await db.execute('''
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        restaurantId INTEGER,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        imageUrl TEXT,
        category TEXT,
        FOREIGN KEY (restaurantId) REFERENCES restaurants (id)
      )
    ''');

    // Bảng đơn hàng
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderCode TEXT NOT NULL,
        restaurantId INTEGER,
        restaurantName TEXT,
        totalAmount REAL,
        status TEXT,
        deliveryAddress TEXT,
        paymentMethod TEXT,
        createdAt TEXT,
        itemsJson TEXT
      )
    ''');

    // Bảng đánh giá
    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        restaurantId INTEGER,
        userName TEXT,
        rating REAL,
        comment TEXT,
        createdAt TEXT,
        FOREIGN KEY (restaurantId) REFERENCES restaurants (id)
      )
    ''');

    // Thêm dữ liệu mẫu
    await _insertSampleData(db);
  }

  Future _insertSampleData(Database db) async {
    // Nhà hàng mẫu
    final restaurants = [
      {
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
      await db.insert('restaurants', r);
    }

    // Món ăn mẫu
    final foods = [
      // Phở Hà Nội
      {'restaurantId': 1, 'name': 'Phở Bò Tái', 'description': 'Phở bò tái chín, nước dùng đậm đà', 'price': 55000, 'imageUrl': 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=300', 'category': 'Món chính'},
      {'restaurantId': 1, 'name': 'Phở Bò Nạm', 'description': 'Phở bò nạm mềm, thơm ngon', 'price': 60000, 'imageUrl': 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=300', 'category': 'Món chính'},
      {'restaurantId': 1, 'name': 'Phở Gà', 'description': 'Phở gà ta, nước dùng trong', 'price': 50000, 'imageUrl': 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=300', 'category': 'Món chính'},
      {'restaurantId': 1, 'name': 'Trà Đá', 'description': 'Trà đá mát lạnh', 'price': 10000, 'imageUrl': 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=300', 'category': 'Đồ uống'},

      // Pizza Hut
      {'restaurantId': 2, 'name': 'Pizza Hải Sản', 'description': 'Pizza hải sản cao cấp', 'price': 189000, 'imageUrl': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=300', 'category': 'Pizza'},
      {'restaurantId': 2, 'name': 'Pizza Pepperoni', 'description': 'Pizza pepperoni truyền thống', 'price': 159000, 'imageUrl': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=300', 'category': 'Pizza'},
      {'restaurantId': 2, 'name': 'Pizza Rau Củ', 'description': 'Pizza chay rau củ tươi', 'price': 139000, 'imageUrl': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=300', 'category': 'Pizza'},
      {'restaurantId': 2, 'name': 'Coca Cola', 'description': 'Nước ngọt có ga', 'price': 25000, 'imageUrl': 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=300', 'category': 'Đồ uống'},

      // KFC
      {'restaurantId': 3, 'name': 'Gà Rán (2 miếng)', 'description': 'Gà rán giòn tan', 'price': 69000, 'imageUrl': 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=300', 'category': 'Gà rán'},
      {'restaurantId': 3, 'name': 'Combo Gà + Khoai', 'description': 'Gà rán + khoai tây chiên', 'price': 99000, 'imageUrl': 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=300', 'category': 'Combo'},
      {'restaurantId': 3, 'name': 'Burger Gà', 'description': 'Burger gà giòn', 'price': 45000, 'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300', 'category': 'Burger'},

      // Bún Chả
      {'restaurantId': 4, 'name': 'Bún Chả Hà Nội', 'description': 'Bún chả thịt nướng thơm lừng', 'price': 65000, 'imageUrl': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=300', 'category': 'Món chính'},
      {'restaurantId': 4, 'name': 'Nem Rán', 'description': 'Nem rán giòn', 'price': 35000, 'imageUrl': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=300', 'category': 'Khai vị'},

      // Sushi
      {'restaurantId': 5, 'name': 'Sushi Cá Hồi', 'description': 'Sushi cá hồi tươi', 'price': 89000, 'imageUrl': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=300', 'category': 'Sushi'},
      {'restaurantId': 5, 'name': 'Sashimi Tổng Hợp', 'description': 'Sashimi cá hồi, cá ngừ, bạch tuộc', 'price': 199000, 'imageUrl': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=300', 'category': 'Sashimi'},
      {'restaurantId': 5, 'name': 'Miso Soup', 'description': 'Súp miso truyền thống', 'price': 35000, 'imageUrl': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=300', 'category': 'Súp'},
    ];

    for (var f in foods) {
      await db.insert('food_items', f);
    }

    // Đánh giá mẫu
    final reviews = [
      {'restaurantId': 1, 'userName': 'Nguyễn Văn A', 'rating': 5.0, 'comment': 'Phở ngon quá, nước dùng đậm đà!', 'createdAt': DateTime.now().subtract(Duration(days: 2)).toIso8601String()},
      {'restaurantId': 1, 'userName': 'Trần Thị B', 'rating': 4.5, 'comment': 'Giao hàng nhanh, món nóng hổi', 'createdAt': DateTime.now().subtract(Duration(days: 5)).toIso8601String()},
      {'restaurantId': 2, 'userName': 'Lê Văn C', 'rating': 4.0, 'comment': 'Pizza ngon nhưng hơi mặn', 'createdAt': DateTime.now().subtract(Duration(days: 1)).toIso8601String()},
      {'restaurantId': 3, 'userName': 'Phạm Thị D', 'rating': 4.5, 'comment': 'Gà rán giòn, giao nhanh', 'createdAt': DateTime.now().subtract(Duration(days: 3)).toIso8601String()},
    ];

    for (var r in reviews) {
      await db.insert('reviews', r);
    }
  }

  // ========== RESTAURANT ==========
  Future<List<Restaurant>> getAllRestaurants() async {
    final db = await database;
    final result = await db.query('restaurants');
    return result.map((e) => Restaurant.fromMap(e)).toList();
  }

  Future<List<Restaurant>> searchRestaurants(String query) async {
    final db = await database;
    final result = await db.query(
      'restaurants',
      where: 'name LIKE ? OR category LIKE ? OR address LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return result.map((e) => Restaurant.fromMap(e)).toList();
  }

  Future<Restaurant?> getRestaurantById(int id) async {
    final db = await database;
    final result = await db.query('restaurants', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) return Restaurant.fromMap(result.first);
    return null;
  }

  // ========== FOOD ITEMS ==========
  Future<List<FoodItem>> getFoodItemsByRestaurant(int restaurantId) async {
    final db = await database;
    final result = await db.query(
      'food_items',
      where: 'restaurantId = ?',
      whereArgs: [restaurantId],
    );
    return result.map((e) => FoodItem.fromMap(e)).toList();
  }

  // ========== ORDERS ==========
  Future<int> insertOrder(Order order) async {
    final db = await database;
    return await db.insert('orders', order.toMap());
  }

  Future<List<Order>> getAllOrders() async {
    final db = await database;
    final result = await db.query('orders', orderBy: 'createdAt DESC');
    return result.map((e) => Order.fromMap(e)).toList();
  }

  Future<Order?> getOrderById(int id) async {
    final db = await database;
    final result = await db.query('orders', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) return Order.fromMap(result.first);
    return null;
  }

  Future<int> updateOrderStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== REVIEWS ==========
  Future<List<Review>> getReviewsByRestaurant(int restaurantId) async {
    final db = await database;
    final result = await db.query(
      'reviews',
      where: 'restaurantId = ?',
      orderBy: 'createdAt DESC',
      whereArgs: [restaurantId],
    );
    return result.map((e) => Review.fromMap(e)).toList();
  }

  Future<int> insertReview(Review review) async {
    final db = await database;
    return await db.insert('reviews', review.toMap());
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}