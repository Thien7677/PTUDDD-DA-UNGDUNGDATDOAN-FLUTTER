import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:do_an/main.dart';
import 'package:do_an/dichvu/kho_taikhoan.dart';
import 'package:do_an/mohinh/hoso_nguoidung.dart';
import 'package:do_an/giaodien/trang_dangky.dart';
import 'package:do_an/mohinh/anh_quan.dart';
import 'dart:convert';
import 'kho_banhang_thu.dart';

AnhQuan anhMau() => AnhQuan(
  dinhdang: 'png',
  dulieu: base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAEUlEQVR4nGP4z8DwnwGMgRQAH+4D/dJQfRoAAAAASUVORK5CYII=',
  ),
);

class KhoThuNghiem extends KhoTaiKhoan {
  @override
  bool sansang = true;
  @override
  bool dangxuly = false;
  @override
  bool dangtaihoso = false;
  @override
  bool dadangnhap = false;
  @override
  bool thieuhoso = false;
  @override
  String? loiketnoi;
  @override
  String? loihoso;
  @override
  String? emailhientai;
  @override
  HoSoNguoiDung? hoso;
  DuLieuDangKy? dulieudagui;
  int solandangnhap = 0;
  String? loidangnhap;
  @override
  Future<void> dangNhap(String email, String matkhau) async {
    solandangnhap++;
    if (loidangnhap != null) throw LoiTaiKhoan(loidangnhap!);
  }

  @override
  Future<void> dangKy(DuLieuDangKy dulieu) async {
    dulieudagui = dulieu;
  }

  @override
  Future<void> hoanThienHoSo(DuLieuDangKy dulieu) async {
    dulieudagui = dulieu;
  }

  @override
  Future<void> guiEmailDatLaiMatKhau(String email) async {}
  @override
  Future<void> dangXuat() async {
    dadangnhap = false;
    hoso = null;
    notifyListeners();
  }

  @override
  void taiLaiHoSo() {}
}

