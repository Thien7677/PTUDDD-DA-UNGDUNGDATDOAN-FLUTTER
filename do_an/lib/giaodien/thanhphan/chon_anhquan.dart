import 'package:flutter/material.dart';
import '../../dichvu/dichvu_anhquan.dart';
import '../../dichvu/kho_taikhoan.dart';
import '../../mohinh/anh_quan.dart';
import 'chude.dart';

class ChonAnhQuan extends StatefulWidget {
  const ChonAnhQuan({
    super.key,
    required this.onThayDoi,
    this.chonanh = DichVuAnhQuan.chonAnh,
    this.danggui = false,
  });
  final ValueChanged<AnhQuan?> onThayDoi;
  final Future<AnhQuan?> Function() chonanh;
  final bool danggui;
  @override
  State<ChonAnhQuan> createState() => _TrangThaiChonAnh();
}

class _TrangThaiChonAnh extends State<ChonAnhQuan> {
  bool _dangchon = false;
  String? _loi;
  @override
  Widget build(BuildContext context) => FormField<AnhQuan>(
    validator: (anh) => anh == null ? 'Bạn phải thêm ảnh của quán.' : null,
    builder: (truong) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Ảnh quán *', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (truong.value != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              truong.value!.dulieu,
              height: 160,
              fit: BoxFit.cover,
              cacheWidth: 880,
            ),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: widget.danggui || _dangchon
              ? null
              : () async {
                  setState(() {
                    _dangchon = true;
                    _loi = null;
                  });
                  try {
                    final anh = await widget.chonanh();
                    if (!mounted || anh == null) return;
                    truong.didChange(anh);
                    widget.onThayDoi(anh);
                  } catch (loi) {
                    if (mounted) {
                      setState(
                        () => _loi = loi is LoiTaiKhoan
                            ? loi.thongbao
                            : 'Chưa mở được thư viện ảnh. Kiểm tra quyền truy cập ảnh.',
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _dangchon = false);
                  }
                },
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(
            _dangchon
                ? 'Đang đọc ảnh…'
                : (truong.value == null ? 'Chọn ảnh quán' : 'Đổi ảnh quán'),
          ),
        ),
        if (truong.value != null)
          TextButton(
            onPressed: widget.danggui || _dangchon
                ? null
                : () {
                    truong.didChange(null);
                    widget.onThayDoi(null);
                  },
            child: const Text('Xóa ảnh'),
          ),
        const Text(
          'Bắt buộc • JPG, PNG hoặc WebP • Tối đa 5 MB',
          style: TextStyle(fontSize: 12, color: MauSac.chuphu),
        ),
        if (_loi != null || truong.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _loi ?? truong.errorText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    ),
  );
}
