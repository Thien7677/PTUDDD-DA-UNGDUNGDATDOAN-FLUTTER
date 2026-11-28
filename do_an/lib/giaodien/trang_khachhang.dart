import 'package:flutter/material.dart';
import '../dichvu/kiemtra_dulieu.dart';
import '../dichvu/kho_banhang.dart';
import '../mohinh/ban_hang.dart';
import '../mohinh/hoso_nguoidung.dart';
import 'thanhphan/ban_hang.dart';
import 'thanhphan/chude.dart';
import 'trang_donhang.dart';

class TrangKhamPha extends StatefulWidget {
  const TrangKhamPha({
    super.key,
    required this.kho,
    required this.gio,
    required this.hoso,
    required this.moGio,
    required this.moHoSo,
  });
  final KhoBanHang kho;
  final GioHang gio;
  final HoSoNguoiDung hoso;
  final VoidCallback moGio, moHoSo;
  @override
  State<TrangKhamPha> createState() => _TrangThaiKhamPha();
}

class _TrangThaiKhamPha extends State<TrangKhamPha> {
  late final _luong = widget.kho.theoDoiQuan();
  String _tim = '', _nhom = 'Tất cả';
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      InkWell(
        onTap: widget.moHoSo,
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: MauSac.cam),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GIAO ĐẾN',
                    style: TextStyle(fontSize: 11, color: MauSac.chuphu),
                  ),
                  Text(
                    widget.hoso.diachi.isEmpty
                        ? 'Thêm địa chỉ nhận món'
                        : widget.hoso.diachi,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
      const SizedBox(height: 22),
      const Text(
        'Hôm nay ăn gì?',
        style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800),
      ),
      const Text(
        'Một bữa ngon đang chờ bạn.',
        style: TextStyle(color: MauSac.chuphu),
      ),
      const SizedBox(height: 22),
      TextField(
        onChanged: (v) => setState(() => _tim = v.trim().toLowerCase()),
        decoration: const InputDecoration(
          hintText: 'Tìm tên nhà hàng…',
          prefixIcon: Icon(Icons.search),
        ),
      ),
      const SizedBox(height: 18),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: MauSac.xanh,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BỮA NGON MỖI NGÀY',
                    style: TextStyle(fontSize: 11, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Đúng món thích.\nĐúng lúc đói.',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Khám phá quán gần bạn →',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            AnhMon(anhmau: 'pho', width: 102, height: 144),
          ],
        ),
      ),
      const SizedBox(height: 14),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final n in ['Tất cả', 'Món Việt', 'Pizza', 'Gà rán'])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(n),
                  selected: _nhom == n,
                  onSelected: (_) => setState(() => _nhom = n),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      const Text(
        'Quán ngon dành cho bạn',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 14),
      DuLieuTrucTiep<List<QuanAn>>(
        stream: _luong,
        builder: (ds) {
          final hien = ds
              .where(
                (q) =>
                    q.tenquan.toLowerCase().contains(_tim) &&
                    (_nhom == 'Tất cả' ||
                        (_nhom == 'Pizza'
                            ? q.anhmau == 'pizza'
                            : _nhom == 'Gà rán'
                            ? q.anhmau == 'ga'
                            : !['pizza', 'ga'].contains(q.anhmau))),
              )
              .toList();
          if (hien.isEmpty) {
            return const TrangRong(
              'Chưa tìm thấy quán',
              'Thử tên khác hoặc quay lại khi có quán được duyệt.',
            );
          }
          return Column(
            children: [
              for (final q in hien)
                TheQuan(
                  quan: q,
                  onNhan: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => TrangThucDon(
                        kho: widget.kho,
                        quan: q,
                        gio: widget.gio,
                        moGio: widget.moGio,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ],
  );
}

class TrangThucDon extends StatefulWidget {
  const TrangThucDon({
    super.key,
    required this.kho,
    required this.quan,
    required this.gio,
    required this.moGio,
  });
  final KhoBanHang kho;
  final QuanAn quan;
  final GioHang gio;
  final VoidCallback moGio;
  @override
  State<TrangThucDon> createState() => _TrangThaiThucDon();
}

class _TrangThaiThucDon extends State<TrangThucDon> {
  late final _luong = widget.kho.theoDoiMon(widget.quan.id);
  String _nhom = 'Tất cả';
  Future<void> _them(MonAn mon) async {
    if (!widget.quan.dangmocua) return;
    if (!widget.gio.rong && widget.gio.quan?.id != widget.quan.id) {
      if (!await xacNhan(
        context,
        'Đổi sang quán mới?',
        'Giỏ hàng đang có món từ ${widget.gio.quan!.tenquan}. Tiếp tục sẽ xóa giỏ cũ để chọn món của ${widget.quan.tenquan}.',
        nut: 'Đổi quán và xóa giỏ cũ',
      )) {
        return;
      }
      widget.gio.xoa();
    }
    try {
      widget.gio.them(widget.quan, mon);
    } catch (loi) {
      if (mounted) baoLoi(context, loi);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.quan.tenquan)),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AnhMon(
              anhmau: widget.quan.anhmau,
              duongdananh: widget.quan.duongdananh,
              height: 200,
              width: double.infinity,
            ),
            const SizedBox(height: 18),
            Text(
              widget.quan.tenquan,
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: NhanTrangThai(
                widget.quan.dangmocua ? 'Đang mở cửa' : 'Quán tạm nghỉ',
                xanh: widget.quan.dangmocua,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.quan.diachi,
              style: const TextStyle(color: MauSac.chuphu),
            ),
            const SizedBox(height: 8),
            Text(
              'Phí giao hàng ${tienViet(widget.quan.phigiaohang)} · Thanh toán COD',
              style: const TextStyle(color: MauSac.chuphu, fontSize: 12),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              children: [
                for (final n in ['Tất cả', 'Món chính', 'Đồ uống'])
                  ChoiceChip(
                    label: Text(n),
                    selected: _nhom == n,
                    onSelected: (_) => setState(() => _nhom = n),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Món ngon của quán',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            const SizedBox(height: 14),
            DuLieuTrucTiep<List<MonAn>>(
              stream: _luong,
              builder: (ds) {
                final hien = ds
                    .where(
                      (m) =>
                          m.dangban && (_nhom == 'Tất cả' || m.nhom == _nhom),
                    )
                    .toList();
                return Column(
                  children: [
                    if (hien.isEmpty)
                      const TrangRong(
                        'Chưa có món đang bán',
                        'Quán sẽ cập nhật thực đơn sớm.',
                      ),
                    for (final m in hien)
                      TheTrang(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnhMon(anhmau: m.anhmau, width: 76, height: 94),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.tenmon,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    m.mota,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: MauSac.chuphu,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    tienViet(m.gia),
                                    style: const TextStyle(
                                      color: MauSac.cam,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton.filledTonal(
                              onPressed: widget.quan.dangmocua
                                  ? () => _them(m)
                                  : null,
                              tooltip: 'Thêm ${m.tenmon}',
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: AnimatedBuilder(
      animation: widget.gio,
      builder: (_, _) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: widget.gio.rong
                ? null
                : () {
                    widget.moGio();
                    Navigator.pop(context);
                  },
            child: Text(
              'Xem giỏ hàng · ${widget.gio.tongsoluong} phần · ${tienViet(widget.gio.tienmon)}',
            ),
          ),
        ),
      ),
    ),
  );
}

class TrangGioHang extends StatefulWidget {
  const TrangGioHang({
    super.key,
    required this.kho,
    required this.gio,
    required this.hoso,
    required this.khampha,
    required this.xemDon,
  });
  final KhoBanHang kho;
  final GioHang gio;
  final HoSoNguoiDung hoso;
  final VoidCallback khampha, xemDon;
  @override
  State<TrangGioHang> createState() => _TrangThaiGioHang();
}

class _TrangThaiGioHang extends State<TrangGioHang> {
  final _ghichu = TextEditingController();
  @override
  void dispose() {
    _ghichu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.gio,
    builder: (_, _) {
      final g = widget.gio;
      if (g.rong) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const TrangRong(
              'Bạn chưa chọn món nào',
              'Khám phá quán ngon và thêm món bạn thích vào giỏ nhé.',
              bieutuong: Icons.shopping_bag_outlined,
            ),
            FilledButton(
              onPressed: widget.khampha,
              child: const Text('Khám phá món ngon'),
            ),
          ],
        );
      }
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Giỏ hàng của bạn',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          Text(
            g.quan!.tenquan,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          const SizedBox(height: 12),
          const TheTrang(child: Text('Một giỏ hàng chỉ gồm món của một quán.')),
          for (final d in g.dong)
            TheTrang(
              child: Column(
                children: [
                  Row(
                    children: [
                      AnhMon(anhmau: d.mon.anhmau, width: 72, height: 80),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.mon.tenmon,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              tienViet(d.mon.gia),
                              style: const TextStyle(color: MauSac.cam),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => g.giam(d.mon.id),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '${d.soluong}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        onPressed: () {
                          try {
                            g.them(g.quan!, d.mon);
                          } catch (loi) {
                            baoLoi(context, loi);
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          TextField(
            controller: _ghichu,
            maxLength: 300,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Ghi chú cho nhà hàng',
              hintText: 'Ví dụ: ít cay, không hành…',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(child: Text('Tiền món')),
              Text(
                tienViet(g.tienmon),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => TrangDatHang(
                  kho: widget.kho,
                  hoso: widget.hoso,
                  gio: g,
                  ghichu: _ghichu.text,
                  onThanhCong: () {
                    _ghichu.clear();
                    widget.xemDon();
                  },
                ),
              ),
            ),
            child: const Text('Tiếp tục đặt hàng'),
          ),
          TextButton(
            onPressed: () async {
              if (await xacNhan(
                context,
                'Xóa giỏ hàng?',
                'Bạn sẽ chọn lại món từ đầu.',
              )) {
                g.xoa();
                _ghichu.clear();
              }
            },
            child: const Text('Xóa giỏ hàng'),
          ),
        ],
      );
    },
  );
}

class TrangDatHang extends StatefulWidget {
  const TrangDatHang({
    super.key,
    required this.kho,
    required this.hoso,
    required this.gio,
    required this.ghichu,
    required this.onThanhCong,
  });
  final KhoBanHang kho;
  final HoSoNguoiDung hoso;
  final GioHang gio;
  final String ghichu;
  final VoidCallback onThanhCong;
  @override
  State<TrangDatHang> createState() => _TrangThaiDatHang();
}

class _TrangThaiDatHang extends State<TrangDatHang> {
  final _khoa = GlobalKey<FormState>();
  late final _ten = TextEditingController(text: widget.hoso.hoten);
  late final _sdt = TextEditingController(text: widget.hoso.sodienthoai);
  late final _diachi = TextEditingController(text: widget.hoso.diachi);
  final _maxacnhan = DateTime.now().microsecondsSinceEpoch.toString();
  bool _danggui = false;
  String? _loi;
  @override
  void dispose() {
    _ten.dispose();
    _sdt.dispose();
    _diachi.dispose();
    super.dispose();
  }

  Future<void> _dat() async {
    if (_danggui || !_khoa.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _danggui = true;
      _loi = null;
    });
    try {
      final id = await widget.kho.datHang(
        widget.hoso,
        widget.gio,
        maxacnhan: _maxacnhan,
        nguoinhan: _ten.text,
        sodienthoai: _sdt.text,
        diachi: _diachi.text,
        ghichu: widget.ghichu,
      );
      if (!mounted) return;
      widget.gio.xoa();
      widget.onThanhCong();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) =>
              ChiTietDon(kho: widget.kho, hoso: widget.hoso, donid: id),
        ),
      );
    } catch (loi) {
      if (mounted) setState(() => _loi = thongBaoLoi(loi));
    } finally {
      if (mounted) setState(() => _danggui = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.gio;
    if (g.rong) {
      return Scaffold(
        appBar: AppBar(title: const Text('Đặt hàng')),
        body: const TrangRong('Giỏ hàng đang trống', 'Quay lại và chọn món.'),
      );
    }
    return PopScope(
      canPop: !_danggui,
      child: Scaffold(
        appBar: AppBar(title: const Text('Xác nhận đặt hàng')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Form(
                  key: _khoa,
                  child: TheTrang(
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: MauSac.cam),
                            SizedBox(width: 8),
                            Text(
                              'Thông tin nhận hàng',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _ten,
                          validator: KiemTraDuLieu.hoten,
                          maxLength: 100,
                          decoration: const InputDecoration(
                            labelText: 'Tên người nhận',
                          ),
                        ),
                        const SizedBox(height: 12),
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
                          validator: KiemTraDuLieu.diachinhanhang,
                          maxLength: 300,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Địa chỉ nhận hàng',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TheTrang(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Đơn hàng từ ${g.quan!.tenquan}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      for (final d in g.dong)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('${d.soluong} × ${d.mon.tenmon}'),
                              ),
                              Text(tienViet(d.thanhtien)),
                            ],
                          ),
                        ),
                      if (widget.ghichu.isNotEmpty)
                        Text('Ghi chú: ${widget.ghichu}'),
                    ],
                  ),
                ),
                const TheTrang(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.check_circle, color: MauSac.xanh),
                    title: Text('Tiền mặt khi nhận hàng'),
                    subtitle: Text('COD · Chưa thanh toán'),
                  ),
                ),
                TheTrang(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(child: Text('Tiền món')),
                          Text(tienViet(g.tienmon)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Expanded(child: Text('Phí giao hàng')),
                          Text(tienViet(g.quan!.phigiaohang)),
                        ],
                      ),
                      const Divider(height: 28),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Tổng thanh toán',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            tienViet(g.tienmon + g.quan!.phigiaohang),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: MauSac.cam,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_loi != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _loi!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                FilledButton(
                  onPressed: _danggui ? null : _dat,
                  child: Text(
                    _danggui
                        ? 'Đang gửi đơn…'
                        : 'Đặt đơn · ${tienViet(g.tienmon + g.quan!.phigiaohang)}',
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
