# Kết nối Firebase cho đăng nhập và đăng ký No Nê

Mã nguồn nằm tại `C:\Flutter_CN\do_an`. Chạy lệnh trong thư mục này, nơi có `pubspec.yaml`.

**Thành viên nhóm:** Firebase `no-ne-food` đã được tạo và dùng chung. Đọc [HUONG_DAN_NHOM.md](HUONG_DAN_NHOM.md) để chạy bản hiện tại; không cần tạo lại project hoặc triển khai lại Rules khi chỉ thử ứng dụng. Các bước tạo mới bên dưới là tài liệu thiết lập từ đầu.

## Trạng thái hiện tại

Đã có giao diện đăng nhập, chọn loại đăng ký, đăng ký khách, đăng ký quán, đặt lại mật khẩu, khôi phục phiên và đăng xuất. Firebase Authentication quản lý mật khẩu; Firestore lưu hồ sơ. Khi chưa cấu hình, ứng dụng cho xem giao diện nhưng không giả lập đăng ký thành công hoặc lưu mật khẩu trên máy.

Khách đăng ký bằng tên tài khoản, email, số điện thoại, mật khẩu và xác nhận mật khẩu. Không yêu cầu họ tên/địa chỉ lúc đăng ký; tên hiển thị lưu trống để bổ sung sau ở hồ sơ. Chủ quán nhập thêm tên quán, địa chỉ quán và ảnh quán bắt buộc. Tất cả ô đang hiển thị đều bắt buộc. Tên tài khoản duy nhất, 4–30 ký tự không dấu; đăng nhập hiện dùng **email và mật khẩu**.

## 1. Tạo project và bật dịch vụ

1. Mở https://console.firebase.google.com/ và tạo project `No Ne Food App` cho nhóm.
2. Vào Authentication, bật phương thức Email/Password.
3. Tạo Cloud Firestore, Standard edition, database `(default)`. Chọn vị trí lưu phù hợp với nhóm; vị trí database không đổi được sau khi tạo. Bắt đầu bằng Production mode.
4. Mở tab Rules, dán toàn bộ nội dung `firestore.rules` của dự án rồi Publish. Đăng ký quán cần các quy tắc dùng `getAfter` có trong file này.
5. Bật **Storage** để lưu ảnh quán. Cloud Storage hiện yêu cầu gói **Blaze** và liên kết thanh toán: https://firebase.google.com/docs/storage/flutter/start . Chưa cần bật thanh toán nếu chỉ thử bằng Emulator trên máy. Mã nguồn không tự nâng gói hay tạo tài khoản thanh toán.
6. Trong Storage → Rules, triển khai `storage.rules`. Khi Firebase hỏi cho phép Storage Rules truy cập Firestore, bật quyền này vì quy tắc kiểm tra hồ sơ chủ quán/admin. Lấy đúng tên bucket ở Storage → Files, điền `FIREBASE_KHOLUUTRU` (không có tiền tố `gs://`).

## 2. Cấu hình Android

1. Trong Project settings → Your apps, thêm ứng dụng Android.
2. Android package name phải là **com.example.do_an** (khớp `android/app/build.gradle.kts`). Đăng nhập Email/Password chưa cần SHA-1.
3. Tải `google-services.json` của ứng dụng Android vừa đăng ký.
4. Chạy:

```powershell
node congcu/tao_cauhinh_firebase.cjs "C:\Users\Admin\Downloads\google-services.json"
flutter run --dart-define-from-file=cauhinh_firebase.json
```

Thay đường dẫn bằng vị trí file thực tế. Mã đã khởi tạo Firebase bằng `FirebaseOptions`, vì vậy không cần thêm Google Services Gradle plugin riêng cho luồng Email/Password này.

## 3. Nếu chạy bản web

Đăng ký thêm ứng dụng Web trong cùng Firebase project. Trong SDK setup and configuration, sao chép các giá trị:

| Giá trị Firebase Web | Trường trong cauhinh_firebase.json |
|---|---|
| apiKey | FIREBASE_KHOAAPI_WEB |
| appId | FIREBASE_MAUNGDUNG_WEB |
| projectId | FIREBASE_MADUAN |
| messagingSenderId | FIREBASE_MANGUOIGUI |
| authDomain | FIREBASE_MIENDANGNHAP |
| storageBucket | FIREBASE_KHOLUUTRU |

