# Thiết kế cơ sở dữ liệu

## Kiến trúc

Ứng dụng sử dụng Cloud Firestore làm nguồn dữ liệu chính và SQLite làm bộ nhớ
đệm cục bộ trên thiết bị.

```text
Firebase Authentication user (uid)
          |
          | 1 - 1
          v
users/{uid}
          |
          | 1 - n qua requests.userId
          v
requests/{requestId}
          |
          | 1 - n qua notifications.requestId
          v
notifications/{notificationId}
```

Firebase Authentication quản lý mật khẩu. Không lưu mật khẩu hoặc password hash
trong Firestore.

## Collection `users`

Document ID là Firebase Authentication UID.

| Field | Kiểu | Ý nghĩa |
| --- | --- | --- |
| `uid` | string | UID Firebase Authentication |
| `mssv` | string | Mã số sinh viên |
| `fullName` | string | Họ tên |
| `fullNameLower` | string | Họ tên chữ thường |
| `email` | string | Email nội bộ |
| `className` | string | Lớp |
| `role` | string | `student` hoặc `admin` |
| `createdAt` | timestamp | Thời điểm tạo |

## Collection `requests`

| Field | Kiểu | Ý nghĩa |
| --- | --- | --- |
| `userId` | string | UID sinh viên gửi yêu cầu |
| `studentId` | string | MSSV |
| `studentName` | string | Họ tên sinh viên |
| `studentNameLower` | string | Họ tên chữ thường |
| `title` | string | Tiêu đề yêu cầu |
| `content` | string | Nội dung chi tiết |
| `status` | string | `pending`, `processing`, `approved`, `rejected` |
| `type` | string | Loại yêu cầu |
| `adminNote` | string? | Ghi chú xử lý |
| `processedBy` | string? | UID admin xử lý |
| `createdAt` | timestamp | Thời điểm gửi |
| `updatedAt` | timestamp | Lần cập nhật gần nhất |
| `processedAt` | timestamp? | Thời điểm xử lý |

## Collection `notifications`

| Field | Kiểu | Ý nghĩa |
| --- | --- | --- |
| `userId` | string | UID người nhận |
| `requestId` | string | Yêu cầu liên quan |
| `title` | string | Tiêu đề |
| `message` | string | Nội dung |
| `type` | string | Loại thông báo |
| `isRead` | bool | Đã đọc hay chưa |
| `createdAt` | timestamp | Thời điểm tạo |
| `readAt` | timestamp? | Thời điểm đọc |

## Đồng bộ SQLite

1. Ứng dụng tạo trước document ID.
2. Yêu cầu được lưu SQLite với `isSynced = 0`.
3. Repository ghi cùng ID lên Firestore.
4. Khi thành công, SQLite chuyển sang `isSynced = 1`.
5. Khi mở danh sách, repository thử đồng bộ lại các bản ghi đang chờ.

Các composite index cần thiết được khai báo trong `firestore.indexes.json`.
