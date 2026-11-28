import 'package:flutter/material.dart';

import '../dichvu/kiemtra_dulieu.dart';
import '../dichvu/kho_taikhoan.dart';
import '../mohinh/hoso_nguoidung.dart';
import '../mohinh/anh_quan.dart';
import '../dichvu/dichvu_anhquan.dart';
import 'thanhphan/chon_anhquan.dart';
import 'thanhphan/chude.dart';
import 'thanhphan/thanhphan_taikhoan.dart';

class TrangDangKy extends StatefulWidget {
  const TrangDangKy({
    super.key,
    required this.kho,
    required this.loaitaikhoan,
    this.hoanthienhoso = false,
    this.chonanh = DichVuAnhQuan.chonAnh,
  });
  final KhoTaiKhoan kho;
  final LoaiTaiKhoan loaitaikhoan;
  final bool hoanthienhoso;
  final Future<AnhQuan?> Function() chonanh;

  @override
  State<TrangDangKy> createState() => _TrangThaiDangKy();
}

class _TrangThaiDangKy extends State<TrangDangKy> {
  final _khoabieumau = GlobalKey<FormState>();
  final _tendangnhap = TextEditingController();
  final _email = TextEditingController();
  final _sodienthoai = TextEditingController();
  final _matkhau = TextEditingController();
  final _nhaplaimatkhau = TextEditingController();
  final _tenquan = TextEditingController();
  final _diachi = TextEditingController();
  AnhQuan? _anhquan;
  bool _danggui = false;
  String? _loi;

  bool get _laChuQuan => widget.loaitaikhoan == LoaiTaiKhoan.chuquan;

  @override
  void initState() {
    super.initState();
    if (widget.hoanthienhoso) _email.text = widget.kho.emailhientai ?? '';
  }

  @override
  void dispose() {
    for (final dieukhien in [
      _tendangnhap,
      _email,
      _sodienthoai,
      _matkhau,
      _nhaplaimatkhau,
      _tenquan,
      _diachi,
    ]) {
      dieukhien.dispose();
    }
    super.dispose();
  }

