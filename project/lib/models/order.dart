class Order {
  final int? id;
  final String orderCode;
  final int restaurantId;
  final String restaurantName;
  final double totalAmount;
  final String status; // pending, confirmed, preparing, delivering, completed, cancelled
  final String deliveryAddress;
  final String paymentMethod;
  final DateTime createdAt;
  final String itemsJson; // JSON string của danh sách món

  Order({
    this.id,
    required this.orderCode,
    required this.restaurantId,
    required this.restaurantName,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.createdAt,
    required this.itemsJson,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderCode': orderCode,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'totalAmount': totalAmount,
      'status': status,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'itemsJson': itemsJson,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      orderCode: map['orderCode'],
      restaurantId: map['restaurantId'],
      restaurantName: map['restaurantName'],
      totalAmount: map['totalAmount'],
      status: map['status'],
      deliveryAddress: map['deliveryAddress'],
      paymentMethod: map['paymentMethod'],
      createdAt: DateTime.parse(map['createdAt']),
      itemsJson: map['itemsJson'],
    );
  }
}