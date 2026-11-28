import 'package:flutter_test/flutter_test.dart';
import 'package:do_an/dichvu/kiemtra_dulieu.dart';
import 'package:do_an/mohinh/hoso_nguoidung.dart';

void main() {
  test('Chấp nhận email hợp lệ và loại bỏ email sai', () {
    expect(KiemTraDuLieu.email('  khach@example.com '), isNull);
    for (final email in ['', 'abc', 'abc@', 'a b@example.com']) {
      expect(KiemTraDuLieu.email(email), isNotNull);
    }
  });
  test('Số điện thoại Việt Nam và chuẩn hóa dấu cách', () {
    expect(KiemTraDuLieu.sodienthoai('090 123 4567'), isNull);
    expect(KiemTraDuLieu.sodienthoai('+84901234567'), isNull);
    expect(KiemTraDuLieu.sodienthoai('12345'), isNotNull);
    expect(KiemTraDuLieu.chuanHoaSoDienThoai('090-123-4567'), '0901234567');
  });
  test('Đăng nhập không áp lại chính sách mật khẩu mới', () {
    expect(KiemTraDuLieu.matkhau('1234567'), isNotNull);
    expect(KiemTraDuLieu.matkhauDangNhap('1234567'), isNull);
  });
  test('Hồ sơ không nhận vai trò không xác định', () {
    expect(
      () => HoSoNguoiDung.tuDuLieu('abc', {'loaitaikhoan': 'unknown'}),
      throwsFormatException,
    );
    expect(LoaiTaiKhoan.tuChuoi('chuquan'), LoaiTaiKhoan.chuquan);
  });
}