  Future<void> _dangKy() async {
    if (_danggui || !_khoabieumau.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _danggui = true;
      _loi = null;
    });
    try {
      final dulieu = DuLieuDangKy(
        tendangnhap: _tendangnhap.text,
        email: _email.text,
        sodienthoai: _sodienthoai.text,
        matkhau: _matkhau.text,
        loaitaikhoan: widget.loaitaikhoan,
        tenquan: _tenquan.text,
        diachi: _diachi.text,
        anhquan: _anhquan,
      );
      if (widget.hoanthienhoso) {
        await widget.kho.hoanThienHoSo(dulieu);
      } else {
        await widget.kho.dangKy(dulieu);
      }
      if (!mounted) return;
      Navigator.of(context).popUntil((tuyen) => tuyen.isFirst);
    } on LoiTaiKhoan catch (loi) {
      if (mounted) setState(() => _loi = loi.thongbao);
    } catch (_) {
      if (mounted) {
        setState(() => _loi = 'Chưa hoàn tất đăng ký. Vui lòng thử lại.');
      }
    } finally {
      if (mounted) setState(() => _danggui = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_danggui,
    child: KhungTaiKhoan(
      tieude: widget.hoanthienhoso
          ? 'Hoàn thiện hồ sơ'
          : (_laChuQuan ? 'Đăng ký quán ăn' : 'Đăng ký tài khoản'),
      noidung: AutofillGroup(
        child: Form(
          key: _khoabieumau,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              DauThuongHieu(
                tieude: _laChuQuan
                    ? 'Đưa quán ngon\nđến gần khách hơn.'
                    : 'Bữa ngon bắt đầu\ntừ tài khoản của bạn.',
                mota: _laChuQuan
                    ? 'Tạo tài khoản chủ quán và gửi thông tin nhà hàng để được duyệt.'
                    : 'Tạo tài khoản để đặt món. Bạn có thể thêm tên hiển thị và địa chỉ sau trong hồ sơ cá nhân.',
                bieutuong: _laChuQuan
                    ? Icons.storefront_outlined
                    : Icons.person_outline,
              ),
              const SizedBox(height: 24),
              if (_laChuQuan) ...[
                const HopThongBao(
                  noidung:
                      'Hồ sơ quán cần admin duyệt trước khi nhận đơn. Thanh toán bằng tiền mặt khi nhận hàng (COD).',
                ),
                const SizedBox(height: 20),
                const Text(
                  'Thông tin tài khoản',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
              ],
              OThongTin(
                dieukhien: _tendangnhap,
                nhan: 'Tên tài khoản',
                kiemtra: KiemTraDuLieu.tendangnhap,
                maxlength: 30,
                goiynhap: const [AutofillHints.newUsername],
              ),
              const SizedBox(height: 16),
              OThongTin(
                dieukhien: _email,
                nhan: 'Email',
                kiemtra: KiemTraDuLieu.email,
                banphim: TextInputType.emailAddress,
                chidoc: widget.hoanthienhoso,
                goiynhap: const [AutofillHints.email],
              ),
              const SizedBox(height: 16),
              OThongTin(
                dieukhien: _sodienthoai,
                nhan: 'Số điện thoại',
                kiemtra: KiemTraDuLieu.sodienthoai,
                banphim: TextInputType.phone,
                maxlength: 20,
                goiynhap: const [AutofillHints.telephoneNumber],
              ),
              if (!widget.hoanthienhoso) ...[
                const SizedBox(height: 16),
                OMatKhau(
                  dieukhien: _matkhau,
                  nhan: 'Mật khẩu',
                  kiemtra: KiemTraDuLieu.matkhau,
                  matkhaumoi: true,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 2),
                  child: Text(
                    'Dùng ít nhất 8 ký tự.',
                    style: TextStyle(color: MauSac.chuphu, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
                OMatKhau(
                  dieukhien: _nhaplaimatkhau,
                  nhan: 'Nhập lại mật khẩu',
                  matkhaumoi: true,
                  kiemtra: (giatri) =>
                      giatri != _matkhau.text || (giatri ?? '').isEmpty
                      ? 'Mật khẩu nhập lại chưa khớp.'
                      : null,
                ),
              ],
              if (_laChuQuan) ...[
                const SizedBox(height: 28),
                const Text(
                  'Thông tin quán ăn',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                OThongTin(
                  dieukhien: _tenquan,
                  nhan: 'Tên quán ăn',
                  kiemtra: KiemTraDuLieu.tenquan,
                  maxlength: 120,
                ),
                const SizedBox(height: 16),
                OThongTin(
                  dieukhien: _diachi,
                  nhan: 'Địa chỉ quán',
                  kiemtra: KiemTraDuLieu.diachi,
                  banphim: TextInputType.streetAddress,
                  sodong: 2,
                  maxlength: 300,
                ),
                const SizedBox(height: 16),
                ChonAnhQuan(
                  chonanh: widget.chonanh,
                  danggui: _danggui,
                  onThayDoi: (anh) => _anhquan = anh,
                ),
              ],
              if (_loi != null) ...[
                const SizedBox(height: 20),
                HopThongBao(noidung: _loi!, laloi: true),
              ],
              const SizedBox(height: 24),
              NutTaiKhoan(
                nhan: widget.hoanthienhoso
                    ? 'Lưu hồ sơ'
                    : (_laChuQuan ? 'Gửi đăng ký quán ăn' : 'Tạo tài khoản'),
                onNhan: _dangKy,
                dangxuly: _danggui,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _danggui ? null : () => Navigator.of(context).pop(),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> chonLoaiDangKy(
  BuildContext context,
  KhoTaiKhoan kho, {
  bool hoanthienhoso = false,
}) async {
  final loai = await showModalBottomSheet<LoaiTaiKhoan>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: MauSac.nen,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bạn muốn đăng ký gì?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chọn loại tài khoản phù hợp để bắt đầu.',
              style: TextStyle(color: MauSac.chuphu),
            ),
            const SizedBox(height: 20),
            _LuaChonDangKy(
              bieutuong: Icons.person_outline,
              tieude: 'Đăng ký tài khoản',
              mota: 'Dành cho khách đặt món, theo dõi đơn và đánh giá.',
              onNhan: () => Navigator.pop(context, LoaiTaiKhoan.khachhang),
            ),
            const SizedBox(height: 12),
            _LuaChonDangKy(
              bieutuong: Icons.storefront_outlined,
              tieude: 'Đăng ký quán ăn',
              mota:
                  'Dành cho chủ quán. Hồ sơ được admin duyệt trước khi nhận đơn.',
              onNhan: () => Navigator.pop(context, LoaiTaiKhoan.chuquan),
            ),
          ],
        ),
      ),
    ),
  );
  if (loai == null || !context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => TrangDangKy(
        kho: kho,
        loaitaikhoan: loai,
        hoanthienhoso: hoanthienhoso,
      ),
    ),
  );
}

class _LuaChonDangKy extends StatelessWidget {
  const _LuaChonDangKy({
    required this.bieutuong,
    required this.tieude,
    required this.mota,
    required this.onNhan,
  });
  final IconData bieutuong;
  final String tieude;
  final String mota;
  final VoidCallback onNhan;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onNhan,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MauSac.camnhat,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(bieutuong, color: MauSac.cam),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tieude,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mota,
                    style: const TextStyle(
                      fontSize: 12,
                      color: MauSac.chuphu,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: MauSac.cam),
          ],
        ),
      ),
    ),
  );
}
