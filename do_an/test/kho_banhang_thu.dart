import 'dart:async';
import 'package:do_an/dichvu/kho_banhang.dart';
import 'package:do_an/mohinh/ban_hang.dart';
import 'package:do_an/mohinh/hoso_nguoidung.dart';
import 'package:do_an/mohinh/anh_quan.dart';

const quanThu = QuanAn(
  id: 'chuquan',
  tenquan: 'Phở Hà Nội',
  diachi: '123 Nguyễn Huệ, Quận 1',
  sodienthoai: '0901234567',
  trangthai: 'hoatdong',
  anhmau: '',
);
const monThu = MonAn(
  id: 'phobo',
  quanid: 'chuquan',
  tenmon: 'Phở bò tái',
  gia: 55000,
  mota: 'Thịt bò mềm',
  anhmau: '',
);

class KhoBanHangThu implements KhoBanHang {
  List<QuanAn> cacquan = [quanThu];
  List<MonAn> cacmon = [monThu];
  final List<DonHang> cacdon = [];
  final _don = StreamController<List<DonHang>>.broadcast();
  final _quan = StreamController<QuanAn>.broadcast();
  int solandat = 0;
  MonAn? mondaluu;
  String? quandaduyet;
  @override
  Stream<List<QuanAn>> theoDoiQuan({bool tatca = false}) =>
      Stream.value(cacquan);
  @override
  Stream<QuanAn?> theoDoiQuanCuaToi(String uid) async* {
    yield cacquan.first;
    yield* _quan.stream;
  }
  @override
  Stream<List<MonAn>> theoDoiMon(String quanid) =>
      Stream.value(cacmon.where((m) => m.quanid == quanid).toList());
  @override
  Stream<List<DonHang>> theoDoiDon(HoSoNguoiDung hoso) async* {
    yield List.of(cacdon);
    yield* _don.stream;
  }

  @override
  Stream<List<HoSoNguoiDung>> theoDoiNguoiDung() => Stream.value([]);
  @override
  Future<void> luuMon(MonAn mon, {AnhQuan? anh}) async {
    mondaluu = mon;
  }

  @override
  Future<void> anMon(MonAn mon) async {}
  @override
  Future<void> luuQuan(
    String uid,
    Map<String, dynamic> dulieu, {
    AnhQuan? anh,
  }) async {
    final q = cacquan.first;
    final moi = QuanAn.tuDuLieu(q.id, {
      'tenquan': q.tenquan, 'diachi': q.diachi, 'sodienthoai': q.sodienthoai,
      'mota': q.mota, 'trangthai': q.trangthai, 'phigiaohang': q.phigiaohang,
      'dangmocua': q.dangmocua, 'anhmau': q.anhmau, 'duongdananh': q.duongdananh,
      ...dulieu,
    });
    cacquan = [moi, ...cacquan.skip(1)];
    _quan.add(moi);
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
    solandat++;
    cacdon.add(
      DonHang(
        id: 'donmoi',
        quanid: gio.quan!.id,
        khachid: hoso.manguoidung,
        tenquan: gio.quan!.tenquan,
        nguoinhan: nguoinhan,
        sodienthoai: sodienthoai,
        diachi: diachi,
        cacmon: gio.dong.map((d) => d.dulieu).toList(),
        tienmon: gio.tienmon,
        phigiaohang: gio.quan!.phigiaohang,
        tongtien: gio.tienmon + gio.quan!.phigiaohang,
        trangthai: 'choxacnhan',
        trangthaithanhtoan: 'chuathanhtoan',
        ghichu: ghichu,
      ),
    );
    _don.add(List.of(cacdon));
    return 'donmoi';
  }

  @override
  Future<void> doiTrangThai(
    DonHang don,
    HoSoNguoiDung hoso,
    String trangthai,
  ) async {}
  @override
  Future<void> xacNhanThuTien(DonHang don, HoSoNguoiDung hoso) async {}
  @override
  Future<void> duyetQuan(String uid, String trangthai) async {
    quandaduyet = uid;
  }

  @override
  Future<void> doiTrangThaiKhach(String uid, String trangthai) async {}
  @override
  Future<void> luuHoSo(
    String uid,
    String hoten,
    String sodienthoai,
    String diachi,
  ) async {}
  Future<void> dong() async { await _don.close(); await _quan.close(); }
}
