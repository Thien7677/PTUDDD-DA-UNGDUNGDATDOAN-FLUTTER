import 'package:flutter/material.dart';
import '../dichvu/kho_banhang.dart';
import '../dichvu/kho_taikhoan.dart';
import '../mohinh/ban_hang.dart';
import '../mohinh/hoso_nguoidung.dart';
import 'thanhphan/chude.dart';
import 'thanhphan/ban_hang.dart';
import 'trang_chuquan.dart';
import 'trang_donhang.dart';
import 'trang_khachhang.dart';
import 'trang_quantri.dart';
import 'trang_taikhoan.dart';

class TrangSauDangNhap extends StatefulWidget {
  const TrangSauDangNhap({
    super.key,
    required this.taikhoan,
    required this.banhang,
  });
  final KhoTaiKhoan taikhoan;
  final KhoBanHang banhang;
  @override
  State<TrangSauDangNhap> createState() => _TrangThaiSauDangNhap();
}

class _TrangThaiSauDangNhap extends State<TrangSauDangNhap> {
  final _gio = GioHang();
  int _tab = 0;
  @override
  void dispose() {
    _gio.dispose();
    super.dispose();
  }

  void _chon(int i) => setState(() => _tab = i);
  @override
  Widget build(BuildContext context) {
    final h = widget.taikhoan.hoso!;
    if (h.trangthai == 'bikhoa') return TrangTaiKhoan(kho: widget.taikhoan);
    final kho = widget.banhang;
    final khach = h.loaitaikhoan == LoaiTaiKhoan.khachhang;
    final chu = h.loaitaikhoan == LoaiTaiKhoan.chuquan;
    final nhan = khach
        ? ['Khám phá', 'Đơn hàng', 'Giỏ hàng', 'Tài khoản']
        : chu
        ? ['Đơn hàng', 'Thực đơn', 'Quán ăn', 'Tài khoản']
        : ['Quán ăn', 'Khách hàng', 'Đơn hàng', 'Tài khoản'];
    final icon = khach
        ? [
            Icons.home_outlined,
            Icons.receipt_long_outlined,
            Icons.shopping_bag_outlined,
            Icons.person_outline,
          ]
        : chu
        ? [
            Icons.receipt_long_outlined,
            Icons.restaurant_menu,
            Icons.storefront_outlined,
            Icons.person_outline,
          ]
        : [
            Icons.storefront_outlined,
            Icons.people_outline,
            Icons.receipt_long_outlined,
            Icons.person_outline,
          ];
    final trang = khach
        ? <Widget>[
            TrangKhamPha(
              kho: kho,
              gio: _gio,
              hoso: h,
              moGio: () => _chon(2),
              moHoSo: () => _chon(3),
            ),
            DanhSachDon(kho: kho, hoso: h),
            TrangGioHang(
              kho: kho,
              gio: _gio,
              hoso: h,
              khampha: () => _chon(0),
              xemDon: () => _chon(1),
            ),
            TrangTaiKhoan(kho: widget.taikhoan, banhang: kho, nhung: true),
          ]
        : chu
        ? <Widget>[
            DanhSachDon(kho: kho, hoso: h, tieude: 'Đơn hàng của quán'),
            QuanLyThucDon(kho: kho, uid: h.manguoidung),
            ThongTinQuan(kho: kho, hoso: h),
            TrangTaiKhoan(kho: widget.taikhoan, banhang: kho, nhung: true),
          ]
        : <Widget>[
            QuanTriQuan(kho: kho),
            QuanTriKhach(kho: kho, uid: h.manguoidung),
            DanhSachDon(kho: kho, hoso: h, tieude: 'Tất cả đơn hàng'),
            TrangTaiKhoan(kho: widget.taikhoan, banhang: kho, nhung: true),
          ];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('No Nê.', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(width: 12),
            if (!khach)
              NhanTrangThai(
                chu ? 'Dành cho quán ăn' : 'Quản trị viên',
                xanh: !chu,
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (chu && h.trangthai == 'choduyet')
            Container(
              width: double.infinity,
              color: MauSac.camnhat,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Text(
                'Chờ duyệt · Chuẩn bị thực đơn trong khi admin kiểm tra hồ sơ.',
                style: TextStyle(color: MauSac.cam, fontSize: 12),
              ),
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: IndexedStack(index: _tab, children: trang),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _gio,
        builder: (_, _) => NavigationBar(
          selectedIndex: _tab,
          backgroundColor: Colors.white,
          indicatorColor: MauSac.camnhat,
          onDestinationSelected: _chon,
          destinations: [
            for (var i = 0; i < nhan.length; i++)
              NavigationDestination(
                icon: khach && i == 2
                    ? Badge(
                        isLabelVisible: !_gio.rong,
                        label: Text('${_gio.tongsoluong}'),
                        child: Icon(icon[i]),
                      )
                    : Icon(icon[i]),
                label: nhan[i],
              ),
          ],
        ),
      ),
    );
  }
}
