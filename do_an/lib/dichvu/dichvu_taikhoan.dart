import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../cauhinh/cauhinh_firebase.dart';
import '../mohinh/hoso_nguoidung.dart';
import 'kiemtra_dulieu.dart';
import 'kho_taikhoan.dart';

class DichVuTaiKhoan extends KhoTaiKhoan {
  FirebaseAuth? _xacthuc;
  FirebaseFirestore? _cosodulieu;
  FirebaseStorage? _kholuutru;
  StreamSubscription<User?>? _theodoiphien;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _theodoihoso;
  bool _dangxuly = false;
  bool _dangtaihoso = false;
  String? _loiketnoi;
  String? _loihoso;
  HoSoNguoiDung? _hoso;
  int _luotphien = 0;

  @override
  bool get sansang => _xacthuc != null && _cosodulieu != null;
  @override
  bool get dangxuly => _dangxuly;
  @override
  bool get dangtaihoso => _dangtaihoso;
  @override
  bool get dadangnhap => _xacthuc?.currentUser != null;
  @override
  bool get thieuhoso =>
      dadangnhap && !_dangtaihoso && _hoso == null && _loihoso == null;
  @override
  String? get loiketnoi => _loiketnoi;
  @override
  String? get loihoso => _loihoso;
  @override
  String? get emailhientai => _xacthuc?.currentUser?.email;
  @override
  HoSoNguoiDung? get hoso => _hoso;

  Future<void> khoiTao() async {
    if (!CauHinhFirebase.dacauhinh) {
      _loiketnoi =
          'Chưa kết nối Firebase. Bạn vẫn có thể xem giao diện đăng nhập và đăng ký.';
      return;
    }
    try {
      await Firebase.initializeApp(options: CauHinhFirebase.tuychon);
      final xacthuc = FirebaseAuth.instance;
      final cosodulieu = FirebaseFirestore.instance;
      final kholuutru =
          CauHinhFirebase.dunggialap || CauHinhFirebase.kholuutru.isNotEmpty
          ? FirebaseStorage.instance
          : null;
      if (CauHinhFirebase.dunggialap) {
        await xacthuc.useAuthEmulator(CauHinhFirebase.maychugialap, 9099);
        cosodulieu.useFirestoreEmulator(CauHinhFirebase.maychugialap, 8080);
        cosodulieu.settings = const Settings(persistenceEnabled: false);
        await kholuutru!.useStorageEmulator(CauHinhFirebase.maychugialap, 9199);
      }
      _xacthuc = xacthuc;
      _cosodulieu = cosodulieu;
      _kholuutru = kholuutru;
      await xacthuc.setLanguageCode('vi');
      _theodoiphien = xacthuc.authStateChanges().listen((nguoidung) {
        if (!_dangxuly) _theoDoiHoSo(nguoidung);
      });
      _theoDoiHoSo(xacthuc.currentUser);
    } catch (_) {
      _xacthuc = null;
      _cosodulieu = null;
      _loiketnoi =
          'Chưa thể khởi tạo Firebase. Kiểm tra lại cấu hình dự án và kết nối mạng.';
    }
  }

  void _theoDoiHoSo(User? nguoidung) {
    final luot = ++_luotphien;
    unawaited(_theodoihoso?.cancel());
    _hoso = null;
    _loihoso = null;
    _dangtaihoso = nguoidung != null;
    notifyListeners();
    if (nguoidung == null) return;
    _theodoihoso = _cosodulieu!
        .collection('nguoidung')
        .doc(nguoidung.uid)
        .snapshots()
        .listen(
          (banghi) {
            if (luot != _luotphien) return;
            if (!banghi.exists && banghi.metadata.isFromCache) return;
            try {
              _hoso = banghi.exists
                  ? HoSoNguoiDung.tuDuLieu(nguoidung.uid, banghi.data()!)
                  : null;
              _loihoso = null;
            } catch (_) {
              _loihoso =
                  'Hồ sơ chưa hợp lệ. Liên hệ quản trị viên để kiểm tra.';
            }
            _dangtaihoso = false;
            notifyListeners();
          },
          onError: (Object loi) {
            if (luot != _luotphien) return;
            _dangtaihoso = false;
            _loihoso =
                'Chưa đọc được hồ sơ. Kiểm tra kết nối và quyền truy cập Firestore.';
            notifyListeners();
          },
        );
  }

  void _yeuCauKetNoi() {
    if (!sansang) {
      throw const LoiTaiKhoan(
        'Chưa có cấu hình Firebase. Mở “Kết nối Firebase” để xem cách thiết lập.',
      );
    }
    if (_dangxuly) throw const LoiTaiKhoan('Yêu cầu trước đang được xử lý.');
  }

