# Hướng dẫn thành viên 1 chạy Firebase

Tài liệu này dành cho thành viên đang quản lý Firebase project hiện có của
nhóm.

## Thông tin project

- Firebase project ID: `fir-fd3b4`
- Firestore rules: `firestore.rules`
- Firestore indexes: `firestore.indexes.json`

Không tạo Firebase project mới và không sửa API key thủ công.

## 1. Cập nhật và chọn project

```powershell
git pull
flutter pub get
firebase login
firebase projects:list
firebase use --add
firebase use
```

Khi chạy `firebase use --add`, chọn `fir-fd3b4` và đặt alias `default`.

## 2. Cấu hình Firebase Console

1. Vào **Authentication > Sign-in method**.
2. Bật **Email/Password**.
3. Vào **Firestore Database** và tạo database nếu chưa có.

Không cần tạo thủ công `requests` hoặc `notifications`; ứng dụng sẽ tạo khi ghi
dữ liệu đầu tiên.

## 3. Deploy rules và indexes

```powershell
firebase deploy --only firestore:rules,firestore:indexes
```

Chờ các composite index chuyển sang trạng thái **Enabled**.

## 4. Tạo tài khoản admin

1. Vào **Authentication > Users > Add user**.
2. Tạo tài khoản, ví dụ `admin001@huit.edu.vn`.
3. Sao chép UID.
4. Trong Firestore, tạo document `users/{UID}` với các field:

| Field | Type | Giá trị mẫu |
| --- | --- | --- |
| `uid` | string | UID tài khoản |
| `mssv` | string | `ADMIN001` |
| `fullName` | string | `Quản trị viên` |
| `fullNameLower` | string | `quản trị viên` |
| `email` | string | `admin001@huit.edu.vn` |
| `className` | string | Để trống |
| `role` | string | `admin` |
| `createdAt` | timestamp | Thời gian hiện tại |

Document ID phải bằng đúng UID và `role` phải là chuỗi `admin`.

## 5. Chạy kiểm thử

```powershell
flutter analyze
flutter test
flutter run
```

Kiểm thử theo thứ tự:

1. Đăng ký sinh viên.
2. Sinh viên tạo yêu cầu.
3. Admin xem và đổi trạng thái yêu cầu.
4. Kiểm tra collection `notifications`.
5. Sinh viên thấy trạng thái cập nhật realtime.

## Lỗi thường gặp

### `permission-denied`

- Deploy lại `firestore.rules`.
- Kiểm tra hồ sơ admin có đúng UID và `role: "admin"`.

### Firestore yêu cầu index

```powershell
firebase deploy --only firestore:indexes
```

### Không đăng nhập được

- Kiểm tra Email/Password đã bật.
- Kiểm tra thiết bị có mạng.
- Kiểm tra ứng dụng đang dùng project `fir-fd3b4`.

## Checklist

- [ ] Chọn đúng project `fir-fd3b4`.
- [ ] Bật Email/Password.
- [ ] Tạo Firestore Database.
- [ ] Deploy rules và indexes.
- [ ] Tạo hồ sơ admin.
- [ ] Kiểm thử luồng sinh viên/admin thành công.
