# No Nê – Đồ án ứng dụng đặt đồ ăn Flutter

Nhóm dùng **Flutter/Dart, Firebase Authentication và Cloud Firestore**, thanh toán **COD**.

## Bản chạy Firebase mới

Mã hiện tại nằm trong **[do_an/](do_an/)**, trên nhánh `feature/no-ne-firebase-demo`.

- **[Hướng dẫn lấy mã và chạy chung Firebase](do_an/HUONG_DAN_NHOM.md)**
- **[Tài khoản và mật khẩu demo](do_an/TAI_KHOAN_DEMO.md)**
- [Kịch bản thử quán → khách đặt COD → admin](do_an/HUONG_DAN_DEMO.md)
- [Thiết lập Firebase/Android/Storage](do_an/HUONG_DAN_FIREBASE.md)

```powershell
git clone --branch feature/no-ne-firebase-demo https://github.com/Thien7677/PTUDDD-DA-UNGDUNGDATDOAN-FLUTTER.git
cd PTUDDD-DA-UNGDUNGDATDOAN-FLUTTER\do_an
Copy-Item cauhinh_firebase.nhom.json cauhinh_firebase.json
flutter pub get
flutter run -d chrome --dart-define-from-file=cauhinh_firebase.json
```

Mở đúng thư mục `do_an` trong VS Code và chọn **No Nê · Firebase Web** nếu chạy bằng F5. Đã chạy thử với Flutter 3.41.5 / Dart 3.11.3.

## Tình trạng triển khai

- Đăng nhập, đăng ký khách/quán và hồ sơ cá nhân; phân vai khách, chủ quán, admin.
- Khách tìm quán theo tên, xem thực đơn, thêm giỏ thuộc một quán, đặt COD và theo dõi đơn.
- Chủ quán nhận/xử lý đơn, xác nhận giao và thu tiền riêng, quản lý món/thông tin quán.
- Admin duyệt/khóa quán, quản lý trạng thái khách và xem đơn.
- Dữ liệu thật dùng chung trên Firebase `no-ne-food`. Ảnh mẫu dùng Unsplash; tải ảnh quán từ thiết bị cần thiết lập Storage.
- Bản đồ/định vị và đánh giá sau đơn là phần làm tiếp. Android chưa cấu hình Firebase; bản hiện tại dùng Web để demo.

## Thiết kế và phần triển khai trước

- [Thiết kế Figma No Nê](https://www.figma.com/design/mtO6YVZtLv1NuxffgAdecv)
- [Nguyên mẫu luồng đặt món](https://www.figma.com/proto/mtO6YVZtLv1NuxffgAdecv?node-id=3-40&starting-point-node-id=3%3A40&scaling=scale-down)
- [Issue thống nhất và góp ý của nhóm](https://github.com/Thien7677/PTUDDD-DA-UNGDUNGDATDOAN-FLUTTER/issues/2)
- Thư mục [project/](project/) giữ phần Flutter/SQLite trước đó để nhóm đối chiếu khi gộp mã. Các thành viên xem Pull Request của bản Firebase trước khi thống nhất thư mục chính trên `main`.