  Future<void> _luuHoSo(User nguoidung, DuLieuDangKy dulieu) async {
    if (dulieu.loaitaikhoan == LoaiTaiKhoan.quantrivien) {
      throw const LoiTaiKhoan('Tài khoản quản trị được cấp riêng.');
    }
    final lachuquan = dulieu.loaitaikhoan == LoaiTaiKhoan.chuquan;
    final ten = KiemTraDuLieu.chuanHoaTenDangNhap(dulieu.tendangnhap);
    if (KiemTraDuLieu.tendangnhap(ten) != null ||
        KiemTraDuLieu.email(dulieu.email) != null ||
        KiemTraDuLieu.sodienthoai(dulieu.sodienthoai) != null) {
      throw const LoiTaiKhoan(
        'Kiểm tra lại tên tài khoản, email và số điện thoại.',
      );
    }
    if (lachuquan &&
        (KiemTraDuLieu.tenquan(dulieu.tenquan) != null ||
            KiemTraDuLieu.diachi(dulieu.diachi) != null ||
            dulieu.anhquan == null)) {
      throw const LoiTaiKhoan('Quán phải có tên, địa chỉ hợp lệ và ảnh quán.');
    }
    final chiso = _cosodulieu!.collection('tendangnhap').doc(ten);
    final datontai = await chiso.get(const GetOptions(source: Source.server));
    if (datontai.exists) {
      throw const LoiTaiKhoan(
        'Tên tài khoản đã có người dùng. Hãy chọn tên khác.',
      );
    }
    Reference? anhdatai;
    if (lachuquan) {
      if (_kholuutru == null) {
        throw const LoiTaiKhoan(
          'Chưa cấu hình kho ảnh Firebase Storage. Cần kết nối kho ảnh để đăng ký quán.',
        );
      }
      final anh = dulieu.anhquan!;
      final vitri = _kholuutru!.ref(
        'anhquanan/${nguoidung.uid}/anhdaidien.${anh.dinhdang}',
      );
      try {
        await vitri.putData(
          anh.dulieu,
          SettableMetadata(contentType: anh.loaitep),
        );
        anhdatai = vitri;
      } on FirebaseException catch (_) {
        throw const LoiTaiKhoan(
          'Chưa tải được ảnh quán. Kiểm tra mạng, Firebase Storage và quyền tải ảnh rồi thử lại.',
        );
      }
    }
    final nhomghi = _cosodulieu!.batch();
    nhomghi.set(chiso, {'manguoidung': nguoidung.uid});
    nhomghi.set(_cosodulieu!.collection('nguoidung').doc(nguoidung.uid), {
      'hoten': '',
      'tendangnhap': ten,
      'email': nguoidung.email,
      'sodienthoai': KiemTraDuLieu.chuanHoaSoDienThoai(dulieu.sodienthoai),
      'loaitaikhoan': dulieu.loaitaikhoan.giatri,
      'trangthai': lachuquan ? 'choduyet' : 'hoatdong',
      'ngaytao': FieldValue.serverTimestamp(),
    });
    if (lachuquan) {
      nhomghi.set(_cosodulieu!.collection('quanan').doc(nguoidung.uid), {
        'chuquanid': nguoidung.uid,
        'tenquan': dulieu.tenquan.trim(),
        'diachi': dulieu.diachi.trim(),
        'duongdananh': anhdatai!.fullPath,
        'sodienthoai': KiemTraDuLieu.chuanHoaSoDienThoai(dulieu.sodienthoai),
        'mota': dulieu.mota.trim(),
        'trangthai': 'choduyet',
        'ngaytao': FieldValue.serverTimestamp(),
      });
    }
    try {
      await nhomghi.commit();
    } catch (loi) {
      if (anhdatai != null) {
        try {
          await anhdatai.delete();
        } catch (_) {
          /* Giữ ảnh nếu chưa xác nhận được quyền xóa. */
        }
      }
      if (loi is FirebaseException && loi.code == 'permission-denied') {
        // Một tài khoản khác có thể vừa giữ tên này sau bước kiểm tra ban đầu.
        final tenhientai = await chiso.get(
          const GetOptions(source: Source.server),
        );
        if (tenhientai.exists) {
          throw const LoiTaiKhoan(
            'Tên tài khoản đã có người dùng. Hãy chọn tên khác.',
          );
        }
      }
      rethrow;
    }
  }

