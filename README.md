# No Nê – Đồ án ứng dụng đặt đồ ăn Flutter

Nhóm dùng **Flutter/Dart, Firebase Authentication và Cloud Firestore**, thanh toán **COD**.

## Bản chạy Firebase mới

Mã hiện tại nằm trong **[do_an/](do_an/)**, trên nhánh `feature/no-ne-firebase-demo`.

- **[Hướng dẫn lấy mã và chạy chung Firebase](tai_lieu/HUONG_DAN_NHOM.txt)**
- **[Tài khoản và mật khẩu demo](tai_lieu/TAI_KHOAN_DEMO.txt)**
- [Kịch bản thử quán → khách đặt COD → admin](tai_lieu/HUONG_DAN_DEMO.txt)
- [Thiết lập Firebase/Android/ảnh Firestore](tai_lieu/HUONG_DAN_FIREBASE.txt)

```powershell
git clone --branch feature/no-ne-firebase-demo https://github.com/Thien7677/PTUDDD-DA-UNGDUNGDATDOAN-FLUTTER.git
cd PTUDDD-DA-UNGDUNGDATDOAN-FLUTTER\do_an
Copy-Item cauhinh_firebase.nhom.json cauhinh_firebase.json
flutter pub get
flutter run -d chrome --dart-define-from-file=cauhinh_firebase.json
```

Chạy Android bằng Android Studio: mở toàn bộ thư mục `do_an` chứa `pubspec.yaml`, thêm `--dart-define-from-file=cauhinh_firebase.json` trong Additional run args của cấu hình Flutter và chọn thiết bị Android. Xem [hướng dẫn Android và ảnh](tai_lieu/HUONG_DAN_ANDROID_VA_ANH.txt). VS Code vẫn có cấu hình **No Nê · Firebase Web** để chạy Web bằng F5. Đã chạy thử với Flutter 3.41.5 / Dart 3.11.3.

## Tình trạng triển khai

- Đăng nhập, đăng ký khách/quán và hồ sơ cá nhân; phân vai khách, chủ quán, admin.
- Khách tìm quán theo tên, xem thực đơn, thêm giỏ thuộc một quán, đặt COD và theo dõi đơn.
- Chủ quán bật/tạm dừng nhận đơn mới, tiếp tục xử lý đơn cũ, xác nhận giao và thu COD riêng, quản lý món/thông tin/ảnh quán.
- Admin duyệt/khóa quán, quản lý trạng thái khách và xem đơn.
- Dữ liệu thật dùng chung trên Firebase `no-ne-food`. Ảnh thật của 2 quán và 8 món mẫu đã lưu trong Firestore. Chọn ảnh từ thiết bị được nén JPEG tối đa 200 KB; giữ Spark, không cần bật Storage hay liên kết thanh toán.
- Android đã đăng ký cùng Firebase, tạo APK debug thành công. Đã đạt 24 kiểm tra Flutter và 98 kiểm tra phân quyền/nghiệp vụ, analyzer không báo lỗi. Chưa chạy tương tác trên thiết bị Android. Bản đồ/định vị và đánh giá sau đơn là phần làm tiếp.

## Thiết kế và phần triển khai trước

- [Thiết kế Figma No Nê](https://www.figma.com/design/mtO6YVZtLv1NuxffgAdecv)
- [Nguyên mẫu luồng đặt món](https://www.figma.com/proto/mtO6YVZtLv1NuxffgAdecv?node-id=3-40&starting-point-node-id=3%3A40&scaling=scale-down)
- [Issue thống nhất và góp ý của nhóm](https://github.com/Thien7677/PTUDDD-DA-UNGDUNGDATDOAN-FLUTTER/issues/2)
- Thư mục [project/](project/) giữ phần Flutter/SQLite trước đó để nhóm đối chiếu khi gộp mã. Các thành viên xem Pull Request của bản Firebase trước khi thống nhất thư mục chính trên `main`.
