import '../mohinh/ban_hang.dart';
import '../mohinh/hoso_nguoidung.dart';

abstract class KhoBanHang {
  Stream<List<QuanAn>> theoDoiQuan({bool tatca = false});
  Stream<QuanAn?> theoDoiQuanCuaToi(String uid);
  Stream<List<MonAn>> theoDoiMon(String quanid);
  Stream<List<DonHang>> theoDoiDon(HoSoNguoiDung hoso);
  Stream<List<HoSoNguoiDung>> theoDoiNguoiDung();
  Future<void> luuMon(MonAn mon);
  Future<void> anMon(MonAn mon);
  Future<void> luuQuan(String uid, Map<String, dynamic> dulieu);
  Future<String> datHang(
    HoSoNguoiDung hoso,
    GioHang gio, {
    required String maxacnhan,
    required String nguoinhan,
    required String sodienthoai,
    required String diachi,
    required String ghichu,
  });
  Future<void> doiTrangThai(DonHang don, HoSoNguoiDung hoso, String trangthai);
  Future<void> xacNhanThuTien(DonHang don, HoSoNguoiDung hoso);
  Future<void> duyetQuan(String uid, String trangthai);
  Future<void> doiTrangThaiKhach(String uid, String trangthai);
  Future<void> luuHoSo(
    String uid,
    String hoten,
    String sodienthoai,
    String diachi,
  );
}
