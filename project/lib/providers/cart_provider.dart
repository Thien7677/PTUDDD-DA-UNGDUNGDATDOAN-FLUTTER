import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  int? _restaurantId;
  String? _restaurantName;

  List<CartItem> get items => [..._items];
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _items.fold(0, (sum, item) => sum + item.totalPrice);
  int? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;
  bool get isEmpty => _items.isEmpty;

  void addItem(FoodItem food, {int? restaurantId, String? restaurantName}) {
    // Nếu giỏ hàng đang có món của nhà hàng khác thì xóa hết
    if (_restaurantId != null && _restaurantId != restaurantId) {
      _items.clear();
    }
    _restaurantId = restaurantId;
    _restaurantName = restaurantName;

    final index = _items.indexWhere((item) => item.foodItem.id == food.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(foodItem: food));
    }
    notifyListeners();
  }

  void removeItem(int foodId) {
    _items.removeWhere((item) => item.foodItem.id == foodId);
    if (_items.isEmpty) {
      _restaurantId = null;
      _restaurantName = null;
    }
    notifyListeners();
  }

  void updateQuantity(int foodId, int quantity) {
    final index = _items.indexWhere((item) => item.foodItem.id == foodId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      if (_items.isEmpty) {
        _restaurantId = null;
        _restaurantName = null;
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    _restaurantId = null;
    _restaurantName = null;
    notifyListeners();
  }
}