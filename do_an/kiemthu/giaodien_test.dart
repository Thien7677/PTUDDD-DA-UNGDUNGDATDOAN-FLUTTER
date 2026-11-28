import 'dart:convert';
import 'dart:io';
import 'dart:ui' as dohoa;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:do_an/main.dart';
import 'package:do_an/mohinh/ban_hang.dart';
import 'package:do_an/mohinh/hoso_nguoidung.dart';
import '../test/kho_banhang_thu.dart';
import '../test/widget_test.dart' show KhoThuNghiem;

void main() {
  testWidgets('Kiểm tra giao diện mobile của khách, quán và admin', (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.runAsync(() async {
      final cfg =
          jsonDecode(
                await File('.dart_tool/package_config.json').readAsString(),
              )
              as Map<String, dynamic>;
      final f = (cfg['packages'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((p) => p['name'] == 'flutter');
      final root = Uri.parse('${f['rootUri']}/');
      for (final font in [
        ('Roboto', 'Roboto-Regular.ttf'),
        ('MaterialIcons', 'MaterialIcons-Regular.otf'),
      ]) {
        final bytes = await File.fromUri(
          root.resolve('../../bin/cache/artifacts/material_fonts/${font.$2}'),
        ).readAsBytes();
        await (FontLoader(
          font.$1,
        )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
      }
    });
    final khoa = GlobalKey();
    final cacKho = <KhoBanHangThu>[];
    Future<void> luu(String ten) async {
      await t.runAsync(() async {
        final v =
            khoa.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final h = await v.toImage(pixelRatio: 2);
        final b = await h.toByteData(format: dohoa.ImageByteFormat.png);
        await Directory('build/anh_giaodien').create(recursive: true);
        await File(
          'build/anh_giaodien/$ten.png',
        ).writeAsBytes(b!.buffer.asUint8List());
        h.dispose();
      });
    }

    for (final loai in [
      LoaiTaiKhoan.khachhang,
      LoaiTaiKhoan.chuquan,
      LoaiTaiKhoan.quantrivien,
    ]) {
      final auth = KhoThuNghiem()
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
      final db = KhoBanHangThu();
      cacKho.add(db);
      if (loai == LoaiTaiKhoan.chuquan) {
        db.cacdon.add(
          const DonHang(
            id: 'NN001',
            quanid: 'chuquan',
            khachid: 'khach',
            tenquan: 'Phở Hà Nội',
            nguoinhan: 'Khách Minh',
            sodienthoai: '0901234567',
            diachi: '45 Lê Lợi, Quận 1',
            cacmon: [
              {
                'monid': 'phobo',
                'tenmon': 'Phở bò tái',
                'gia': 55000,
                'soluong': 2,
              },
            ],
            tienmon: 110000,
            phigiaohang: 15000,
            tongtien: 125000,
            trangthai: 'choxacnhan',
            trangthaithanhtoan: 'chuathanhtoan',
          ),
        );
      }
      if (loai == LoaiTaiKhoan.quantrivien) {
        db.cacquan = [
          const QuanAn(
            id: 'pending',
            tenquan: 'Pizza Nhà Mình',
            diachi: '45 Lê Lợi, Quận 1',
            sodienthoai: '0901234567',
            anhmau: '',
          ),
        ];
      }
      await t.pumpWidget(
        RepaintBoundary(
          key: khoa,
          child: UngDungNoNe(key: ValueKey(loai), kho: auth, banhang: db),
        ),
      );
      await t.pumpAndSettle();
      await luu('trangchu_${loai.giatri}');
      if (loai == LoaiTaiKhoan.chuquan) {
        await t.tap(find.text('Thực đơn'));
        await t.pumpAndSettle();
        await luu('quan_thucdon');
      }
      expect(t.takeException(), isNull);
    }
    await t.pumpWidget(const SizedBox());
    for (final db in cacKho) {
      await db.dong();
    }
  });
}
