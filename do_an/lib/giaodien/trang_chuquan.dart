import 'package:flutter/material.dart';
import '../dichvu/kiemtra_dulieu.dart';
import '../dichvu/kho_banhang.dart';
import '../mohinh/ban_hang.dart';
import '../mohinh/hoso_nguoidung.dart';
import 'thanhphan/ban_hang.dart';
import 'thanhphan/chude.dart';
import '../mohinh/anh_quan.dart';
import 'thanhphan/chon_anh_banhang.dart';

class QuanLyThucDon extends StatefulWidget {
  const QuanLyThucDon({super.key, required this.kho, required this.uid});
  final KhoBanHang kho;
  final String uid;
  @override
  State<QuanLyThucDon> createState() => _TrangThaiQuanLyThucDon();
}

class _TrangThaiQuanLyThucDon extends State<QuanLyThucDon> {
  late final _luong = widget.kho.theoDoiMon(widget.uid);
  String _tim = '';
  void _sua([MonAn? mon]) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => SuaMonAn(kho: widget.kho, uid: widget.uid, mon: mon),
    ),
  );
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Text(
        'Thực đơn của quán',
        style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      const Text(
        'Thêm món ngon, cập nhật giá và trạng thái bán.',
        style: TextStyle(color: MauSac.chuphu),
      ),
      const SizedBox(height: 18),
      FilledButton.icon(
        onPressed: () => _sua(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm món mới'),
      ),
      const SizedBox(height: 18),
      TextField(
        onChanged: (v) => setState(() => _tim = v.trim().toLowerCase()),
        decoration: const InputDecoration(
          hintText: 'Tìm món trong thực đơn…',
          prefixIcon: Icon(Icons.search),
        ),
      ),
      const SizedBox(height: 20),
      DuLieuTrucTiep<List<MonAn>>(
        stream: _luong,
        builder: (ds) {
          final hien = ds
              .where((m) => m.tenmon.toLowerCase().contains(_tim))
              .toList();
          return Column(
            children: [
              if (hien.isEmpty)
                const TrangRong(
                  'Chưa có món phù hợp',
                  'Thêm món mới để chuẩn bị mở bán.',
                ),
              for (final m in hien)
                TheTrang(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AnhMon(
                            anhmau: m.anhmau,
                            duongdananh: m.duongdananh,
                            width: 76,
                            height: 92,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.tenmon,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  tienViet(m.gia),
                                  style: const TextStyle(
                                    color: MauSac.cam,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                NhanTrangThai(
                                  m.dangban ? 'Đang bán' : 'Tạm ẩn',
                                  xanh: m.dangban,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _sua(m),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Chỉnh sửa'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: NutXuLy(
                              nhan: m.dangban ? 'Tạm ngưng bán' : 'Mở bán lại',
                              phu: true,
                              onNhan: () => widget.kho.luuMon(
                                MonAn(
                                  id: m.id,
                                  quanid: m.quanid,
                                  tenmon: m.tenmon,
                                  gia: m.gia,
                                  mota: m.mota,
                                  nhom: m.nhom,
                                  anhmau: m.anhmau,
                                  duongdananh: m.duongdananh,
                                  dangban: !m.dangban,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    ],
  );
}

class SuaMonAn extends StatefulWidget {
  const SuaMonAn({super.key, required this.kho, required this.uid, this.mon});
  final KhoBanHang kho;
  final String uid;
  final MonAn? mon;
  @override
  State<SuaMonAn> createState() => _TrangThaiSuaMon();
}

class _TrangThaiSuaMon extends State<SuaMonAn> {
  final _khoa = GlobalKey<FormState>();
  late final _ten = TextEditingController(text: widget.mon?.tenmon);
  late final _gia = TextEditingController(text: widget.mon?.gia.toString());
  late final _mota = TextEditingController(text: widget.mon?.mota);
  late String _nhom = widget.mon?.nhom ?? 'Món chính';
  late final String _anh = widget.mon?.anhmau ?? '';
  AnhQuan? _anhMoi;
  bool _dangluu = false;
  late bool _dangban = widget.mon?.dangban ?? true;
  @override
  void dispose() {
    _ten.dispose();
    _gia.dispose();
    _mota.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.mon == null ? 'Thêm món mới' : 'Chỉnh sửa món'),
    ),
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
                  ChonAnhBanHang(
                    nhan: 'Ảnh món ăn',
                    anhmau: _anh,
                    duongdananh: widget.mon?.duongdananh ?? '',
                    danggui: _dangluu,
                    onThayDoi: (anh) => _anhMoi = anh,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _ten,
                    maxLength: 120,
                    decoration: const InputDecoration(labelText: 'Tên món *'),
                    validator: (v) => (v?.trim().length ?? 0) < 2
                        ? 'Nhập tên món từ 2 ký tự.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _gia,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Giá bán (đồng) *',
                      hintText: 'Ví dụ: 55000',
                    ),
                    validator: (v) {
                      final so = int.tryParse(v?.trim() ?? '');
                      return so == null || so <= 0 || so > 10000000
                          ? 'Nhập giá từ 1 đến 10.000.000 đồng.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _mota,
                    maxLength: 500,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Mô tả món'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _nhom,
                    decoration: const InputDecoration(labelText: 'Nhóm món'),
                    items: ['Món chính', 'Đồ uống']
                        .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                        .toList(),
                    onChanged: (v) => setState(() => _nhom = v!),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Đang bán'),
                    subtitle: const Text(
                      'Tắt để tạm ẩn món khỏi thực đơn của khách.',
                    ),
                    value: _dangban,
                    onChanged: (v) => setState(() => _dangban = v),
                  ),
                  const SizedBox(height: 16),
                  NutXuLy(
                    nhan: 'Lưu món ăn',
                    onNhan: () async {
                      if (!_khoa.currentState!.validate()) return;
                      setState(() => _dangluu = true);
                      try {
                        await widget.kho.luuMon(
                          MonAn(
                            id: widget.mon?.id ?? '',
                            quanid: widget.uid,
                            tenmon: _ten.text,
                            gia: int.parse(_gia.text.trim()),
                            mota: _mota.text,
                            nhom: _nhom,
                            anhmau: _anh,
                            duongdananh: widget.mon?.duongdananh ?? '',
                            dangban: _dangban,
                          ),
                          anh: _anhMoi,
                        );
                        if (context.mounted) Navigator.pop(context);
                      } finally {
                        if (mounted) setState(() => _dangluu = false);
                      }
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

class ThongTinQuan extends StatefulWidget {
  const ThongTinQuan({super.key, required this.kho, required this.hoso});
  final KhoBanHang kho;
  final HoSoNguoiDung hoso;
  @override
  State<ThongTinQuan> createState() => _TrangThaiThongTinQuan();
}

class _TrangThaiThongTinQuan extends State<ThongTinQuan> {
  late final _luong = widget.kho.theoDoiQuanCuaToi(widget.hoso.manguoidung);
  @override
  Widget build(BuildContext context) => StreamBuilder<QuanAn?>(
    stream: _luong,
    builder: (context, s) {
      if (s.hasError) {
        return TrangRong('Chưa đọc được hồ sơ quán', thongBaoLoi(s.error!));
      }
      if (s.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      final q = s.data;
      if (q == null) {
        return const TrangRong(
          'Chưa có hồ sơ quán',
          'Liên hệ admin để kiểm tra thông tin đăng ký.',
        );
      }
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AnhMon(
            anhmau: q.anhmau,
            duongdananh: q.duongdananh,
            height: 200,
            width: double.infinity,
          ),
          const SizedBox(height: 20),
          Text(
            q.tenquan,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: NhanTrangThai(
              q.trangthai == 'hoatdong' ? 'Đã được duyệt' : 'Chờ duyệt',
              xanh: q.trangthai == 'hoatdong',
            ),
          ),
          const SizedBox(height: 20),
          TheTrang(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q.diachi),
                const SizedBox(height: 10),
                Text(q.sodienthoai),
                const SizedBox(height: 10),
                Text(q.mota),
                const SizedBox(height: 10),
                Text('Phí giao hàng: ${tienViet(q.phigiaohang)}'),
                const SizedBox(height: 10),
                Text(
                  q.dangmocua ? 'Đang mở cửa' : 'Đang tạm nghỉ',
                  style: const TextStyle(color: MauSac.xanh),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => SuaThongTinQuan(kho: widget.kho, quan: q),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Chỉnh sửa thông tin quán'),
          ),
        ],
      );
    },
  );
}

class SuaThongTinQuan extends StatefulWidget {
  const SuaThongTinQuan({super.key, required this.kho, required this.quan});
  final KhoBanHang kho;
  final QuanAn quan;
  @override
  State<SuaThongTinQuan> createState() => _TrangThaiSuaQuan();
}

class _TrangThaiSuaQuan extends State<SuaThongTinQuan> {
  AnhQuan? _anhMoi;
  bool _dangluu = false;
  final _khoa = GlobalKey<FormState>();
  late final _ten = TextEditingController(text: widget.quan.tenquan);
  late final _diachi = TextEditingController(text: widget.quan.diachi);
  late final _sdt = TextEditingController(text: widget.quan.sodienthoai);
  late final _mota = TextEditingController(text: widget.quan.mota);
  late final _phi = TextEditingController(
    text: widget.quan.phigiaohang.toString(),
  );
  late bool _mo = widget.quan.dangmocua;
  @override
  void dispose() {
    for (final d in [_ten, _diachi, _sdt, _mota, _phi]) {
      d.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Thông tin quán ăn')),
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
                  ChonAnhBanHang(
                    nhan: 'Ảnh quán ăn',
                    anhmau: widget.quan.anhmau,
                    duongdananh: widget.quan.duongdananh,
                    danggui: _dangluu,
                    onThayDoi: (anh) => _anhMoi = anh,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _ten,
                    validator: KiemTraDuLieu.tenquan,
                    maxLength: 120,
                    decoration: const InputDecoration(labelText: 'Tên quán'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _diachi,
                    validator: KiemTraDuLieu.diachi,
                    maxLines: 2,
                    maxLength: 300,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ quán',
                    ),
                  ),
                  const SizedBox(height: 14),
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
                    controller: _mota,
                    maxLength: 500,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Giới thiệu quán',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phi,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Phí giao hàng (đồng)',
                    ),
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      return n == null || n < 0 || n > 200000
                          ? 'Nhập phí từ 0 đến 200.000 đồng.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mở cửa nhận đơn'),
                    value: _mo,
                    onChanged: (v) => setState(() => _mo = v),
                  ),
                  const SizedBox(height: 18),
                  NutXuLy(
                    nhan: 'Lưu thông tin quán',
                    onNhan: () async {
                      if (!_khoa.currentState!.validate()) return;
                      setState(() => _dangluu = true);
                      try {
                        await widget.kho.luuQuan(widget.quan.id, {
                          'tenquan': _ten.text.trim(),
                          'diachi': _diachi.text.trim(),
                          'sodienthoai': KiemTraDuLieu.chuanHoaSoDienThoai(
                            _sdt.text,
                          ),
                          'mota': _mota.text.trim(),
                          'phigiaohang': int.parse(_phi.text.trim()),
                          'dangmocua': _mo,
                        }, anh: _anhMoi);
                        if (context.mounted) Navigator.pop(context);
                      } finally {
                        if (mounted) setState(() => _dangluu = false);
                      }
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
