import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:do_an/dichvu/dichvu_anhquan.dart';
import 'package:do_an/dichvu/kiemtra_dulieu.dart';
import 'package:do_an/dichvu/kho_taikhoan.dart';
import 'package:do_an/mohinh/anh_quan.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Tên tài khoản chuẩn hóa và từ chối trống, có dấu, quá ngắn', () {
    expect(KiemTraDuLieu.chuanHoaTenDangNhap('  NguyenAn '), 'nguyenan');
    for (final ten in ['', '   ', 'abc', 'nguyễn', '123abc', 'ten tai khoan']) {
      expect(KiemTraDuLieu.tendangnhap(ten), isNotNull);
    }
    expect(KiemTraDuLieu.tendangnhap('nguyen.an_01'), isNull);
    expect(KiemTraDuLieu.matkhau('        '), isNotNull);
  });
  test('Ảnh rỗng, giả định dạng và quá 5 MB đều bị từ chối', () async {
    for (final anh in [
      Uint8List(0),
      Uint8List.fromList([1, 2, 3]),
      Uint8List(AnhQuan.kichthuoctoida + 1),
      Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 0, 0]),
    ]) {
      await expectLater(DichVuAnhQuan.docAnh(anh), throwsA(isA<LoiTaiKhoan>()));
    }
  });
  test('Ảnh PNG thật được giải mã trước khi chấp nhận', () async {
    final anh = await DichVuAnhQuan.docAnh(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAEUlEQVR4nGP4z8DwnwGMgRQAH+4D/dJQfRoAAAAASUVORK5CYII=',
      ),
    );
    expect(anh.dinhdang, 'png');
    expect(anh.loaitep, 'image/png');
  });
}
