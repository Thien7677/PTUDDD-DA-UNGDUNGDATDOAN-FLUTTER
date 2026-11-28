No Nê – Ứng dụng đặt đồ ăn

Project Flutter của nhóm, sử dụng Firebase no-ne-food, thanh toán COD.

Thành viên mới đọc HUONG_DAN_NHOM.txt để lấy mã và chạy cùng Firebase; tài khoản thử nằm trong TAI_KHOAN_DEMO.txt. Có sẵn cấu hình client Web/Android ở cauhinh_firebase.nhom.json; sao chép thành cauhinh_firebase.json trước khi chạy. Phần ảnh thật dùng Firestore Spark, không cần liên kết thanh toán; xem HUONG_DAN_ANDROID_VA_ANH.txt.

Chạy trong VS Code

Mở thư mục C:\Flutter_CN\do_an, chọn cấu hình No Nê · Firebase Web và nhấn F5.

Hoặc chạy trong Terminal của project:

flutter run -d chrome --dart-define-from-file=cauhinh_firebase.json

Các phần chính

- lib/: giao diện, xử lý tài khoản, quán ăn và đơn hàng.
- android/, web/: cấu hình nền tảng chạy thử.
- test/, kiemthu/: kiểm thử giao diện và phân quyền Firebase.
- congcu/: tạo cấu hình và nạp dữ liệu mẫu.
- firestore.rules, storage.rules: quy tắc truy cập dữ liệu và ảnh.

Xem HUONG_DAN_FIREBASE.txt để thiết lập Firebase và HUONG_DAN_DEMO.txt để thử luồng khách, chủ quán và admin.

Cấu hình riêng của nhóm nằm trong cauhinh_firebase.json; tài khoản demo nằm trong .taikhoan_demo.json. Hai file đã được bỏ qua bởi Git.
