import 'dart:typed_data';

/// Chỉ tạo sau khi đã kiểm tra kích thước, định dạng và giải mã ảnh.
class AnhQuan {
  const AnhQuan({required this.dulieu, required this.dinhdang});
  static const kichthuoctoida = 5 * 1024 * 1024;
  final Uint8List dulieu;
  final String dinhdang;
  String get loaitep => dinhdang == 'jpg' ? 'image/jpeg' : 'image/$dinhdang';
}
