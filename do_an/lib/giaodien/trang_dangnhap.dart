import 'package:flutter/material.dart';

import '../dichvu/kiemtra_dulieu.dart';
import '../dichvu/kho_taikhoan.dart';
import 'thanhphan/chude.dart';
import 'thanhphan/thanhphan_taikhoan.dart';
import 'trang_dangky.dart';

class TrangDangNhap extends StatefulWidget {
  const TrangDangNhap({super.key, required this.kho});
  final KhoTaiKhoan kho;
  @override
  State<TrangDangNhap> createState() => _TrangThaiDangNhap();
}

class _TrangThaiDangNhap extends State<TrangDangNhap> {
  final _khoabieumau = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _matkhau = TextEditingController();
  bool _danggui = false;
  String? _loi;

  @override
  void dispose() {
    _email.dispose();
    _matkhau.dispose();
    super.dispose();
  }

  Future<void> _dangNhap() async {
    if (_danggui || !_khoabieumau.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _danggui = true;
      _loi = null;
    });
    try {
      await widget.kho.dangNhap(_email.text, _matkhau.text);
    } on LoiTaiKhoan catch (loi) {
      if (mounted) setState(() => _loi = loi.thongbao);
    } catch (_) {
      if (mounted) {
        setState(() => _loi = 'Chưa đăng nhập được. Vui lòng thử lại.');
      }
    } finally {
      if (mounted) setState(() => _danggui = false);
    }
  }

  @override
  Widget build(BuildContext context) => KhungTaiKhoan(
    noidung: AutofillGroup(
      child: Form(
        key: _khoabieumau,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const DauThuongHieu(
              tieude: 'Đăng nhập để bữa ngon\nluôn trong tầm tay.',
              mota:
                  'Lưu địa chỉ, xem đơn của bạn và đánh giá\nnhững bữa ăn đã nhận.',
            ),
            const SizedBox(height: 30),
            OThongTin(
              dieukhien: _email,
              nhan: 'Email',
              kiemtra: KiemTraDuLieu.email,
              banphim: TextInputType.emailAddress,
              goiynhap: const [AutofillHints.username, AutofillHints.email],
            ),
            const SizedBox(height: 16),
            OMatKhau(
              dieukhien: _matkhau,
              nhan: 'Mật khẩu',
              kiemtra: KiemTraDuLieu.matkhauDangNhap,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _danggui
                    ? null
                    : () => showDialog<void>(
                        context: context,
                        builder: (_) => _HopDatLaiMatKhau(
                          kho: widget.kho,
                          email: _email.text,
                        ),
                      ),
                child: const Text('Quên mật khẩu?'),
              ),
            ),
            if (_loi != null) ...[
              HopThongBao(noidung: _loi!, laloi: true),
              const SizedBox(height: 16),
            ],
            NutTaiKhoan(
              nhan: 'Đăng nhập',
              onNhan: _dangNhap,
              dangxuly: _danggui,
            ),
            const SizedBox(height: 14),
            NutTaiKhoan(
              nhan: 'Đăng ký',
              onNhan: _danggui
                  ? null
                  : () => chonLoaiDangKy(context, widget.kho),
              thucap: true,
            ),
            const SizedBox(height: 20),
            const Text(
              'Một tài khoản, nhiều bữa ngon.',
              textAlign: TextAlign.center,
              style: TextStyle(color: MauSac.chuphu, fontSize: 12),
            ),
            if (!widget.kho.sansang) ...[
              const SizedBox(height: 22),
              HopThongBao(
                noidung: widget.kho.loiketnoi ?? 'Chưa kết nối Firebase.',
                hanhdong: TextButton(
                  onPressed: () => hienHuongDanFirebase(context),
                  child: const Text('Kết nối Firebase'),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _HopDatLaiMatKhau extends StatefulWidget {
  const _HopDatLaiMatKhau({required this.kho, required this.email});
  final KhoTaiKhoan kho;
  final String email;
  @override
  State<_HopDatLaiMatKhau> createState() => _TrangThaiDatLaiMatKhau();
}

class _TrangThaiDatLaiMatKhau extends State<_HopDatLaiMatKhau> {
  final _khoa = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.email);
  bool _danggui = false;
  bool _dagui = false;
  String? _loi;
  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _gui() async {
    if (!_khoa.currentState!.validate() || _danggui) return;
    setState(() {
      _danggui = true;
      _loi = null;
    });
    try {
      await widget.kho.guiEmailDatLaiMatKhau(_email.text);
      if (mounted) setState(() => _dagui = true);
    } on LoiTaiKhoan catch (loi) {
      if (mounted) setState(() => _loi = loi.thongbao);
    } catch (_) {
      if (mounted) {
        setState(() => _loi = 'Chưa gửi được yêu cầu. Vui lòng thử lại.');
      }
    } finally {
      if (mounted) setState(() => _danggui = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_danggui,
    child: AlertDialog(
      title: const Text('Đặt lại mật khẩu'),
      content: SingleChildScrollView(
        child: Form(
          key: _khoa,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_dagui)
                const Text(
                  'Nếu email đã được đăng ký, bạn sẽ nhận hướng dẫn đặt lại mật khẩu. Kiểm tra cả thư mục thư rác.',
                )
              else ...[
                const Text('Nhập email dùng để đăng ký tài khoản.'),
                const SizedBox(height: 16),
                OThongTin(
                  dieukhien: _email,
                  nhan: 'Email',
                  kiemtra: KiemTraDuLieu.email,
                  banphim: TextInputType.emailAddress,
                ),
                if (_loi != null) ...[
                  const SizedBox(height: 12),
                  HopThongBao(noidung: _loi!, laloi: true),
                ],
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _danggui ? null : () => Navigator.pop(context),
          child: Text(_dagui ? 'Đóng' : 'Hủy'),
        ),
        if (!_dagui)
          TextButton(
            onPressed: _danggui ? null : _gui,
            child: Text(_danggui ? 'Đang gửi…' : 'Gửi hướng dẫn'),
          ),
      ],
    ),
  );
}
