import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

String tienViet(int so) =>
    '${so.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';

class QuanAn {
  const QuanAn({
    required this.id,
    required this.tenquan,
    required this.diachi,
    this.sodienthoai = '',
    this.mota = '',
    this.trangthai = 'choduyet',
    this.phigiaohang = 15000,
    this.dangmocua = true,
    this.anhmau = 'pho',
    this.duongdananh = '',
  });
  final String id,
      tenquan,
      diachi,
      sodienthoai,
      mota,
      trangthai,
      anhmau,
      duongdananh;
  final int phigiaohang;
  final bool dangmocua;
  factory QuanAn.tuDuLieu(String id, Map<String, dynamic> d) => QuanAn(
    id: id,
    tenquan: d['tenquan'] as String,
    diachi: d['diachi'] as String,
    sodienthoai: d['sodienthoai'] as String? ?? '',
    mota: d['mota'] as String? ?? '',
    trangthai: d['trangthai'] as String? ?? 'choduyet',
    phigiaohang: (d['phigiaohang'] as num?)?.toInt() ?? 15000,
    dangmocua: d['dangmocua'] as bool? ?? true,
    anhmau: d['anhmau'] as String? ?? '',
    duongdananh: d['duongdananh'] as String? ?? '',
  );
}

class MonAn {
  const MonAn({
    required this.id,
    required this.quanid,
    required this.tenmon,
    required this.gia,
    this.mota = '',
    this.nhom = 'Món chính',
    this.dangban = true,
    this.anhmau = 'pho',
    this.duongdananh = '',
  });
  final String id, quanid, tenmon, mota, nhom, anhmau, duongdananh;
  final int gia;
  final bool dangban;
  factory MonAn.tuDuLieu(String quanid, String id, Map<String, dynamic> d) =>
      MonAn(
        id: id,
        quanid: quanid,
        tenmon: d['tenmon'] as String,
        gia: (d['gia'] as num).toInt(),
        mota: d['mota'] as String? ?? '',
        nhom: d['nhom'] as String? ?? 'Món chính',
        dangban: d['dangban'] as bool? ?? true,
        anhmau: d['anhmau'] as String? ?? 'pho',
        duongdananh: d['duongdananh'] as String? ?? '',
      );
  Map<String, dynamic> get dulieu => {
    'tenmon': tenmon.trim(),
    'gia': gia,
    'mota': mota.trim(),
    'nhom': nhom,
    'dangban': dangban,
    'anhmau': anhmau,
    'duongdananh': duongdananh,
  };
}

class DongGioHang {
  const DongGioHang(this.mon, this.soluong);
  final MonAn mon;
  final int soluong;
  int get thanhtien => mon.gia * soluong;
  Map<String, dynamic> get dulieu => {
    'monid': mon.id,
    'tenmon': mon.tenmon,
    'gia': mon.gia,
    'soluong': soluong,
  };
}

class GioHang extends ChangeNotifier {
  static const sodongtoida = 4;
  QuanAn? quan;
  final Map<String, DongGioHang> _dong = {};
  List<DongGioHang> get dong => List.unmodifiable(_dong.values);
  int get tongsoluong => _dong.values.fold(0, (s, d) => s + d.soluong);
  int get tienmon => _dong.values.fold(0, (s, d) => s + d.thanhtien);
  bool get rong => _dong.isEmpty;
  void them(QuanAn q, MonAn mon) {
    if (mon.quanid != q.id || !mon.dangban) {
      throw const FormatException('Món này chưa thể thêm vào giỏ.');
    }
    if (!rong && quan?.id != q.id) {
      throw const FormatException('Một giỏ hàng chỉ thuộc một quán.');
    }
    final cu = _dong[mon.id];
    if (cu == null && _dong.length >= sodongtoida) {
      throw const FormatException('Mỗi đơn tối đa 4 món khác nhau.');
    }
    if ((cu?.soluong ?? 0) >= 20) {
      throw const FormatException('Mỗi món tối đa 20 phần.');
    }
    quan = q;
    _dong[mon.id] = DongGioHang(mon, (cu?.soluong ?? 0) + 1);
    notifyListeners();
  }

  void giam(String id) {
    final d = _dong[id];
    if (d == null) return;
    if (d.soluong == 1) {
      _dong.remove(id);
    } else {
      _dong[id] = DongGioHang(d.mon, d.soluong - 1);
    }
    if (_dong.isEmpty) quan = null;
    notifyListeners();
  }

  void xoa() {
    _dong.clear();
    quan = null;
    notifyListeners();
  }
}

const tentrangthai = {
  'choxacnhan': 'Chờ xác nhận',
  'dangchuanbi': 'Đang chuẩn bị',
  'danggiao': 'Đang giao',
  'dagiao': 'Đã giao',
  'dahuy': 'Đã hủy',
};

class DonHang {
  const DonHang({
    required this.id,
    required this.quanid,
    required this.khachid,
    required this.tenquan,
    required this.nguoinhan,
    required this.sodienthoai,
    required this.diachi,
    required this.cacmon,
    required this.tienmon,
    required this.phigiaohang,
    required this.tongtien,
    required this.trangthai,
    required this.trangthaithanhtoan,
    this.ghichu = '',
    this.ngaytao,
  });
  final String id,
      quanid,
      khachid,
      tenquan,
      nguoinhan,
      sodienthoai,
      diachi,
      ghichu,
      trangthai,
      trangthaithanhtoan;
  final List<Map<String, dynamic>> cacmon;
  final int tienmon, phigiaohang, tongtien;
  final DateTime? ngaytao;
  String get madon =>
      'NN-${id.substring(id.length > 6 ? id.length - 6 : 0).toUpperCase()}';
  String get nhantrangthai => tentrangthai[trangthai] ?? trangthai;
  bool get dathutien => trangthaithanhtoan == 'dathanhtoan';
  factory DonHang.tuDuLieu(String id, Map<String, dynamic> d) => DonHang(
    id: id,
    quanid: d['quanid'] as String,
    khachid: d['khachid'] as String,
    tenquan: d['tenquan'] as String,
    nguoinhan: d['nguoinhan'] as String,
    sodienthoai: d['sodienthoai'] as String,
    diachi: d['diachi'] as String,
    cacmon: (d['cacmon'] as List)
        .map((m) => Map<String, dynamic>.from(m as Map))
        .toList(),
    tienmon: (d['tienmon'] as num).toInt(),
    phigiaohang: (d['phigiaohang'] as num).toInt(),
    tongtien: (d['tongtien'] as num).toInt(),
    trangthai: d['trangthai'] as String,
    trangthaithanhtoan: d['trangthaithanhtoan'] as String,
    ghichu: d['ghichu'] as String? ?? '',
    ngaytao: (d['ngaytao'] as Timestamp?)?.toDate(),
  );
}
