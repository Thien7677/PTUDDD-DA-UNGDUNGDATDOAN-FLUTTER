import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:do_an/main.dart';
import 'package:do_an/mohinh/ban_hang.dart';
import 'package:do_an/mohinh/hoso_nguoidung.dart';
import 'widget_test.dart' show KhoThuNghiem;
import 'kho_banhang_thu.dart';

KhoThuNghiem taikhoan(LoaiTaiKhoan loai) => KhoThuNghiem()
  ..dadangnhap = true
  ..hoso = HoSoNguoiDung(
    manguoidung: loai == LoaiTaiKhoan.chuquan ? 'chuquan' : 'nguoidung',
    hoten: 'Nguyễn An',
    email: 'an@example.com',
    sodienthoai: '0901234567',
    loaitaikhoan: loai,
    trangthai: 'hoatdong',
    tendangnhap: 'nguyenan',
  );
Future<void> nhan(WidgetTester t, Finder f) async {
  t.testTextInput.hide();
  await t.pump();
  if (find.byType(AlertDialog).evaluate().isEmpty) {
    await t.pumpAndSettle();
  }
  if (f.evaluate().isEmpty) {
    await t.scrollUntilVisible(
      f,
      250,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await t.ensureVisible(f);
  await t.pump(const Duration(milliseconds: 350));
  await t.tap(f);
  await t.pump();
  await t.pump(const Duration(milliseconds: 350));
  if (find.byType(AlertDialog).evaluate().isEmpty) {
    await t.pumpAndSettle();
  }
}

void main() {
  testWidgets('Khách đăng nhập vào khám phá và đặt COD, bắt buộc địa chỉ', (
    t,
  ) async {
    final kho = KhoBanHangThu();
    await t.pumpWidget(
      UngDungNoNe(kho: taikhoan(LoaiTaiKhoan.khachhang), banhang: kho),
    );
    await t.pumpAndSettle();
    expect(find.text('Hôm nay ăn gì?'), findsOneWidget);
    expect(find.text('Thực đơn'), findsNothing);
    await nhan(t, find.text('Phở Hà Nội'));
    await nhan(t, find.byTooltip('Thêm Phở bò tái'));
    await nhan(t, find.textContaining('Xem giỏ hàng ·'));
    await nhan(t, find.text('Tiếp tục đặt hàng'));
    await nhan(t, find.text('Đặt đơn · 70.000đ'));
    expect(kho.solandat, 0);
    expect(
      find.text('Nhập địa chỉ nhận hàng đầy đủ (8–300 ký tự).'),
      findsOneWidget,
    );
    await t.enterText(
      find.byType(TextFormField).at(2),
      '123 Nguyễn Huệ, Quận 1',
    );
    await nhan(t, find.text('Đặt đơn · 70.000đ'));
    expect(kho.solandat, 1);
    expect(kho.cacdon.single.tongtien, 70000);
    expect(kho.cacdon.single.trangthaithanhtoan, 'chuathanhtoan');
    expect(find.text('Theo dõi đơn hàng'), findsOneWidget);
    expect(find.text('Tôi đã nhận được hàng'), findsNothing);
    await t.pumpWidget(const SizedBox());
    await kho.dong();
  });
  testWidgets('Chủ quán thêm món và giá phải lớn hơn không', (t) async {
    final kho = KhoBanHangThu();
    await t.pumpWidget(
      UngDungNoNe(kho: taikhoan(LoaiTaiKhoan.chuquan), banhang: kho),
    );
    await t.pumpAndSettle();
    expect(find.text('Đơn hàng của quán'), findsOneWidget);
    await nhan(t, find.text('Thực đơn'));
    await nhan(t, find.text('Thêm món mới'));
    await t.enterText(find.byType(TextFormField).at(0), 'Phở bò viên');
    await t.enterText(find.byType(TextFormField).at(1), '0');
    await nhan(t, find.text('Lưu món ăn'));
    expect(kho.mondaluu, isNull);
    await t.enterText(find.byType(TextFormField).at(1), '65000');
    await nhan(t, find.text('Lưu món ăn'));
    expect(kho.mondaluu?.gia, 65000);
    expect(kho.mondaluu?.quanid, 'chuquan');
    await t.pumpWidget(const SizedBox());
    await kho.dong();
  });
  testWidgets('Admin duyệt quán, không đi vào giỏ hàng của khách', (t) async {
    final kho = KhoBanHangThu()
      ..cacquan = [
        const QuanAn(
          id: 'pending',
          tenquan: 'Quán chờ duyệt',
          diachi: '123 Nguyễn Huệ, Quận 1',
        ),
      ];
    await t.pumpWidget(
      UngDungNoNe(kho: taikhoan(LoaiTaiKhoan.quantrivien), banhang: kho),
    );
    await t.pumpAndSettle();
    expect(find.text('Quản trị quán ăn'), findsOneWidget);
    expect(find.text('Giỏ hàng'), findsNothing);
    await nhan(t, find.text('Duyệt quán ăn'));
    await nhan(t, find.text('Xác nhận'));
    expect(kho.quandaduyet, 'pending');
    await t.pumpWidget(const SizedBox());
    await kho.dong();
  });
}