Chạy `flutter run -d chrome --dart-define-from-file=cauhinh_firebase.json`. Thêm localhost vào Authentication → Settings → Authorized domains nếu Firebase yêu cầu cho thao tác email. Không dùng ID ứng dụng Android cho web.

## Dữ liệu được lưu

- `nguoidung/{uid}`: `tendangnhap`, `hoten` (ban đầu trống), `email`, `sodienthoai`, `loaitaikhoan`, `trangthai`, `ngaytao`.
- `tendangnhap/{ten}`: `manguoidung`. Giữ tên duy nhất cùng batch tạo hồ sơ; không có email/mật khẩu. Không cho liệt kê chỉ mục hoặc sửa tên đã giữ.
- Khách mới: `loaitaikhoan = khachhang`, `trangthai = hoatdong`.
- Chủ quán mới: `loaitaikhoan = chuquan`, `trangthai = choduyet`.
- `quanan/{uid}` của chủ quán: `chuquanid`, `tenquan`, `diachi`, `sodienthoai`, `mota` (trống), `duongdananh`, `trangthai = choduyet`, `ngaytao`.
- Ảnh thật nằm trong Storage: `anhquanan/{uid}/anhdaidien.jpg` (hoặc png/webp). Ứng dụng chỉ nhận ảnh giải mã được, tối đa 5 MB; tải ảnh xong mới ghi hồ sơ quán. Ảnh chưa duyệt chỉ chủ quán và admin được đọc. Không công khai download URL chứa token.
- Hồ sơ chủ quán và quán được ghi trong cùng batch; nếu bị từ chối thì không ghi một nửa.
- Không có trường mật khẩu trong Firestore. Không cho tự tạo admin hoặc tự đổi vai trò.
- Admin được cấp từ môi trường quản trị tin cậy. Khi duyệt quán, cập nhật cả trạng thái tài khoản và hồ sơ quán trong cùng batch. Bản hiện tại đã có giao diện admin; xem kịch bản trong `HUONG_DAN_DEMO.md`.

### Giới hạn cần biết khi phát triển tiếp

Firestore Rules kiểm tra đường dẫn ảnh đúng chủ quán và không được trống; Storage Rules kiểm tra quyền, kích thước và kiểu MIME. Firestore Rules không thể tự xác minh object ảnh thực sự tồn tại trong Storage. Luồng ứng dụng hiện tải ảnh trước khi lưu hồ sơ và admin cần xem ảnh khi duyệt. Khi triển khai công khai, nên thêm hàm máy chủ xác minh ảnh và hoàn tất đăng ký để chặn cả ứng dụng bị sửa/gọi API trực tiếp. MIME do máy khách cung cấp, vì vậy kiểm tra nội dung ảnh ở máy chủ cũng thuộc bước này.

Auth, Storage và Firestore không có một giao dịch chung. Nếu ghi hồ sơ thất bại, ứng dụng cố dọn ảnh vừa tải và tài khoản Auth mới; nếu mất mạng trong lúc dọn, có thể còn dữ liệu chờ xử lý. Có luồng đăng nhập để hoàn thiện hồ sơ thiếu; cần tác vụ dọn dữ liệu thừa khi đưa lên môi trường thật.

## Kiểm thử bằng Firebase Emulator

Chỉ sử dụng project demo, không yêu cầu tài khoản cloud:

```powershell
npx firebase-tools emulators:exec --project demo-no-ne --only auth,firestore,storage "node kiemthu/kiemthu_quyen.cjs"
```

Emulator cần Java 21 trên PATH. Nếu có Android Studio, dùng JBR đi kèm. Khi muốn chạy ứng dụng với emulator:

```powershell
npx firebase-tools emulators:start --project demo-no-ne --only auth,firestore,storage
flutter run -d chrome --dart-define=FIREBASE_DUNGGIALAP=true
```

Android Emulator dùng thêm `--dart-define=FIREBASE_MAYCHUGIALAP=10.0.2.2`. Cấu hình giả lập tách biệt hoàn toàn với dữ liệu Firebase cloud.

## Các lệnh kiểm tra mã

```powershell
flutter analyze
flutter test
```

Các thành phần, biến và trường dữ liệu do dự án định nghĩa dùng tiếng Việt không dấu. Các API chuẩn của Flutter/Firebase giữ tên theo SDK.

Nguồn: https://firebase.google.com/docs/flutter/setup ; https://firebase.google.com/docs/auth/flutter/password-auth ; https://firebase.google.com/docs/firestore/security/rules-conditions