Future<void> moDangKy(
  WidgetTester tester,
  KhoThuNghiem kho,
  String loai, {
  bool coanh = false,
}) async {
  if (coanh) {
    await tester.pumpWidget(
      MaterialApp(
        home: TrangDangKy(
          kho: kho,
          loaitaikhoan: LoaiTaiKhoan.chuquan,
          chonanh: () async => anhMau(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return;
  }
  await tester.pumpWidget(UngDungNoNe(kho: kho));
  await tester.ensureVisible(find.text('Đăng ký'));
  await tester.tap(find.text('Đăng ký'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(loai));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Đăng ký hiện hai loại tài khoản, không có lựa chọn admin', (
    tester,
  ) async {
    await tester.pumpWidget(UngDungNoNe(kho: KhoThuNghiem()));
    await tester.ensureVisible(find.text('Đăng ký'));
    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();
    expect(find.text('Đăng ký tài khoản'), findsOneWidget);
    expect(find.text('Đăng ký quán ăn'), findsOneWidget);
    expect(find.text('Đăng ký admin'), findsNothing);
  });
  testWidgets('Đăng nhập rỗng không gửi lên Firebase', (tester) async {
    final kho = KhoThuNghiem();
    await tester.pumpWidget(UngDungNoNe(kho: kho));
    await tester.ensureVisible(find.text('Đăng nhập'));
    await tester.tap(find.text('Đăng nhập'));
    await tester.pumpAndSettle();
    expect(kho.solandangnhap, 0);
    expect(find.text('Nhập địa chỉ email hợp lệ.'), findsOneWidget);
    expect(find.text('Nhập mật khẩu của bạn.'), findsOneWidget);
  });
  testWidgets('Lỗi tài khoản hiển thị bằng tiếng Việt', (tester) async {
    final kho = KhoThuNghiem()..loidangnhap = 'Email hoặc mật khẩu chưa đúng.';
    await tester.pumpWidget(UngDungNoNe(kho: kho));
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'khach@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '12345678');
    await tester.ensureVisible(find.text('Đăng nhập'));
    await tester.tap(find.text('Đăng nhập'));
    await tester.pumpAndSettle();
    expect(kho.solandangnhap, 1);
    expect(find.text('Email hoặc mật khẩu chưa đúng.'), findsOneWidget);
  });
  testWidgets('Khách hàng không phải nhập thông tin quán', (tester) async {
    await moDangKy(tester, KhoThuNghiem(), 'Đăng ký tài khoản');
    expect(find.widgetWithText(TextFormField, 'Tên quán ăn'), findsNothing);
    expect(find.byType(TextFormField), findsNWidgets(5));
    expect(find.widgetWithText(TextFormField, 'Họ và tên'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Địa chỉ'), findsNothing);
  });
  testWidgets('Chủ quán cần tên quán và địa chỉ trước khi đăng ký', (
    tester,
  ) async {
    final kho = KhoThuNghiem();
    await moDangKy(tester, kho, 'Đăng ký quán ăn');
    expect(find.byType(TextFormField), findsNWidgets(7));
    await tester.ensureVisible(find.text('Gửi đăng ký quán ăn'));
    await tester.tap(find.text('Gửi đăng ký quán ăn'));
    await tester.pumpAndSettle();
    expect(kho.dulieudagui, isNull);
    expect(find.text('Bạn phải thêm ảnh của quán.'), findsOneWidget);
    expect(find.text('Tên quán cần từ 2 đến 120 ký tự.'), findsOneWidget);
    expect(
      find.text('Nhập địa chỉ quán đầy đủ (8–300 ký tự).'),
      findsOneWidget,
    );
  });
  testWidgets('Mật khẩu nhập lại không khớp thì không tạo tài khoản', (
    tester,
  ) async {
    final kho = KhoThuNghiem();
    await moDangKy(tester, kho, 'Đăng ký tài khoản');
    final giatri = [
      'nguyenan',
      'an@example.com',
      '0901234567',
      '12345678',
      '87654321',
    ];
    for (var i = 0; i < giatri.length; i++) {
      await tester.enterText(find.byType(TextFormField).at(i), giatri[i]);
    }
    await tester.ensureVisible(find.text('Tạo tài khoản'));
    await tester.tap(find.text('Tạo tài khoản'));
    await tester.pumpAndSettle();
    expect(kho.dulieudagui, isNull);
    expect(find.text('Mật khẩu nhập lại chưa khớp.'), findsOneWidget);
  });
  testWidgets('Chủ quán gửi đủ thông tin và đúng loại tài khoản', (
    tester,
  ) async {
    final kho = KhoThuNghiem();
    await moDangKy(tester, kho, 'Đăng ký quán ăn', coanh: true);
    final giatri = [
      'nguyenan',
      'an@example.com',
      '0901234567',
      '12345678',
      '12345678',
      'Bếp Nhà An',
      '123 Nguyễn Huệ, Quận 1',
    ];
    for (var i = 0; i < giatri.length; i++) {
      await tester.ensureVisible(find.byType(TextFormField).at(i));
      await tester.enterText(find.byType(TextFormField).at(i), giatri[i]);
    }
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Gửi đăng ký quán ăn'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gửi đăng ký quán ăn'));
    await tester.pumpAndSettle();
    expect(kho.dulieudagui, isNull);
    expect(find.text('Bạn phải thêm ảnh của quán.'), findsOneWidget);
    await tester.ensureVisible(find.text('Chọn ảnh quán'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chọn ảnh quán'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Gửi đăng ký quán ăn'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gửi đăng ký quán ăn'));
    await tester.pumpAndSettle();
    expect(kho.dulieudagui?.loaitaikhoan, LoaiTaiKhoan.chuquan);
    expect(kho.dulieudagui?.diachi, '123 Nguyễn Huệ, Quận 1');
    expect(kho.dulieudagui?.anhquan, isNotNull);
    expect(kho.dulieudagui?.tendangnhap, 'nguyenan');
  });
  testWidgets(
    'Khôi phục phiên chủ quán hiển thị chờ duyệt, không mở giao diện khách',
    (tester) async {
      final kho = KhoThuNghiem()
        ..dadangnhap = true
        ..hoso = const HoSoNguoiDung(
          manguoidung: 'uid',
          hoten: 'Chủ quán',
          email: 'chuquan@example.com',
          sodienthoai: '0901234567',
          loaitaikhoan: LoaiTaiKhoan.chuquan,
          trangthai: 'choduyet',
        );
      await tester.pumpWidget(UngDungNoNe(kho: kho, banhang: KhoBanHangThu()));
      await tester.pumpAndSettle();
      expect(find.textContaining('Chờ duyệt ·'), findsOneWidget);
      expect(find.text('Đăng nhập'), findsNothing);
      await tester.tap(find.text('Tài khoản'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Đăng xuất'));
      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();
      expect(find.text('Đăng nhập'), findsOneWidget);
    },
  );
  testWidgets('Màn hình đăng nhập không tràn trên điện thoại nhỏ', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(UngDungNoNe(kho: KhoThuNghiem()..sansang = false));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Đăng ký'));
    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
