import 'dart:ui' as dohoa;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as xulyanh;
import 'package:image_picker/image_picker.dart';
import '../mohinh/anh_quan.dart';
import 'kho_taikhoan.dart';

abstract final class DichVuAnhQuan {
  static Future<AnhQuan?> chonAnh() async {
    final tep = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (tep == null) return null;
    if (await tep.length() > AnhQuan.kichthuoctoida) {
      throw const LoiTaiKhoan('Ảnh phải nhỏ hơn hoặc bằng 5 MB.');
    }
    return docAnh(await tep.readAsBytes());
  }

  static Future<AnhQuan> docAnh(Uint8List dulieu) async {
    if (dulieu.isEmpty || dulieu.length > AnhQuan.kichthuoctoida) {
      throw const LoiTaiKhoan('Chọn ảnh có dung lượng từ 1 byte đến 5 MB.');
    }
    bool batdau(List<int> dau, [int vitri = 0]) =>
        dulieu.length >= vitri + dau.length &&
        List.generate(
          dau.length,
          (i) => dulieu[vitri + i] == dau[i],
        ).every((dung) => dung);
    final dinhdang = batdau([0xff, 0xd8, 0xff])
        ? 'jpg'
        : batdau([137, 80, 78, 71, 13, 10, 26, 10])
        ? 'png'
        : batdau([82, 73, 70, 70]) && batdau([87, 69, 66, 80], 8)
        ? 'webp'
        : null;
    if (dinhdang == null) {
      throw const LoiTaiKhoan('Chỉ nhận ảnh JPG, PNG hoặc WebP.');
    }
    try {
    final bodoc = xulyanh.findDecoderForData(dulieu);
    final thongtin = bodoc?.startDecode(dulieu);
    if (thongtin == null ||
        thongtin.width <= 0 ||
        thongtin.height <= 0 ||
        thongtin.width * thongtin.height > 24000000) {
      throw const LoiTaiKhoan(
        'Ảnh quá lớn hoặc không đọc được. Chọn ảnh tối đa 24 megapixel.',
      );
    }
      final boDoc = await dohoa.instantiateImageCodec(
        dulieu,
        targetWidth: 1200,
        allowUpscaling: false,
      );
      try {
        final khung = await boDoc.getNextFrame();
        khung.image.dispose();
      } finally {
        boDoc.dispose();
      }
    } on LoiTaiKhoan {
      rethrow;
    } catch (_) {
      throw const LoiTaiKhoan('Ảnh không đọc được. Vui lòng chọn ảnh khác.');
    }
    return AnhQuan(dulieu: dulieu, dinhdang: dinhdang);
  }

  static const kichthuocnen = 200 * 1024;
  static Future<AnhQuan> nenDeLuu(AnhQuan anh) async {
    await docAnh(anh.dulieu);
    final bytes = await compute(_nenAnh, anh.dulieu);
    return AnhQuan(dulieu: bytes, dinhdang: 'jpg');
  }
}

Uint8List _nenAnh(Uint8List bytes) {
  var hinh = xulyanh.decodeImage(bytes, frame: 0);
  if (hinh == null) throw const LoiTaiKhoan('Không đọc được ảnh đã chọn.');
  hinh = xulyanh.bakeOrientation(hinh);
  for (final canh in [960, 720, 540, 360]) {
    final lon = hinh.width > hinh.height ? hinh.width : hinh.height;
    final thu = lon <= canh
        ? hinh
        : xulyanh.copyResize(
            hinh,
            width: (hinh.width * canh / lon).round(),
            height: (hinh.height * canh / lon).round(),
          );
    for (final chatluong in [82, 65, 45]) {
      final nen = xulyanh.encodeJpg(thu, quality: chatluong);
      if (nen.length <= DichVuAnhQuan.kichthuocnen) return nen;
    }
  }
  throw const LoiTaiKhoan(
    'Ảnh chưa nén được dưới 200 KB. Vui lòng chọn ảnh khác.',
  );
}
