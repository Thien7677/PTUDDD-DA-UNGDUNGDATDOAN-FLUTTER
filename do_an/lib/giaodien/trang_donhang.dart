import 'package:flutter/material.dart';
import '../dichvu/kho_banhang.dart';
import '../mohinh/ban_hang.dart';
import '../mohinh/hoso_nguoidung.dart';
import 'thanhphan/ban_hang.dart';
import 'thanhphan/chude.dart';
import 'thanhphan/congtac_nhandon.dart';

class DanhSachDon extends StatefulWidget {
  const DanhSachDon({
    super.key,
    required this.kho,
    required this.hoso,
    this.tieude = 'Đơn hàng của tôi',
  });
  final KhoBanHang kho;
  final HoSoNguoiDung hoso;
  final String tieude;
  @override
  State<DanhSachDon> createState() => _TrangThaiDanhSachDon();
}

class _TrangThaiDanhSachDon extends State<DanhSachDon> {
  late final _luong = widget.kho.theoDoiDon(widget.hoso);
  String _loc = 'tatca';
  @override
  Widget build(BuildContext context) => DuLieuTrucTiep<List<DonHang>>(
    stream: _luong,
    builder: (ds) {
      final laquan = widget.hoso.loaitaikhoan == LoaiTaiKhoan.chuquan;
      final hien = ds
          .where((d) => _loc == 'tatca' || d.trangthai == _loc)
          .toList();
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.tieude,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          if (laquan) ...[
            CongTacNhanDon(kho: widget.kho, uid: widget.hoso.manguoidung,
              duocnhan: widget.hoso.trangthai == 'hoatdong'),
            Row(
              children: [
                for (final muc in [
                  ('choxacnhan', 'Đơn mới'),
                  ('dangchuanbi', 'Đang làm'),
                  ('dagiao', 'Đã giao'),
                ])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TheTrang(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${ds.where((d) => d.trangthai == muc.$1).length}'
                                  .padLeft(2, '0'),
                              style: const TextStyle(
                                fontSize: 25,
                                color: MauSac.cam,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              muc.$2,
                              style: const TextStyle(
                                fontSize: 11,
                                color: MauSac.chuphu,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (widget.hoso.trangthai == 'choduyet')
              const TheTrang(
                child: Text(
                  'Quán đang chờ admin duyệt. Bạn có thể chuẩn bị thực đơn và thông tin quán trước khi nhận đơn.',
                ),
              ),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final muc in {'tatca': 'Tất cả', ...tentrangthai}.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(muc.value),
                      selected: _loc == muc.key,
                      onSelected: (_) => setState(() => _loc = muc.key),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (hien.isEmpty)
            const TrangRong(
              'Chưa có đơn hàng',
              'Các đơn hàng mới sẽ xuất hiện tại đây.',
              bieutuong: Icons.receipt_long_outlined,
            ),
          for (final d in hien)
            TheTrang(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          laquan ? d.madon : d.tenquan,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      NhanTrangThai(
                        d.nhantrangthai,
                        xanh: d.trangthai == 'dagiao',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    laquan ? '${d.nguoinhan} · ${d.sodienthoai}' : d.madon,
                    style: const TextStyle(color: MauSac.chuphu, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  for (final m in d.cacmon)
                    Text('${m['soluong']} × ${m['tenmon']}'),
                  const SizedBox(height: 12),
                  Text(
                    tienViet(d.tongtien),
                    style: const TextStyle(
                      color: MauSac.cam,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'COD · ${d.dathutien ? 'Quán đã xác nhận thu tiền' : 'Quán chưa xác nhận thu tiền'}',
                    style: const TextStyle(color: MauSac.chuphu, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ChiTietDon(
                          kho: widget.kho,
                          hoso: widget.hoso,
                          donid: d.id,
                        ),
                      ),
                    ),
                    child: const Text('Xem chi tiết đơn'),
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}

class ChiTietDon extends StatefulWidget {
  const ChiTietDon({
    super.key,
    required this.kho,
    required this.hoso,
    required this.donid,
  });
  final KhoBanHang kho;
  final HoSoNguoiDung hoso;
  final String donid;
  @override
  State<ChiTietDon> createState() => _TrangThaiChiTietDon();
}

class _TrangThaiChiTietDon extends State<ChiTietDon> {
  late final _luong = widget.kho.theoDoiDon(widget.hoso);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Theo dõi đơn hàng')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: DuLieuTrucTiep<List<DonHang>>(
          stream: _luong,
          builder: (ds) {
            final tim = ds.where((d) => d.id == widget.donid);
            if (tim.isEmpty) {
              return const TrangRong(
                'Chưa tìm thấy đơn',
                'Quay lại danh sách và thử tải lại.',
              );
            }
            final d = tim.first;
            final chuquan = widget.hoso.loaitaikhoan == LoaiTaiKhoan.chuquan;
            final khach = widget.hoso.loaitaikhoan == LoaiTaiKhoan.khachhang;
            final cacbuoc = ['choxacnhan', 'dangchuanbi', 'danggiao', 'dagiao'];
            final buoc = cacbuoc.indexOf(d.trangthai);
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: NhanTrangThai(
                    d.nhantrangthai,
                    xanh: d.trangthai == 'dagiao',
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  switch (d.trangthai) {
                    'choxacnhan' => 'Đơn ngon đang chờ\nquán xác nhận.',
                    'dangchuanbi' => 'Bếp đang làm\nmón ngon cho bạn.',
                    'danggiao' => 'Món ngon đang\ntrên đường đến bạn.',
                    'dagiao' => 'Bữa ngon đã đến!',
                    _ => 'Đơn hàng đã hủy.',
                  },
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                TheTrang(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${d.tenquan} · ${d.madon}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('${d.nguoinhan} · ${d.sodienthoai}'),
                      Text(d.diachi),
                      if (d.ghichu.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Ghi chú: ${d.ghichu}'),
                      ],
                    ],
                  ),
                ),
                TheTrang(
                  child: Column(
                    children: [
                      for (var i = 0; i < cacbuoc.length; i++)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            i <= buoc
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: i <= buoc ? MauSac.xanh : MauSac.chuphu,
                          ),
                          title: Text(tentrangthai[cacbuoc[i]]!),
                          subtitle: i == buoc
                              ? const Text('Trạng thái hiện tại')
                              : null,
                        ),
                    ],
                  ),
                ),
                TheTrang(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final m in d.cacmon)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('${m['soluong']} × ${m['tenmon']}'),
                              ),
                              Text(
                                tienViet(
                                  (m['gia'] as num).toInt() *
                                      (m['soluong'] as num).toInt(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Divider(),
                      _dong('Tiền món', d.tienmon),
                      _dong('Phí giao hàng', d.phigiaohang),
                      _dong('Tổng thanh toán', d.tongtien),
                      const SizedBox(height: 12),
                      Text(
                        'Tiền mặt khi nhận hàng · ${d.dathutien ? 'Đã thu tiền' : 'Chưa xác nhận thu tiền'}',
                        style: const TextStyle(color: MauSac.xanh),
                      ),
                    ],
                  ),
                ),
                if (chuquan && widget.hoso.trangthai == 'hoatdong') ...[
                  if (d.trangthai == 'choxacnhan')
                    NutXuLy(
                      nhan: 'Xác nhận nhận đơn',
                      onNhan: () => widget.kho.doiTrangThai(
                        d,
                        widget.hoso,
                        'dangchuanbi',
                      ),
                    ),
                  if (d.trangthai == 'dangchuanbi')
                    NutXuLy(
                      nhan: 'Bắt đầu giao hàng',
                      onNhan: () =>
                          widget.kho.doiTrangThai(d, widget.hoso, 'danggiao'),
                    ),
                  if (d.trangthai == 'danggiao')
                    NutXuLy(
                      nhan: 'Xác nhận đã giao hàng',
                      onNhan: () async {
                        if (await xacNhan(
                          context,
                          'Xác nhận giao hàng?',
                          'Chỉ xác nhận khi nhân viên đã giao hàng cho khách. Việc thu tiền được ghi nhận riêng.',
                        )) {
                          await widget.kho.doiTrangThai(
                            d,
                            widget.hoso,
                            'dagiao',
                          );
                        }
                      },
                    ),
                  const SizedBox(height: 10),
                  if (['danggiao', 'dagiao'].contains(d.trangthai) &&
                      !d.dathutien)
                    NutXuLy(
                      nhan: 'Xác nhận đã thu tiền COD',
                      phu: true,
                      onNhan: () async {
                        if (await xacNhan(
                          context,
                          'Đã nhận tiền mặt?',
                          'Xác nhận nhân viên đã thu đủ ${tienViet(d.tongtien)} từ khách.',
                        )) {
                          await widget.kho.xacNhanThuTien(d, widget.hoso);
                        }
                      },
                    ),
                ],
                if (khach && d.trangthai == 'danggiao')
                  NutXuLy(
                    nhan: 'Tôi đã nhận được hàng',
                    onNhan: () async {
                      if (await xacNhan(
                        context,
                        'Bạn đã nhận hàng?',
                        'Chỉ xác nhận sau khi đã nhận đủ các món của đơn.',
                      )) {
                        await widget.kho.doiTrangThai(d, widget.hoso, 'dagiao');
                      }
                    },
                  ),
                if ((khach && d.trangthai == 'choxacnhan') ||
                    (chuquan &&
                        [
                          'choxacnhan',
                          'dangchuanbi',
                        ].contains(d.trangthai))) ...[
                  const SizedBox(height: 12),
                  NutXuLy(
                    nhan: 'Hủy đơn hàng',
                    phu: true,
                    onNhan: () async {
                      if (await xacNhan(
                        context,
                        'Hủy đơn hàng?',
                        'Đơn đã hủy sẽ không thể tiếp tục giao.',
                        nut: 'Hủy đơn',
                      )) {
                        await widget.kho.doiTrangThai(d, widget.hoso, 'dahuy');
                      }
                    },
                  ),
                ],
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    ),
  );
  Widget _dong(String nhan, int so) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(nhan)),
        Text(tienViet(so), style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}
