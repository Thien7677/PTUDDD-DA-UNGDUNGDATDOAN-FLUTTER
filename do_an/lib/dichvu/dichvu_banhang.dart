import 'package:cloud_firestore/cloud_firestore.dart';
import '../mohinh/ban_hang.dart';
import '../mohinh/hoso_nguoidung.dart';
import 'kiemtra_dulieu.dart';
import 'kho_banhang.dart';
import 'kho_taikhoan.dart';
import '../mohinh/anh_quan.dart';
import 'dichvu_anh_firestore.dart';

class DichVuBanHang implements KhoBanHang {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  @override
  Stream<List<QuanAn>> theoDoiQuan({bool tatca = false}) {
    Query<Map<String, dynamic>> q = _db.collection('quanan');
    if (!tatca) q = q.where('trangthai', isEqualTo: 'hoatdong');
    return q.snapshots().map(
      (s) => s.docs.map((d) => QuanAn.tuDuLieu(d.id, d.data())).toList(),
    );
  }

  @override
  Stream<QuanAn?> theoDoiQuanCuaToi(String uid) => _db
      .collection('quanan')
      .doc(uid)
      .snapshots()
      .map((d) => d.exists ? QuanAn.tuDuLieu(d.id, d.data()!) : null);
  @override
  Stream<List<MonAn>> theoDoiMon(String quanid) => _db
      .collection('quanan')
      .doc(quanid)
      .collection('monan')
      .snapshots()
      .map(
        (s) =>
            s.docs.map((d) => MonAn.tuDuLieu(quanid, d.id, d.data())).toList()
              ..sort((a, b) => a.tenmon.compareTo(b.tenmon)),
      );
  @override
  Stream<List<DonHang>> theoDoiDon(HoSoNguoiDung hoso) {
    Query<Map<String, dynamic>> q = _db.collection('donhang');
    if (hoso.loaitaikhoan == LoaiTaiKhoan.chuquan) {
      q = q.where('quanid', isEqualTo: hoso.manguoidung);
    }
    if (hoso.loaitaikhoan == LoaiTaiKhoan.khachhang) {
      q = q.where('khachid', isEqualTo: hoso.manguoidung);
    }
    return q.snapshots().map(
      (s) => s.docs.map((d) => DonHang.tuDuLieu(d.id, d.data())).toList()
        ..sort(
          (a, b) => (b.ngaytao ?? DateTime(2000)).compareTo(
            a.ngaytao ?? DateTime(2000),
          ),
        ),
    );
  }

  @override
  Stream<List<HoSoNguoiDung>> theoDoiNguoiDung() => _db
      .collection('nguoidung')
      .snapshots()
      .map(
        (s) =>
            s.docs.map((d) => HoSoNguoiDung.tuDuLieu(d.id, d.data())).toList(),
      );
  @override
  Future<void> luuMon(MonAn mon, {AnhQuan? anh}) async {
    final q = _db.collection('quanan').doc(mon.quanid).collection('monan');
    final d = mon.id.isEmpty ? q.doc() : q.doc(mon.id);
    final ghinhom = _db.batch();
    final dulieu = {...mon.dulieu, 'ngaycapnhat': FieldValue.serverTimestamp()};
    if (anh != null) {
      final vitri = DichVuAnhFirestore.anhMon(mon.quanid, d.id);
      ghinhom.set(_db.doc(vitri), await DichVuAnhFirestore.duLieu(anh));
      dulieu['duongdananh'] = vitri;
    }
    ghinhom.set(d, dulieu);
    await ghinhom.commit();
  }

  @override
  Future<void> anMon(MonAn mon) => _db
      .collection('quanan')
      .doc(mon.quanid)
      .collection('monan')
      .doc(mon.id)
      .update({'dangban': false, 'ngaycapnhat': FieldValue.serverTimestamp()});
  @override
  Future<void> luuQuan(
    String uid,
    Map<String, dynamic> dulieu, {
    AnhQuan? anh,
  }) async {
    final ghinhom = _db.batch();
    final thongtin = Map<String, dynamic>.of(dulieu);
    if (anh != null) {
      final vitri = DichVuAnhFirestore.anhQuan(uid);
      ghinhom.set(_db.doc(vitri), await DichVuAnhFirestore.duLieu(anh));
      thongtin['duongdananh'] = vitri;
    }
    ghinhom.update(_db.collection('quanan').doc(uid), thongtin);
    await ghinhom.commit();
  }

