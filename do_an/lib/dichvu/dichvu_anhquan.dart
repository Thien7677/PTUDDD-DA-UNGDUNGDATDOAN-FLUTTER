import 'dart:typed_data';
import 'dart:ui' as dohoa;
import 'package:image_picker/image_picker.dart';
import '../mohinh/anh_quan.dart';
import 'kho_taikhoan.dart';

abstract final class DichVuAnhQuan {
  static Future<AnhQuan?> chonAnh() async {
    final tep = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    if (tep == null) return null;
    if (await tep.length() > AnhQuan.kichthuoctoida) {
      throw const LoiTaiKhoan('Ảnh quán phải nhỏ hơn hoặc bằng 5 MB.');
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
      final boDoc = await dohoa.instantiateImageCodec(
        dulieu,
        targetWidth: 1200,
      );
      try {
        final khung = await boDoc.getNextFrame();
        khung.image.dispose();
      } finally {
        boDoc.dispose();
      }
    } catch (_) {
      throw const LoiTaiKhoan('Ảnh không đọc được. Vui lòng chọn ảnh khác.');
    }
    return AnhQuan(dulieu: dulieu, dinhdang: dinhdang);
  }
}
