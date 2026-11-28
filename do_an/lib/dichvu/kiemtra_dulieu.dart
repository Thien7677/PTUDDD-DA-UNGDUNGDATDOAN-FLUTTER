abstract final class KiemTraDuLieu {
  static String? hoten(String? giatri) {
    final chuoi = giatri?.trim() ?? '';
    if (chuoi.length < 2) return 'Nhập họ tên từ 2 ký tự.';
    if (chuoi.length > 100) return 'Họ tên tối đa 100 ký tự.';
    return null;
  }

  static String? email(String? giatri) {
    final chuoi = giatri?.trim() ?? '';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(chuoi) ||
        chuoi.length > 254) {
      return 'Nhập địa chỉ email hợp lệ.';
    }
    return null;
  }

  static String chuanHoaTenDangNhap(String giatri) =>
      giatri.trim().toLowerCase();

  static String? tendangnhap(String? giatri) =>
      RegExp(
        r'^[a-z][a-z0-9_.]{3,29}$',
      ).hasMatch(chuanHoaTenDangNhap(giatri ?? ''))
      ? null
      : 'Dùng 4–30 ký tự không dấu, bắt đầu bằng chữ; cho phép số, _ và dấu chấm.';

  static String chuanHoaSoDienThoai(String giatri) =>
      giatri.replaceAll(RegExp(r'[\s().-]'), '');

  static String? sodienthoai(String? giatri) {
    final chuoi = chuanHoaSoDienThoai(giatri ?? '');
    if (!RegExp(r'^(0[35789][0-9]{8}|\+84[35789][0-9]{8})$').hasMatch(chuoi)) {
      return 'Nhập số điện thoại Việt Nam hợp lệ.';
    }
    return null;
  }

  static String? matkhau(String? giatri) {
    if ((giatri ?? '').trim().isEmpty || (giatri ?? '').length < 8) {
      return 'Mật khẩu cần ít nhất 8 ký tự, không chỉ có khoảng trắng.';
    }
    return null;
  }

  static String? matkhauDangNhap(String? giatri) =>
      (giatri ?? '').isEmpty ? 'Nhập mật khẩu của bạn.' : null;

  static String? tenquan(String? giatri) {
    final chuoi = giatri?.trim() ?? '';
    return chuoi.length < 2 || chuoi.length > 120
        ? 'Tên quán cần từ 2 đến 120 ký tự.'
        : null;
  }

  static String? diachi(String? giatri) {
    final chuoi = giatri?.trim() ?? '';
    return chuoi.length < 8 || chuoi.length > 300
        ? 'Nhập địa chỉ quán đầy đủ (8–300 ký tự).'
        : null;
  }

  static String? diachinhanhang(String? giatri) => diachi(giatri) == null
      ? null
      : 'Nhập địa chỉ nhận hàng đầy đủ (8–300 ký tự).';
}
