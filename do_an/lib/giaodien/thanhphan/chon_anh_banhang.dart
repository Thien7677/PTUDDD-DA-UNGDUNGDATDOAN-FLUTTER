import 'package:flutter/material.dart';
import '../../dichvu/dichvu_anhquan.dart';
import '../../mohinh/anh_quan.dart';
import 'ban_hang.dart';

class ChonAnhBanHang extends StatefulWidget {
  const ChonAnhBanHang({
    super.key,
    required this.nhan,
    required this.onThayDoi,
    this.duongdananh = '',
    this.anhmau = '',
    this.danggui = false,
    this.chonanh = DichVuAnhQuan.chonAnh,
  });
  final String nhan, duongdananh, anhmau;
  final bool danggui;
  final ValueChanged<AnhQuan?> onThayDoi;
  final Future<AnhQuan?> Function() chonanh;
  @override
  State<ChonAnhBanHang> createState() => _TrangThaiChonAnhBanHang();
}

class _TrangThaiChonAnhBanHang extends State<ChonAnhBanHang> {
  AnhQuan? _anh;
  bool _dangchon = false;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(widget.nhan, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      if (_anh == null)
        AnhMon(
          duongdananh: widget.duongdananh,
          anhmau: widget.anhmau,
          height: 180,
        )
      else
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            _anh!.dulieu,
            height: 180,
            fit: BoxFit.cover,
            cacheWidth: 880,
          ),
        ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: widget.danggui || _dangchon
            ? null
            : () async {
                setState(() => _dangchon = true);
                try {
                  final anh = await widget.chonanh();
                  if (!mounted || anh == null) return;
                  setState(() => _anh = anh);
                  widget.onThayDoi(anh);
                } catch (loi) {
                  if (context.mounted) baoLoi(context, loi);
                } finally {
                  if (mounted) setState(() => _dangchon = false);
                }
              },
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: Text(_dangchon ? 'Đang đọc ảnh…' : 'Chọn ảnh từ thiết bị'),
      ),
      if (_anh != null)
        TextButton(
          onPressed: widget.danggui
              ? null
              : () {
                  setState(() => _anh = null);
                  widget.onThayDoi(null);
                },
          child: const Text('Bỏ ảnh vừa chọn'),
        ),
      const Text(
        'JPG, PNG hoặc WebP • Tối đa 5 MB • Ảnh sẽ được thu gọn trước khi lưu',
        style: TextStyle(fontSize: 12),
      ),
    ],
  );
}
