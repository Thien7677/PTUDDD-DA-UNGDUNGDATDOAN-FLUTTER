import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../services/firebase_service.dart';

class OwnerOrdersScreen extends StatefulWidget {
  const OwnerOrdersScreen({super.key});

  @override
  State<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends State<OwnerOrdersScreen> {
  String _filterStatus = 'all';

  final Map<String, String> _statusLabels = {
    'all': 'Tất cả',
    'pending': 'Chờ duyệt',
    'confirmed': 'Đã nhận',
    'preparing': 'Đang làm',
    'delivering': 'Đang giao',
    'completed': 'Hoàn tất',
    'cancelled': 'Đã hủy',
  };

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
      case 'preparing':
        return Colors.blue;
      case 'delivering':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActionButtons(BuildContext context, Order order) {
    if (order.id == null) return const SizedBox.shrink();

    Future<void> updateStatus(String newStatus) async {
      await FirebaseService.instance.updateOrderStatus(order.id!, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã chuyển đơn ${order.orderCode} sang "${_statusLabels[newStatus]}"'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }

    switch (order.status) {
      case 'pending':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => updateStatus('cancelled'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hủy đơn'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => updateStatus('confirmed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD9532F),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Xác nhận đơn'),
              ),
            ),
          ],
        );
      case 'confirmed':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => updateStatus('preparing'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: const Text('Bắt đầu chuẩn bị món'),
          ),
        );
      case 'preparing':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => updateStatus('delivering'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
            child: const Text('Giao cho tài xế'),
          ),
        );
      case 'delivering':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => updateStatus('completed'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Xác nhận đã giao xong'),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý đơn hàng (Chủ quán)')),
      body: Column(
        children: [
          // Thanh lọc trạng thái
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: _statusLabels.entries.map((entry) {
                final selected = _filterStatus == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(entry.value),
                    selected: selected,
                    selectedColor: const Color(0xFFD9532F),
                    labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
                    onSelected: (_) => setState(() => _filterStatus = entry.key),
                  ),
                );
              }).toList(),
            ),
          ),
          // Danh sách đơn hàng realtime
          Expanded(
            child: StreamBuilder<List<Order>>(
              stream: FirebaseService.instance.getOrdersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allOrders = snapshot.data ?? [];
                final filtered = _filterStatus == 'all'
                    ? allOrders
                    : allOrders.where((o) => o.status == _filterStatus).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('Không có đơn hàng nào'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(order.orderCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(order.status).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _statusLabels[order.status] ?? order.status,
                                    style: TextStyle(
                                      color: _statusColor(order.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Quán: ${order.restaurantName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('Địa chỉ: ${order.deliveryAddress}'),
                            Text('Thời gian: ${dateFormat.format(order.createdAt)}'),
                            const SizedBox(height: 6),
                            Text(
                              'Tổng tiền: ${currency.format(order.totalAmount)} (${order.paymentMethod})',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD9532F)),
                            ),
                            const SizedBox(height: 12),
                            _buildActionButtons(context, order),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}