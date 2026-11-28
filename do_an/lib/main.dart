import 'package:flutter/material.dart';
import 'dichvu/dichvu_taikhoan.dart';
import 'dichvu/kho_taikhoan.dart';
import 'giaodien/thanhphan/chude.dart';
import 'giaodien/trang_dangnhap.dart';
import 'giaodien/trang_taikhoan.dart';
import 'giaodien/trang_saudangnhap.dart';
import 'dichvu/dichvu_banhang.dart';
import 'dichvu/kho_banhang.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final kho = DichVuTaiKhoan();
  await kho.khoiTao();
  runApp(UngDungNoNe(kho: kho));
}

class UngDungNoNe extends StatelessWidget {
  const UngDungNoNe({super.key, required this.kho, this.banhang});
  final KhoTaiKhoan kho;
  final KhoBanHang? banhang;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'No Nê · Đặt đồ ăn',
    debugShowCheckedModeBanner: false,
    theme: MauSac.chude,
    home: AnimatedBuilder(
      animation: kho,
      builder: (context, _) {
        if (!kho.dadangnhap) return TrangDangNhap(kho: kho);
        if (kho.hoso != null) {
          return TrangSauDangNhap(
            key: ValueKey(
              '${kho.hoso!.manguoidung}_${kho.hoso!.loaitaikhoan.giatri}',
            ),
            taikhoan: kho,
            banhang: banhang ?? DichVuBanHang(),
          );
        }
        return TrangXuLyHoSo(kho: kho);
      },
    ),
  );
}
