# Hướng dẫn tạo và cấu hình Firebase

Project hiện tại đã có cấu hình Firebase cho project ID `fir-fd3b4` trong:

- `lib/firebase_options.dart`
- `android/app/google-services.json`

Không cần sửa API key thủ công. Nếu dùng Firebase project mới, chạy
`flutterfire configure` để CLI tự cập nhật cấu hình.

## Các bước cấu hình

1. Mở [Firebase Console](https://console.firebase.google.com/).
2. Chọn project `fir-fd3b4`.
3. Vào **Authentication > Sign-in method** và bật **Email/Password**.
4. Vào **Firestore Database** và tạo database nếu chưa có.
5. Tại thư mục dự án, chạy:

```powershell
firebase login
firebase use --add
firebase deploy --only firestore:rules,firestore:indexes
```

## Tạo admin đầu tiên

1. Tạo user trong **Authentication > Users**.
2. Sao chép UID.
3. Tạo document `users/{UID}` trong Firestore.
4. Thêm các field `uid`, `mssv`, `fullName`, `fullNameLower`, `email`,
   `className`, `createdAt` và đặt `role` bằng `admin`.

## Kiểm thử

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

Kiểm tra luồng đăng ký sinh viên, tạo yêu cầu, admin xử lý và notification được
tạo sau khi trạng thái thay đổi.

## Tài liệu chính thức

- [Add Firebase to Flutter](https://firebase.google.com/docs/flutter/setup)
- [Email/Password Authentication](https://firebase.google.com/docs/auth/flutter/password-auth)
- [Cloud Firestore quickstart](https://firebase.google.com/docs/firestore/quickstart)
- [Firestore indexes](https://firebase.google.com/docs/firestore/query-data/indexing)
- [Firebase CLI](https://firebase.google.com/docs/cli)
