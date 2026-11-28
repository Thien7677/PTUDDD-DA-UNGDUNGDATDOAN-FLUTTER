import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'chude.dart';

class KhungTaiKhoan extends StatelessWidget {
  const KhungTaiKhoan({super.key, this.tieude, required this.noidung});
  final String? tieude;
  final Widget noidung;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: tieude == null ? null : AppBar(title: Text(tieude!)),
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: noidung,
          ),
        ),
      ),
    ),
  );
}

class DauThuongHieu extends StatelessWidget {
  const DauThuongHieu({
    super.key,
    required this.tieude,
    required this.mota,
    this.bieutuong = Icons.shopping_bag_outlined,
  });
  final String tieude;
  final String mota;
  final IconData bieutuong;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: MauSac.cam,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Icon(bieutuong, color: Colors.white, size: 30),
      ),
      const SizedBox(height: 18),
      const Text(
        'No Nê.',
        style: TextStyle(
          fontSize: 36,
          height: 1.1,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        tieude,
        style: const TextStyle(
          fontSize: 24,
          height: 1.3,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        mota,
        style: const TextStyle(
          color: Color(0xFF706D63),
          fontSize: 14,
          height: 1.6,
        ),
      ),
    ],
  );
}

class OThongTin extends StatelessWidget {
  const OThongTin({
    super.key,
    required this.dieukhien,
    required this.nhan,
    this.kiemtra,
    this.banphim,
    this.bieutuong,
    this.chidoc = false,
    this.goiynhap,
    this.sodong = 1,
    this.maxlength,
    this.dinhdang,
  });
  final TextEditingController dieukhien;
  final String nhan;
  final String? Function(String?)? kiemtra;
  final TextInputType? banphim;
  final IconData? bieutuong;
  final bool chidoc;
  final Iterable<String>? goiynhap;
  final int sodong;
  final int? maxlength;
  final List<TextInputFormatter>? dinhdang;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: dieukhien,
    validator: kiemtra,
    keyboardType: banphim,
    readOnly: chidoc,
    autofillHints: goiynhap,
    maxLines: sodong,
    maxLength: maxlength,
    inputFormatters: dinhdang,
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      labelText: nhan,
      prefixIcon: bieutuong == null ? null : Icon(bieutuong, size: 20),
      counterText: '',
    ),
  );
}

class OMatKhau extends StatefulWidget {
  const OMatKhau({
    super.key,
    required this.dieukhien,
    required this.nhan,
    required this.kiemtra,
    this.matkhaumoi = false,
  });
  final TextEditingController dieukhien;
  final String nhan;
  final String? Function(String?) kiemtra;
  final bool matkhaumoi;
  @override
  State<OMatKhau> createState() => _TrangThaiOMatKhau();
}

class _TrangThaiOMatKhau extends State<OMatKhau> {
  bool _anmatkhau = true;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.dieukhien,
    validator: widget.kiemtra,
    obscureText: _anmatkhau,
    enableSuggestions: false,
    autocorrect: false,
    autofillHints: [
      widget.matkhaumoi ? AutofillHints.newPassword : AutofillHints.password,
    ],
    decoration: InputDecoration(
      labelText: widget.nhan,
      suffixIcon: IconButton(
        tooltip: _anmatkhau
            ? 'Hiện ${widget.nhan.toLowerCase()}'
            : 'Ẩn ${widget.nhan.toLowerCase()}',
        onPressed: () => setState(() => _anmatkhau = !_anmatkhau),
        icon: Icon(
          _anmatkhau
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20,
        ),
      ),
    ),
  );
}

class NutTaiKhoan extends StatelessWidget {
  const NutTaiKhoan({
    super.key,
    required this.nhan,
    required this.onNhan,
    this.dangxuly = false,
    this.thucap = false,
  });
  final String nhan;
  final VoidCallback? onNhan;
  final bool dangxuly;
  final bool thucap;

  @override
  Widget build(BuildContext context) {
    final noidung = dangxuly
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Text(nhan);
    return FilledButton(
      style: thucap
          ? FilledButton.styleFrom(
              backgroundColor: MauSac.camnhat,
              foregroundColor: MauSac.cam,
            )
          : null,
      onPressed: dangxuly ? null : onNhan,
      child: noidung,
    );
  }
}

class HopThongBao extends StatelessWidget {
  const HopThongBao({
    super.key,
    required this.noidung,
    this.laloi = false,
    this.hanhdong,
  });
  final String noidung;
  final bool laloi;
  final Widget? hanhdong;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: laloi ? const Color(0xFFFCECE8) : MauSac.xanhnhat,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          noidung,
          style: TextStyle(
            color: laloi ? const Color(0xFF9F2F24) : MauSac.xanh,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        ?hanhdong,
      ],
    ),
  );
}

void hienHuongDanFirebase(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Kết nối Firebase',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 16),
          Text(
            '1. Tạo Firebase project cho nhóm.\n\n2. Bật Authentication → Email/Password.\n\n3. Tạo Cloud Firestore và triển khai file firestore.rules trong dự án.\n\n4. Đăng ký ứng dụng Android/Web, điền cấu hình vào cauhinh_firebase.json theo file mẫu.\n\n5. Chạy Flutter với --dart-define-from-file=cauhinh_firebase.json.\n\nXem HUONG_DAN_FIREBASE.md trong thư mục dự án để làm từng bước.',
          ),
        ],
      ),
    ),
  ),
);