  @override
  Future<void> dangNhap(String email, String matkhau) async {
    _yeuCauKetNoi();
    _dangxuly = true;
    notifyListeners();
    try {
      final ketqua = await _xacthuc!.signInWithEmailAndPassword(
        email: email.trim(),
        password: matkhau,
      );
      _theoDoiHoSo(ketqua.user);
    } on FirebaseAuthException catch (loi) {
      throw LoiTaiKhoan(_thongBaoXacThuc(loi.code));
    } finally {
      _dangxuly = false;
      notifyListeners();
    }
  }

  @override
  Future<void> dangKy(DuLieuDangKy dulieu) async {
    _yeuCauKetNoi();
    _dangxuly = true;
    notifyListeners();
    User? nguoidung;
    try {
      final ketqua = await _xacthuc!.createUserWithEmailAndPassword(
        email: dulieu.email.trim(),
        password: dulieu.matkhau,
      );
      nguoidung = ketqua.user!;
      await _luuHoSo(nguoidung, dulieu);
      _theoDoiHoSo(nguoidung);
    } on FirebaseAuthException catch (loi) {
      throw LoiTaiKhoan(_thongBaoXacThuc(loi.code));
    } catch (loi) {
      var daxoa = nguoidung == null;
      if (nguoidung != null) {
        try {
          await nguoidung.delete();
          daxoa = true;
        } catch (_) {
          /* Có thể tiếp tục hồ sơ sau khi đăng nhập lại. */
        }
        await _xacthuc!.signOut();
        _theoDoiHoSo(null);
      }
      if (!daxoa) {
        throw const LoiTaiKhoan(
          'Email đã được tạo nhưng chưa lưu được hồ sơ. Đăng nhập lại để hoàn thiện hồ sơ.',
        );
      }
      throw LoiTaiKhoan(
        loi is LoiTaiKhoan
            ? loi.thongbao
            : 'Chưa lưu được hồ sơ. Kiểm tra mạng và quyền Firestore rồi đăng ký lại.',
      );
    } finally {
      _dangxuly = false;
      notifyListeners();
    }
  }

  @override
  Future<void> hoanThienHoSo(DuLieuDangKy dulieu) async {
    _yeuCauKetNoi();
    final nguoidung = _xacthuc!.currentUser;
    if (nguoidung == null) throw const LoiTaiKhoan('Bạn cần đăng nhập lại.');
    _dangxuly = true;
    notifyListeners();
    try {
      final banghi = await _cosodulieu!
          .collection('nguoidung')
          .doc(nguoidung.uid)
          .get(const GetOptions(source: Source.server));
      if (banghi.exists) {
        throw const LoiTaiKhoan('Hồ sơ đã tồn tại. Vui lòng tải lại.');
      }
      await _luuHoSo(nguoidung, dulieu);
      _theoDoiHoSo(nguoidung);
    } on FirebaseException catch (_) {
      throw const LoiTaiKhoan(
        'Chưa lưu được hồ sơ. Kiểm tra mạng và quyền Firestore.',
      );
    } finally {
      _dangxuly = false;
      notifyListeners();
    }
  }

  @override
  Future<void> guiEmailDatLaiMatKhau(String email) async {
    _yeuCauKetNoi();
    try {
      await _xacthuc!.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (loi) {
      if (loi.code != 'user-not-found') {
        throw LoiTaiKhoan(_thongBaoXacThuc(loi.code));
      }
    }
  }

  @override
  Future<void> dangXuat() async {
    if (_xacthuc == null) return;
    await _xacthuc!.signOut();
    _theoDoiHoSo(null);
  }

  @override
  void taiLaiHoSo() => _theoDoiHoSo(_xacthuc?.currentUser);

  static String _thongBaoXacThuc(String maloi) => switch (maloi) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'Email hoặc mật khẩu chưa đúng.',
    'email-already-in-use' =>
      'Email này đã được đăng ký. Hãy đăng nhập hoặc đặt lại mật khẩu.',
    'invalid-email' => 'Địa chỉ email không hợp lệ.',
    'weak-password' => 'Mật khẩu chưa đủ mạnh. Dùng ít nhất 8 ký tự.',
    'network-request-failed' => 'Không thể kết nối. Kiểm tra mạng rồi thử lại.',
    'too-many-requests' =>
      'Bạn đã thử nhiều lần. Vui lòng chờ một lúc rồi thử lại.',
    'user-disabled' => 'Tài khoản đã bị vô hiệu hóa. Liên hệ quản trị viên.',
    'operation-not-allowed' =>
      'Dự án chưa bật đăng nhập Email/Password trong Firebase.',
    _ => 'Chưa xử lý được yêu cầu. Vui lòng thử lại.',
  };

  @override
  void dispose() {
    unawaited(_theodoiphien?.cancel());
    unawaited(_theodoihoso?.cancel());
    super.dispose();
  }
}
