import 'package:flutter_test/flutter_test.dart';
import 'package:do_an/mohinh/ban_hang.dart';
import 'kho_banhang_thu.dart';

void main() {
  test('Đổi quán không tự xóa giỏ cũ', () {
    final gio = GioHang();
    gio.them(quanThu, monThu);
    expect(
      () => gio.them(
        const QuanAn(id: 'quan2', tenquan: 'Quán 2', diachi: 'Địa chỉ quán 2'),
        const MonAn(id: 'm2', quanid: 'quan2', tenmon: 'Món 2', gia: 50000),
      ),
      throwsFormatException,
    );
    expect(gio.quan?.id, 'chuquan');
    expect(gio.tienmon, 55000);
  });
  test('Giỏ giới hạn 4 món khác nhau và 20 phần mỗi món', () {
    final gio = GioHang();
    for (var i = 0; i < 4; i++) {
      gio.them(
        quanThu,
        MonAn(id: 'mon$i', quanid: quanThu.id, tenmon: 'Món $i', gia: 10000),
      );
    }
    expect(
      () => gio.them(
        quanThu,
        const MonAn(id: 'mon6', quanid: 'chuquan', tenmon: 'Món 6', gia: 10000),
      ),
      throwsFormatException,
    );
    for (var i = 1; i < 20; i++) {
      gio.them(quanThu, gio.dong.first.mon);
    }
    expect(() => gio.them(quanThu, gio.dong.first.mon), throwsFormatException);
    gio.xoa();
    expect(gio.quan, isNull);
    expect(gio.rong, isTrue);
  });
}
