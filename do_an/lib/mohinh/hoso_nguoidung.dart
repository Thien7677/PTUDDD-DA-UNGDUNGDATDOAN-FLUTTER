import 'anh_quan.dart';

enum LoaiTaiKhoan {
  khachhang('khachhang'),
  chuquan('chuquan'),
  quantrivien('quantrivien');

  const LoaiTaiKhoan(this.giatri);
  final String giatri;

  static LoaiTaiKhoan? tuChuoi(Object? giatri) {
    for (final loai in values) {
      if (loai.giatri == giatri) return loai;
    }
    return null;
  }
}

class HoSoNguoiDung {
  const HoSoNguoiDung({
    required this.manguoidung,
    required this.hoten,
    required this.email,
    required this.sodienthoai,
    required this.loaitaikhoan,
    required this.trangthai,
    this.tendangnhap = '',
    this.diachi = '',
  });

  final String manguoidung;
  final String hoten;
  final String email;
  final String sodienthoai;
  final LoaiTaiKhoan loaitaikhoan;
  final String trangthai;
  final String tendangnhap;
  final String diachi;

  factory HoSoNguoiDung.tuDuLieu(
    String manguoidung,
    Map<String, dynamic> dulieu,
  ) {
    final loai = LoaiTaiKhoan.tuChuoi(dulieu['loaitaikhoan']);
    if (loai == null ||
        !['hoatdong', 'choduyet', 'bikhoa'].contains(dulieu['trangthai'])) {
      throw const FormatException(
        'Hồ sơ có vai trò hoặc trạng thái không hợp lệ.',
      );
    }
    return HoSoNguoiDung(
      manguoidung: manguoidung,
      hoten: dulieu['hoten'] as String,
      email: dulieu['email'] as String,
      sodienthoai: dulieu['sodienthoai'] as String,
      loaitaikhoan: loai,
      trangthai: dulieu['trangthai'] as String,
      tendangnhap: dulieu['tendangnhap'] as String? ?? '',
      diachi: dulieu['diachi'] as String? ?? '',
    );
  }
}

class DuLieuDangKy {
  const DuLieuDangKy({
    required this.tendangnhap,
    required this.email,
    required this.sodienthoai,
    required this.matkhau,
    required this.loaitaikhoan,
    this.tenquan = '',
    this.diachi = '',
    this.mota = '',
    this.anhquan,
  });

  final String tendangnhap;
  final String email;
  final String sodienthoai;
  final String matkhau;
  final LoaiTaiKhoan loaitaikhoan;
  final String tenquan;
  final String diachi;
  final String mota;
  final AnhQuan? anhquan;
}
