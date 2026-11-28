import 'package:flutter/foundation.dart';
import '../mohinh/hoso_nguoidung.dart';

class LoiTaiKhoan implements Exception {
  const LoiTaiKhoan(this.thongbao);
  final String thongbao;
  @override
  String toString() => thongbao;
}

abstract class KhoTaiKhoan extends ChangeNotifier {
  bool get sansang;
  bool get dangxuly;
  bool get dangtaihoso;
  bool get dadangnhap;
  bool get thieuhoso;
  String? get loiketnoi;
  String? get loihoso;
  String? get emailhientai;
  HoSoNguoiDung? get hoso;

  Future<void> dangNhap(String email, String matkhau);
  Future<void> dangKy(DuLieuDangKy dulieu);
  Future<void> hoanThienHoSo(DuLieuDangKy dulieu);
  Future<void> guiEmailDatLaiMatKhau(String email);
  Future<void> dangXuat();
  void taiLaiHoSo();
}