  @override
  Future<String> datHang(
    HoSoNguoiDung hoso,
    GioHang gio, {
    required String maxacnhan,
    required String nguoinhan,
    required String sodienthoai,
    required String diachi,
    required String ghichu,
  }) async {
    if (gio.rong || gio.quan == null) {
      throw const LoiTaiKhoan('Giỏ hàng đang trống.');
    }
    if (KiemTraDuLieu.hoten(nguoinhan) != null ||
        KiemTraDuLieu.sodienthoai(sodienthoai) != null ||
        KiemTraDuLieu.diachi(diachi) != null) {
      throw const LoiTaiKhoan('Kiểm tra thông tin người nhận.');
    }
    // Giữ cùng ID khi bấm lại để tránh tạo hai đơn nếu phản hồi mạng bị mất.
    final ref = _db.collection('donhang').doc('${hoso.manguoidung}_$maxacnhan');
    final quan = gio.quan!;
    final dong = List<DongGioHang>.of(gio.dong);
    await _db.runTransaction((gd) async {
      final dacodon = await gd.get(ref);
      if (dacodon.exists) return;
      final q = await gd.get(_db.collection('quanan').doc(quan.id));
      if (!q.exists ||
          q.data()!['trangthai'] != 'hoatdong' ||
          q.data()!['dangmocua'] == false) {
        throw const LoiTaiKhoan('Quán hiện chưa nhận đơn.');
      }
      final phihientai = (q.data()!['phigiaohang'] as num?)?.toInt() ?? 15000;
      if (phihientai != quan.phigiaohang) {
        throw const LoiTaiKhoan(
          'Phí giao hàng đã thay đổi. Mở lại quán để cập nhật giỏ.',
        );
      }
      for (final d in dong) {
        final m = await gd.get(
          _db
              .collection('quanan')
              .doc(quan.id)
              .collection('monan')
              .doc(d.mon.id),
        );
        if (!m.exists ||
            m.data()!['dangban'] != true ||
            m.data()!['gia'] != d.mon.gia ||
            m.data()!['tenmon'] != d.mon.tenmon) {
          throw const LoiTaiKhoan(
            'Món hoặc giá đã thay đổi. Xóa giỏ và chọn lại món để kiểm tra giá mới.',
          );
        }
      }
      gd.set(ref, {
        'quanid': quan.id,
        'khachid': hoso.manguoidung,
        'tenquan': q.data()!['tenquan'],
        'nguoinhan': nguoinhan.trim(),
        'sodienthoai': KiemTraDuLieu.chuanHoaSoDienThoai(sodienthoai),
        'diachi': diachi.trim(),
        'ghichu': ghichu.trim(),
        'cacmon': dong.map((d) => d.dulieu).toList(),
        'mamon': dong.map((d) => d.mon.id).toList(),
        'tienmon': dong.fold<int>(0, (s, d) => s + d.thanhtien),
        'phigiaohang': phihientai,
        'tongtien': dong.fold<int>(0, (s, d) => s + d.thanhtien) + phihientai,
        'trangthai': 'choxacnhan',
        'thanhtoan': 'cod',
        'trangthaithanhtoan': 'chuathanhtoan',
        'ngaytao': FieldValue.serverTimestamp(),
        'ngaycapnhat': FieldValue.serverTimestamp(),
        'capnhatboi': hoso.manguoidung,
      });
    });
    return ref.id;
  }

  @override
  Future<void> doiTrangThai(
    DonHang don,
    HoSoNguoiDung hoso,
    String trangthai,
  ) => _db.collection('donhang').doc(don.id).update({
    'trangthai': trangthai,
    'capnhatboi': hoso.manguoidung,
    'ngaycapnhat': FieldValue.serverTimestamp(),
  });
  @override
  Future<void> xacNhanThuTien(DonHang don, HoSoNguoiDung hoso) =>
      _db.collection('donhang').doc(don.id).update({
        'trangthaithanhtoan': 'dathanhtoan',
        'capnhatboi': hoso.manguoidung,
        'ngaycapnhat': FieldValue.serverTimestamp(),
      });
  @override
  Future<void> duyetQuan(String uid, String trangthai) async {
    final gd = _db.batch();
    gd.update(_db.collection('quanan').doc(uid), {'trangthai': trangthai});
    gd.update(_db.collection('nguoidung').doc(uid), {'trangthai': trangthai});
    await gd.commit();
  }

  @override
  Future<void> doiTrangThaiKhach(String uid, String trangthai) =>
      _db.collection('nguoidung').doc(uid).update({'trangthai': trangthai});
  @override
  Future<void> luuHoSo(
    String uid,
    String hoten,
    String sodienthoai,
    String diachi,
  ) => _db.collection('nguoidung').doc(uid).update({
    'hoten': hoten.trim(),
    'sodienthoai': KiemTraDuLieu.chuanHoaSoDienThoai(sodienthoai),
    'diachi': diachi.trim(),
  });
}
