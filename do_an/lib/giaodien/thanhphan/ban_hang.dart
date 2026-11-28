import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../../dichvu/kho_taikhoan.dart';
import '../../mohinh/ban_hang.dart';
import 'chude.dart';

String thongBaoLoi(Object loi) {
  if (loi is LoiTaiKhoan) return loi.thongbao;
  if (loi is FormatException) return loi.message;
  if (loi is FirebaseException) {
    if (loi.code == 'permission-denied') {
      return 'Thao tác chưa được phép hoặc giá món đã thay đổi. Hãy kiểm tra lại và thử lại.';
    }
    if (loi.code == 'unavailable') {
      return 'Chưa kết nối được máy chủ. Kiểm tra mạng rồi thử lại.';
    }
  }
  return 'Chưa hoàn tất thao tác. Vui lòng thử lại.';
}

void baoLoi(BuildContext context, Object loi) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(thongBaoLoi(loi))));

Future<bool> xacNhan(
  BuildContext context,
  String tieude,
  String noidung, {
  String nut = 'Xác nhận',
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(tieude),
        content: Text(noidung),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Quay lại'),
          ),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(nut)),
        ],
      ),
    ) ??
    false;

class NutXuLy extends StatefulWidget {
  const NutXuLy({
    super.key,
    required this.nhan,
    required this.onNhan,
    this.phu = false,
    this.bieutuong,
  });
  final String nhan;
  final Future<void> Function() onNhan;
  final bool phu;
  final IconData? bieutuong;
  @override
  State<NutXuLy> createState() => _TrangThaiNut();
}

class _TrangThaiNut extends State<NutXuLy> {
  bool _danggui = false;
  @override
  Widget build(BuildContext context) => FilledButton(
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, 44),
      backgroundColor: widget.phu ? MauSac.camnhat : MauSac.cam,
      foregroundColor: widget.phu ? MauSac.cam : Colors.white,
    ),
    onPressed: _danggui
        ? null
        : () async {
            setState(() => _danggui = true);
            try {
              await widget.onNhan();
            } catch (loi) {
              if (context.mounted) baoLoi(context, loi);
            } finally {
              if (mounted) setState(() => _danggui = false);
            }
          },
    child: _danggui
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.bieutuong != null) ...[
                Icon(widget.bieutuong, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(widget.nhan, textAlign: TextAlign.center)),
            ],
          ),
  );
}

class TheTrang extends StatelessWidget {
  const TheTrang({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: child,
  );
}

class NhanTrangThai extends StatelessWidget {
  const NhanTrangThai(this.nhan, {super.key, this.xanh = false});
  final String nhan;
  final bool xanh;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: xanh ? MauSac.xanhnhat : MauSac.camnhat,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      nhan,
      style: TextStyle(fontSize: 12, color: xanh ? MauSac.xanh : MauSac.cam),
    ),
  );
}

class TrangRong extends StatelessWidget {
  const TrangRong(
    this.tieude,
    this.mota, {
    super.key,
    this.bieutuong = Icons.restaurant_outlined,
  });
  final String tieude, mota;
  final IconData bieutuong;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
    child: Column(
      children: [
        Icon(bieutuong, size: 52, color: MauSac.cam),
        const SizedBox(height: 20),
        Text(
          tieude,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          mota,
          textAlign: TextAlign.center,
          style: const TextStyle(color: MauSac.chuphu),
        ),
      ],
    ),
  );
}

class DuLieuTrucTiep<T> extends StatelessWidget {
  const DuLieuTrucTiep({
    super.key,
    required this.stream,
    required this.builder,
  });
  final Stream<T> stream;
  final Widget Function(T) builder;
  @override
  Widget build(BuildContext context) => StreamBuilder<T>(
    stream: stream,
    builder: (context, s) {
      if (s.hasError) {
        return TrangRong(
          'Chưa tải được dữ liệu',
          thongBaoLoi(s.error!),
          bieutuong: Icons.cloud_off_outlined,
        );
      }
      if (!s.hasData) {
        return const Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return builder(s.data as T);
    },
  );
}

class AnhMon extends StatefulWidget {
  const AnhMon({
    super.key,
    this.anhmau = '',
    this.duongdananh = '',
    this.width,
    this.height = 92,
  });
  final String anhmau, duongdananh;
  final double? width;
  final double height;
  static const duongdanmau = {
    'pho':
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=900&q=80',
    'pizza':
        'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=900&q=80',
    'com':
        'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=900&q=80',
    'ga':
        'https://images.unsplash.com/photo-1562967914-608f82629710?auto=format&fit=crop&w=900&q=80',
    'nuoc':
        'https://images.unsplash.com/photo-1544145945-f90425340c7e?auto=format&fit=crop&w=900&q=80',
  };
  @override
  State<AnhMon> createState() => _TrangThaiAnh();
}

class _TrangThaiAnh extends State<AnhMon> {
  Stream<Uint8List?>? _anh;
  @override
  void initState() {
    super.initState();
    _docAnh();
  }

  @override
  void didUpdateWidget(AnhMon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duongdananh != widget.duongdananh) _docAnh();
  }

  void _docAnh() {
    final vitri = widget.duongdananh;
    if (vitri.isEmpty || Firebase.apps.isEmpty) {
      _anh = null;
      return;
    }
    if (RegExp(
      r'^anhquanan/[^/]+$|^anhmonan/[^/]+/anhmon/[^/]+$',
    ).hasMatch(vitri)) {
      _anh = FirebaseFirestore.instance.doc(vitri).snapshots().map((d) {
        final dulieu = d.data()?['dulieu'];
        return dulieu is String ? base64Decode(dulieu) : null;
      });
    } else {
      _anh = FirebaseStorage.instance
          .ref(vitri)
          .getData(5 * 1024 * 1024)
          .asStream();
    }
  }

  Widget _hinh(String? url) => url == null
      ? _trong()
      : Image.network(
          url,
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _trong(),
        );
  Widget _trong() => Container(
    width: widget.width,
    height: widget.height,
    color: MauSac.camnhat,
    alignment: Alignment.center,
    child: const Icon(Icons.restaurant, color: MauSac.cam, size: 32),
  );
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: _anh == null
        ? _hinh(AnhMon.duongdanmau[widget.anhmau])
        : StreamBuilder<Uint8List?>(
            stream: _anh,
            builder: (_, s) => s.hasError || s.data == null
                ? _trong()
                : Image.memory(
                    s.data!,
                    width: widget.width,
                    height: widget.height,
                    fit: BoxFit.cover,
                    cacheWidth: 960,
                    errorBuilder: (_, _, _) => _trong(),
                  ),
          ),
  );
}

class TheQuan extends StatelessWidget {
  const TheQuan({super.key, required this.quan, required this.onNhan});
  final QuanAn quan;
  final VoidCallback onNhan;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onNhan,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              AnhMon(
                anhmau: quan.anhmau,
                duongdananh: quan.duongdananh,
                width: 88,
                height: 104,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quan.tenquan,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      quan.mota.isEmpty ? quan.diachi : quan.mota,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MauSac.chuphu,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Giao hàng ${tienViet(quan.phigiaohang)}',
                      style: const TextStyle(color: MauSac.cam, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      quan.dangmocua ? 'Đang mở cửa' : 'Tạm nghỉ',
                      style: const TextStyle(color: MauSac.xanh, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
