import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/firebase_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => [..._orders];
  bool get isLoading => _isLoading;

  Future<void> fetchOrders(String customerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final allOrders = await FirebaseService.instance.getAllOrders();
      _orders = allOrders.where((o) => o.customerId == customerId).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> placeOrder({
    required String customerId,
    required String restaurantId,
    required String restaurantName,
    required List<CartItem> items,
    required double subtotal,
    double deliveryFee = 15000,
    required String deliveryAddress,
    required String paymentMethod,
  }) async {
    final newOrder = Order(
      id: const Uuid().v4(),
      orderCode: 'NN-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      customerId: customerId,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      totalAmount: subtotal + deliveryFee,
      status: 'pending',
      paymentStatus: 'unpaid',
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      itemsJson: jsonEncode(items.map((e) => e.toMap()).toList()),
    );

    await FirebaseService.instance.insertOrder(newOrder);
    _orders.insert(0, newOrder);
    notifyListeners();
  }
}