import 'package:flutter/material.dart';
import '../dichvu/kho_taikhoan.dart';
import '../dichvu/kho_banhang.dart';
import '../dichvu/kiemtra_dulieu.dart';
import 'thanhphan/ban_hang.dart';
import '../mohinh/hoso_nguoidung.dart';
import 'thanhphan/chude.dart';
import 'thanhphan/thanhphan_taikhoan.dart';
import 'trang_dangky.dart';

class TrangTaiKhoan extends StatefulWidget {
  const TrangTaiKhoan({
    super.key,
    required this.kho,
    this.banhang,
    this.nhung = false,
  });
  final KhoTaiKhoan kho;
  final KhoBanHang? banhang;
  final bool nhung;
  @override
  State<TrangTaiKhoan> createState() => _TrangThaiTaiKhoan();
}

class _TrangThaiTaiKhoan extends State<TrangTaiKhoan> {
  bool _dangthoat = false;
  Future<void> _dangXuat() async {
    setState(() => _dangthoat = true);
    try {
      await widget.kho.dangXuat();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chưa đăng xuất được. Vui lòng thử lại.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _dangthoat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hoso = widget.kho.hoso!;
    final choduyet = hoso.trangthai == 'choduyet';
    final bikhoa = hoso.trangthai == 'bikhoa';
    final tenloai = switch (hoso.loaitaikhoan) {
      LoaiTaiKhoan.khachhang => 'Khách hàng',
      LoaiTaiKhoan.chuquan => 'Chủ quán',
      LoaiTaiKhoan.quantrivien => 'Quản trị viên',
    };
    return _khung(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          DauThuongHieu(
            tieude: bikhoa
                ? 'Tài khoản đang tạm khóa.'
                : (choduyet
                      ? 'Đã nhận hồ sơ\nquán của bạn.'
                      : 'Chào ${hoso.hoten.isEmpty ? hoso.tendangnhap : hoso.hoten}!'),
            mota: bikhoa
                ? 'Liên hệ quản trị viên để kiểm tra tình trạng tài khoản.'
                : (choduyet
                      ? 'Thông tin đã lưu trên Firebase. Admin sẽ kiểm tra hồ sơ trước khi quán được nhận đơn.'
                      : 'Bạn đã đăng nhập thành công vào No Nê.'),
            bieutuong: bikhoa
                ? Icons.lock_outline
                : (choduyet
                      ? Icons.storefront_outlined
                      : Icons.check_circle_outline),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DongHoSo(nhan: 'Tên tài khoản', giatri: hoso.tendangnhap),
                _DongHoSo(
                  nhan: 'Tên hiển thị',
                  giatri: hoso.hoten.isEmpty ? 'Chưa đặt' : hoso.hoten,
                ),
                _DongHoSo(nhan: 'Email', giatri: hoso.email),
                _DongHoSo(nhan: 'Số điện thoại', giatri: hoso.sodienthoai),
                _DongHoSo(
                  nhan: 'Địa chỉ nhận hàng',
                  giatri: hoso.diachi.isEmpty ? 'Chưa thêm' : hoso.diachi,
                ),
                _DongHoSo(nhan: 'Loại tài khoản', giatri: tenloai),
                _DongHoSo(
                  nhan: 'Trạng thái',
                  giatri: bikhoa
                      ? 'Tạm khóa'
                      : (choduyet ? 'Chờ duyệt' : 'Hoạt động'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!bikhoa && widget.banhang != null) ...[
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => SuaHoSo(kho: widget.banhang!, hoso: hoso),
                ),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Chỉnh sửa hồ sơ'),
            ),
            const SizedBox(height: 12),
          ],
          NutTaiKhoan(
            nhan: 'Đăng xuất',
            onNhan: _dangXuat,
            dangxuly: _dangthoat,
            thucap: true,
          ),
        ],
      ),
    );
  }

  Widget _khung(Widget noidung) => widget.nhung
      ? SingleChildScrollView(padding: const EdgeInsets.all(20), child: noidung)
      : KhungTaiKhoan(tieude: 'Tài khoản của bạn', noidung: noidung);
}

class SuaHoSo extends StatefulWidget {
  const SuaHoSo({super.key, required this.kho, required this.hoso});
  final KhoBanHang kho;
  final HoSoNguoiDung hoso;
  @override
  State<SuaHoSo> createState() => _TrangThaiSuaHoSo();
}

class _TrangThaiSuaHoSo extends State<SuaHoSo> {
  final _khoa = GlobalKey<FormState>();
  late final _ten = TextEditingController(text: widget.hoso.hoten);
  late final _sdt = TextEditingController(text: widget.hoso.sodienthoai);
  late final _diachi = TextEditingController(text: widget.hoso.diachi);
  @override
  void dispose() {
    _ten.dispose();
    _sdt.dispose();
    _diachi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Hồ sơ cá nhân')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Form(
              key: _khoa,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _ten,
                    validator: KiemTraDuLieu.hoten,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      labelText: 'Tên hiển thị',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _sdt,
                    validator: KiemTraDuLieu.sodienthoai,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _diachi,
                    validator: (v) => (v?.trim().isEmpty ?? true)
                        ? null
                        : KiemTraDuLieu.diachinhanhang(v),
                    maxLength: 300,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ nhận hàng',
                    ),
                  ),
                  const SizedBox(height: 20),
                  NutXuLy(
                    nhan: 'Lưu hồ sơ',
                    onNhan: () async {
                      if (!_khoa.currentState!.validate()) return;
                      await widget.kho.luuHoSo(
                        widget.hoso.manguoidung,
                        _ten.text,
                        _sdt.text,
                        _diachi.text,
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DongHoSo extends StatelessWidget {
  const _DongHoSo({required this.nhan, required this.giatri});
  final String nhan;
  final String giatri;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(nhan, style: const TextStyle(color: MauSac.chuphu, fontSize: 12)),
        const SizedBox(height: 3),
        Text(giatri, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class TrangXuLyHoSo extends StatelessWidget {
  const TrangXuLyHoSo({super.key, required this.kho});
  final KhoTaiKhoan kho;
  @override
  Widget build(BuildContext context) => KhungTaiKhoan(
    tieude: 'Hồ sơ tài khoản',
    noidung: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        if (kho.dangtaihoso) ...[
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 24),
          const Text(
            'Đang đọc hồ sơ từ Firebase…',
            textAlign: TextAlign.center,
          ),
        ] else if (kho.loihoso != null) ...[
          HopThongBao(noidung: kho.loihoso!, laloi: true),
          const SizedBox(height: 20),
          NutTaiKhoan(nhan: 'Thử tải lại', onNhan: kho.taiLaiHoSo),
        ] else ...[
          const DauThuongHieu(
            tieude: 'Hoàn thiện\nhồ sơ của bạn.',
            mota:
                'Tài khoản đăng nhập đã có, nhưng chưa lưu xong hồ sơ. Chọn loại tài khoản để bổ sung thông tin.',
          ),
          const SizedBox(height: 24),
          NutTaiKhoan(
            nhan: 'Hoàn thiện hồ sơ',
            onNhan: () => chonLoaiDangKy(context, kho, hoanthienhoso: true),
          ),
        ],
        const SizedBox(height: 16),
        TextButton(
          onPressed: () async {
            try {
              await kho.dangXuat();
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chưa đăng xuất được. Vui lòng thử lại.'),
                  ),
                );
              }
            }
          },
          child: const Text('Đăng xuất'),
        ),
      ],
    ),
  );
}
