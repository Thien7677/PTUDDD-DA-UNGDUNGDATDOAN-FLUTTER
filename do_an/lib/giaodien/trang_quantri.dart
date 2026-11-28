import 'package:flutter/material.dart';
import '../dichvu/kho_banhang.dart';
import '../mohinh/ban_hang.dart';
import '../mohinh/hoso_nguoidung.dart';
import 'thanhphan/ban_hang.dart';
import 'thanhphan/chude.dart';

class QuanTriQuan extends StatefulWidget {
  const QuanTriQuan({super.key, required this.kho});
  final KhoBanHang kho;
  @override
  State<QuanTriQuan> createState() => _TrangThaiQuanTriQuan();
}

class _TrangThaiQuanTriQuan extends State<QuanTriQuan> {
  late final _luong = widget.kho.theoDoiQuan(tatca: true);
  String _loc = 'tatca';
  @override
  Widget build(BuildContext context) => DuLieuTrucTiep<List<QuanAn>>(
    stream: _luong,
    builder: (ds) => ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Quản trị quán ăn',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Text(
          '${ds.length} quán · ${ds.where((q) => q.trangthai == 'choduyet').length} hồ sơ đang chờ duyệt',
          style: const TextStyle(color: MauSac.chuphu),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          children: [
            for (final m in {
              'tatca': 'Tất cả',
              'choduyet': 'Chờ duyệt',
              'hoatdong': 'Hoạt động',
              'bikhoa': 'Tạm khóa',
            }.entries)
              ChoiceChip(
                label: Text(m.value),
                selected: _loc == m.key,
                onSelected: (_) => setState(() => _loc = m.key),
              ),
          ],
        ),
        const SizedBox(height: 18),
        if (ds.where((q) => _loc == 'tatca' || q.trangthai == _loc).isEmpty)
          const TrangRong(
            'Chưa có hồ sơ phù hợp',
            'Hồ sơ đăng ký quán mới sẽ xuất hiện tại đây.',
          ),
        for (final q in ds.where((q) => _loc == 'tatca' || q.trangthai == _loc))
          TheTrang(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnhMon(
                  anhmau: q.anhmau,
                  duongdananh: q.duongdananh,
                  height: 150,
                  width: double.infinity,
                ),
                const SizedBox(height: 14),
                Text(
                  q.tenquan,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(q.diachi),
                Text(q.sodienthoai),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: NhanTrangThai(
                    q.trangthai == 'hoatdong'
                        ? 'Hoạt động'
                        : q.trangthai == 'choduyet'
                        ? 'Chờ duyệt'
                        : 'Tạm khóa',
                    xanh: q.trangthai == 'hoatdong',
                  ),
                ),
                const SizedBox(height: 14),
                if (q.trangthai != 'hoatdong')
                  NutXuLy(
                    nhan: q.trangthai == 'choduyet'
                        ? 'Duyệt quán ăn'
                        : 'Mở lại quán',
                    onNhan: () async {
                      if (await xacNhan(
                        context,
                        'Duyệt ${q.tenquan}?',
                        'Xác nhận đã kiểm tra ảnh, địa chỉ và thông tin liên hệ của quán.',
                      )) {
                        await widget.kho.duyetQuan(q.id, 'hoatdong');
                      }
                    },
                  ),
                if (q.trangthai != 'bikhoa')
                  NutXuLy(
                    nhan: q.trangthai == 'choduyet'
                        ? 'Tạm khóa hồ sơ'
                        : 'Tạm khóa quán',
                    phu: true,
                    onNhan: () async {
                      if (await xacNhan(
                        context,
                        'Tạm khóa quán?',
                        'Quán sẽ ngừng nhận đơn và tài khoản chủ quán sẽ bị tạm khóa.',
                      )) {
                        await widget.kho.duyetQuan(q.id, 'bikhoa');
                      }
                    },
                  ),
              ],
            ),
          ),
      ],
    ),
  );
}

class QuanTriKhach extends StatefulWidget {
  const QuanTriKhach({super.key, required this.kho, required this.uid});
  final KhoBanHang kho;
  final String uid;
  @override
  State<QuanTriKhach> createState() => _TrangThaiQuanTriKhach();
}

class _TrangThaiQuanTriKhach extends State<QuanTriKhach> {
  late final _luong = widget.kho.theoDoiNguoiDung();
  @override
  Widget build(BuildContext context) => DuLieuTrucTiep<List<HoSoNguoiDung>>(
    stream: _luong,
    builder: (ds) => ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Tài khoản khách hàng',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 18),
        for (final h in ds.where(
          (h) => h.loaitaikhoan == LoaiTaiKhoan.khachhang,
        ))
          TheTrang(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  h.hoten.isEmpty ? h.tendangnhap : h.hoten,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(h.email),
                Text(h.sodienthoai),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: NhanTrangThai(
                    h.trangthai == 'bikhoa' ? 'Tạm khóa' : 'Hoạt động',
                    xanh: h.trangthai != 'bikhoa',
                  ),
                ),
                const SizedBox(height: 12),
                if (h.manguoidung != widget.uid)
                  NutXuLy(
                    nhan: h.trangthai == 'bikhoa'
                        ? 'Mở lại tài khoản'
                        : 'Tạm khóa tài khoản',
                    phu: true,
                    onNhan: () async {
                      if (await xacNhan(
                        context,
                        'Cập nhật tài khoản?',
                        h.trangthai == 'bikhoa'
                            ? 'Cho phép khách sử dụng lại ứng dụng.'
                            : 'Khách sẽ không thể tiếp tục đặt hàng khi bị khóa.',
                      )) {
                        await widget.kho.doiTrangThaiKhach(
                          h.manguoidung,
                          h.trangthai == 'bikhoa' ? 'hoatdong' : 'bikhoa',
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
      ],
    ),
  );
}
