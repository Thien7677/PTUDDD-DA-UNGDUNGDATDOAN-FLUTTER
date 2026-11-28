import 'package:flutter/material.dart';
import '../../dichvu/kho_banhang.dart';
import '../../mohinh/ban_hang.dart';
import 'ban_hang.dart';
import 'chude.dart';

class CongTacNhanDon extends StatefulWidget {
  const CongTacNhanDon({
    super.key,
    required this.kho,
    required this.uid,
    this.duocnhan = true,
  });
  final KhoBanHang kho;
  final String uid;
  final bool duocnhan;
  @override
  State<CongTacNhanDon> createState() => _TrangThaiCongTacNhanDon();
}

class _TrangThaiCongTacNhanDon extends State<CongTacNhanDon> {
  late final _luong = widget.kho.theoDoiQuanCuaToi(widget.uid);
  bool _dangghi = false;
  @override
  Widget build(BuildContext context) => StreamBuilder<QuanAn?>(
    stream: _luong,
    builder: (context, s) {
      if (s.hasError) return TheTrang(child: Text(thongBaoLoi(s.error!)));
      final q = s.data;
      if (q == null) return const SizedBox.shrink();
      final duocnhan = q.trangthai == 'hoatdong' && widget.duocnhan;
      final dangnhan = duocnhan && q.dangmocua;
      return TheTrang(
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: _dangghi
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  dangnhan ? Icons.storefront : Icons.pause_circle_outline,
                  color: dangnhan ? MauSac.xanh : MauSac.cam,
                ),
          title: Text(
            !duocnhan
                ? 'Quán đang chờ duyệt'
                : dangnhan
                ? 'Đang nhận đơn'
                : 'Tạm dừng nhận đơn',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            !duocnhan
                ? 'Quán cần được duyệt trước khi nhận đơn.'
                : dangnhan
                ? 'Khách có thể đặt món tại quán.'
                : 'Khách vẫn xem thực đơn; các đơn cũ tiếp tục xử lý.',
          ),
          value: dangnhan,
          onChanged: _dangghi || !duocnhan
              ? null
              : (mo) async {
                  setState(() => _dangghi = true);
                  try {
                    await widget.kho.luuQuan(widget.uid, {'dangmocua': mo});
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            mo
                                ? 'Quán đã bật nhận đơn mới.'
                                : 'Quán đã tạm dừng nhận đơn mới.',
                          ),
                        ),
                      );
                    }
                  } catch (loi) {
                    if (context.mounted) baoLoi(context, loi);
                  } finally {
                    if (mounted) setState(() => _dangghi = false);
                  }
                },
        ),
      );
    },
  );
}
