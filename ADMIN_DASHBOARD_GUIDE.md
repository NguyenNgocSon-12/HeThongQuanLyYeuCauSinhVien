# Admin Dashboard - Implementation Guide

## Overview
This document outlines all the features implemented for the Admin Dashboard in the Student Request Management System. The dashboard is built with Flutter and integrates Firebase Cloud Firestore, Firebase Storage, and Firebase Cloud Messaging for a complete request management solution.

---

## 📦 Dependencies Added

```yaml
firebase_storage: ^12.1.0          # For evidence file uploads
firebase_messaging: ^15.0.0        # For push notifications
flutter_local_notifications: ^16.1.0  # For local notifications
file_picker: ^6.0.0                # For file selection
```

Run `flutter pub get` after updating pubspec.yaml.

---

## 🏗️ Architecture Overview

### Layer Structure
```
lib/
├── models/           # Data models (RequestModel, UserModel)
├── services/         # Firebase services (Auth, Storage, Messaging)
├── repository/       # Firestore data access layer
├── providers/        # State management (Auth, Theme)
├── screens/          # UI screens
├── widgets/          # Reusable UI components
└── utils/            # Helper utilities
```

---

## 🔥 Core Components

### 1. **Firestore Request Repository** (`firestore_request_repository.dart`)

Complete CRUD operations with Firestore integration:

```dart
final repository = FirestoreRequestRepository();

// Create request
final docId = await repository.createRequest(requestModel);

// Read requests
final allRequests = await repository.getAllRequests();
final byStatus = await repository.getRequestsByStatus(RequestStatus.pending);
final byStudent = await repository.getRequestsByStudentId('SV001');

// Real-time streams
repository.getAllRequestsStream().listen((requests) {
  // Update UI with real-time data
});

// Update request
await repository.updateRequestStatus(requestId, RequestStatus.approved);

// Process request with full details
await repository.processRequest(
  requestId,
  RequestStatus.approved,
  'Approved',
  'Admin Name',
  'file_url',
);

// Get dashboard statistics
final stats = await repository.getDashboardStats();
// Returns: {total: 10, pending: 3, processing: 2, approved: 4, rejected: 1}

// Real-time stats stream
repository.getDashboardStatsStream().listen((stats) {
  // Update dashboard with real-time stats
});
```

**Key Methods:**
- `createRequest()` - Create new request
- `getAllRequests()` / `getAllRequestsStream()` - Fetch all requests
- `getRequestsByStatus()` / `getRequestsStreamByStatus()` - Filter by status
- `getRequestsByType()` - Filter by type
- `getRequestsByStudentId()` - Get student's requests
- `searchRequests()` - Search by student ID or name
- `updateRequestStatus()` - Update request status
- `processRequest()` - Full request processing with evidence file URL
- `getDashboardStats()` / `getDashboardStatsStream()` - Get analytics

---

### 2. **Firebase Storage Service** (`firebase_storage_service.dart`)

Handle evidence file uploads:

```dart
final storage = FirebaseStorageService();

// Upload single file
final fileUrl = await storage.uploadEvidenceFile(requestId, file);

// Upload multiple files
final urls = await storage.uploadMultipleEvidenceFiles(requestId, files);

// Delete file
await storage.deleteEvidenceFile(fileUrl);

// Get file name from URL
final fileName = FirebaseStorageService.getFileNameFromUrl(fileUrl);

// Check if file exists
final exists = await storage.fileExists(fileUrl);
```

**Storage Structure:**
```
gs://your-bucket/
└── evidence_files/
    └── {requestId}/
        ├── {timestamp}_document.pdf
        ├── {timestamp}_photo.jpg
        └── ...
```

---

### 3. **Firebase Notification Service** (`firebase_notification_service.dart`)

Push notifications for admin alerts:

```dart
final notifications = FirebaseNotificationService();

// Initialize (call once in app startup)
await notifications.initialize();

// Get FCM token
final token = await notifications.getFCMToken();

// Subscribe to topic
await notifications.subscribeToTopic('admin_updates');

// Unsubscribe from topic
await notifications.unsubscribeFromTopic('admin_updates');

// Notify new request
await notifications.notifyNewRequest(
  'Xin giấy xác nhận',
  'Nguyễn Văn A',
);

// Notify status update
await notifications.notifyRequestStatusUpdate(
  'SV001',
  'Đã duyệt',
);

// Subscribe admin
await notifications.subscribeAdminToUpdates();
```

**Features:**
- Local and remote notifications
- Foreground message handling
- Background message handling
- Topic-based subscriptions
- Custom notification channels

---

### 4. **Request Model Updates** (`request_model.dart`)

Added evidence file support:

```dart
class RequestModel {
  String? id;                    // Firestore doc ID
  String title;
  String content;
  String studentName;
  String studentId;
  RequestStatus status;
  RequestType type;
  String? adminNote;
  String? processedBy;
  String? evidenceFileUrl;      // NEW: Evidence file URL
  DateTime createdAt;
  DateTime? processedAt;

  // ... rest of model
}
```

---

### 5. **Auth Provider** (`auth_provider.dart`)

Centralized authentication state management:

```dart
// Wrap app with provider
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
  ],
  child: MyApp(),
);

// Access auth state
final authProvider = Provider.of<AuthProvider>(context);

if (authProvider.isAuthenticated) {
  print('User: ${authProvider.currentUser?.email}');
}

// Login
final success = await authProvider.loginWithMSSV(mssv, password);

// Check role
if (authProvider.isAdmin()) {
  // Show admin screens
}

// Logout
await authProvider.logout();
```

---

### 6. **Firestore Query Helper** (`firestore_query_helper.dart`)

Advanced query utilities:

```dart
// Get with pagination
final requests = await FirestoreQueryHelper.getRequestsWithPagination(
  pageSize: 10,
  lastDocument: lastDoc,
);

// Complex filtering
final filtered = await FirestoreQueryHelper.getFilteredRequests(
  status: RequestStatus.pending,
  type: RequestType.leave,
  studentId: 'SV001',
  dateFrom: DateTime(2024, 1, 1),
  dateTo: DateTime(2024, 12, 31),
);

// Count by status
final countByStatus = await FirestoreQueryHelper.getCountByStatus();

// Date range
final rangeRequests = await FirestoreQueryHelper.getRequestsForDateRange(
  DateTime(2024, 1, 1),
  DateTime(2024, 12, 31),
);

// Get requests with evidence files
final withEvidence = await FirestoreQueryHelper.getRequestsWithEvidenceFiles();

// Recently updated
final recent = await FirestoreQueryHelper.getRecentlyUpdatedRequests(limit: 10);
```

---

## 📊 Admin Screens

### 1. **Admin Home** (`admin_home.dart`)
Dashboard with quick access cards:
- **Statistics** → Navigate to statistical dashboard
- **All Requests** → View all requests
- **Pending** → Filter pending requests
- **Processing** → View processing requests
- **Completed** → Approved requests
- **Rejected** → Rejected requests

**Features:**
- Initializes push notifications
- Subscribes admin to updates topic
- Grid layout with action cards

### 2. **Request List Screen** (`admin_request_list.dart`)
Real-time request list with filtering:
- Search by MSSV or student name
- Filter by status (Pending, Processing, Approved, Rejected)
- Filter by type (Confirm, Leave, Complaint)
- Real-time updates via Firestore Stream
- Click to process individual requests

```dart
// Real-time data binding
StreamBuilder<List<RequestModel>>(
  stream: _repository.getAllRequestsStream(),
  builder: (context, snapshot) {
    // Auto-updates when Firestore data changes
  },
);
```

### 3. **Process Request Screen** (`process_request.dart`)
Request processing interface:
- View request details
- Add admin notes
- Update request status (Processing, Approved, Rejected)
- Upload evidence files
- Confirmation dialogs
- Real-time Firestore updates
- Push notifications on status change

```dart
// Update status with full details
await _repository.processRequest(
  requestId,
  RequestStatus.approved,
  'Approved via verification',
  'Admin Name',
  evidenceFileUrl,
);
```

### 4. **Statistical Dashboard** (`admin_statistical_dashboard.dart`)
Advanced analytics and metrics:
- **Total Requests** - All submitted requests
- **Pending** - Awaiting processing
- **Processing** - Currently being processed
- **Completed** - Total approved + rejected
- **Approved** - Successful requests
- **Rejected** - Declined requests
- **Request Distribution** - By type (Confirm, Leave, Complaint)
- **Recent Activity** - Last 5 requests

**Features:**
- Real-time data updates
- Visual progress bars
- Type distribution chart
- Activity timeline
- Timestamp tracking

---

## 🔄 Real-Time Data Binding

All admin screens use Firestore Streams for real-time updates:

```dart
// Request List automatically updates when Firestore changes
Stream<List<RequestModel>> getAllRequestsStream()

// Dashboard stats update in real-time
Stream<Map<String, int>> getDashboardStatsStream()

// Status-specific streams
Stream<List<RequestModel>> getRequestsStreamByStatus(RequestStatus status)
```

**Benefits:**
- No manual refresh needed
- Multiple users see updates instantly
- Better user experience
- Efficient data sync

---

## 📁 File Upload Workflow

### Upload Evidence Files:
1. Click "Choose File" in ProcessRequestScreen
2. Select file from device
3. Click "Upload" to upload to Firebase Storage
4. File URL automatically added to request
5. File accessible at generated URL

### File Storage Location:
```
gs://your-bucket/evidence_files/{requestId}/{timestamp}_{filename}
```

### Retrieve File:
```dart
// File URL stored in request.evidenceFileUrl
final fileUrl = request.evidenceFileUrl;
// Use fileUrl to display/download file
```

---

## 🔔 Push Notifications Setup

### Initialize in App:
```dart
@override
void initState() {
  super.initState();
  FirebaseNotificationService().initialize();
}
```

### Subscribe Admin to Updates:
```dart
await FirebaseNotificationService().subscribeAdminToUpdates();
```

### Trigger Notifications:
```dart
// New request submitted
await _notificationService.notifyNewRequest(
  'Request Title',
  'Student Name',
);

// Status updated
await _notificationService.notifyRequestStatusUpdate(
  'SV001',
  'Đã duyệt',
);
```

### Firebase Cloud Messaging Setup:
1. Configure FCM in Firebase Console
2. Download google-services.json (Android)
3. Configure in Xcode (iOS)
4. Create server-side logic to send messages to `admin_updates` topic

---

## 🗄️ Firestore Database Schema

### Collections:

**requests**
```json
{
  "id": "doc_id",
  "title": "Xin giấy xác nhận",
  "content": "...",
  "studentName": "Nguyễn Văn A",
  "studentId": "SV001",
  "status": 0,                    // 0:pending, 1:processing, 2:approved, 3:rejected
  "type": 0,                      // 0:confirm, 1:leave, 2:complaint
  "adminNote": "Approved",
  "processedBy": "Admin Name",
  "evidenceFileUrl": "https://...", // Optional
  "createdAt": "2024-01-15T10:30:00.000Z",
  "processedAt": "2024-01-15T14:30:00.000Z"
}
```

**users** (created by AuthService)
```json
{
  "uid": "firebase_uid",
  "mssv": "SV001",
  "fullName": "Nguyễn Văn A",
  "className": "12DHTh01",
  "role": "student",              // or "admin"
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

---

## 🚀 Implementation Checklist

### Prerequisites:
- [x] Flutter SDK installed
- [x] Firebase project created
- [x] Firestore database enabled
- [x] Firebase Storage enabled
- [x] Firebase Authentication enabled
- [x] Firebase Cloud Messaging enabled

### Setup Steps:
1. **Update pubspec.yaml** - Add new dependencies
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

3. **Test Features:**
   - [ ] Admin login works
   - [ ] Request list loads with real-time data
   - [ ] Search/filter functions work
   - [ ] Can process requests
   - [ ] Can upload files
   - [ ] Dashboard shows correct stats
   - [ ] Notifications trigger

---

## 📋 Usage Examples

### Example 1: Create and Submit Request
```dart
final request = RequestModel(
  title: "Xin giấy xác nhận",
  content: "Cần xác nhận sinh viên",
  studentName: "Nguyễn Văn A",
  studentId: "SV001",
  type: RequestType.confirm,
);

final docId = await FirestoreRequestRepository().createRequest(request);
print('Request created: $docId');
```

### Example 2: Process Request with File
```dart
final file = File('/path/to/document.pdf');
final fileUrl = await FirebaseStorageService().uploadEvidenceFile(
  requestId,
  file,
);

await FirestoreRequestRepository().processRequest(
  requestId,
  RequestStatus.approved,
  'Document verified',
  'Admin Name',
  fileUrl,
);
```

### Example 3: Real-time Dashboard Update
```dart
FirestoreRequestRepository().getDashboardStatsStream().listen((stats) {
  setState(() {
    totalRequests = stats['total'];
    pendingRequests = stats['pending'];
    approvedRequests = stats['approved'];
  });
});
```

### Example 4: Search Requests
```dart
final results = await FirestoreRequestRepository().searchRequests('SV001');
results.forEach((request) {
  print('${request.studentName}: ${request.title}');
});
```

---

## 🐛 Troubleshooting

### Issue: File upload fails
**Solution:** Check Firebase Storage rules are configured correctly

### Issue: Real-time updates not working
**Solution:** Ensure Firestore security rules allow reads, check Stream is properly listened to

### Issue: Notifications not received
**Solution:** 
1. Check device has notification permissions
2. Verify FCM configuration
3. Check admin is subscribed to `admin_updates` topic

### Issue: Status update doesn't save
**Solution:** Verify request ID exists in Firestore, check security rules

---

## 🔒 Security Considerations

### Firestore Security Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Requests: Admins can read/write, students can read own
    match /requests/{document=**} {
      allow read: if request.auth != null;
      allow write: if isAdmin();
    }
    
    // Users: Can read own, admins read all
    match /users/{userId} {
      allow read: if request.auth.uid == userId || isAdmin();
      allow write: if request.auth.uid == userId || isAdmin();
    }
  }
}

function isAdmin() {
  return request.auth.token.role == 'admin';
}
```

### Firebase Storage Rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /evidence_files/{requestId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && isAdmin();
    }
  }
}

function isAdmin() {
  return request.auth.token.role == 'admin';
}
```

---

## 📈 Performance Tips

1. **Use pagination** for large request lists:
   ```dart
   final requests = await FirestoreQueryHelper.getRequestsWithPagination(
     pageSize: 20,
     lastDocument: lastDoc,
   );
   ```

2. **Filter early** in queries to reduce data transfer:
   ```dart
   final filtered = await FirestoreQueryHelper.getFilteredRequests(
     status: RequestStatus.pending,
   );
   ```

3. **Cache dashboard stats** to reduce query load

4. **Lazy load** request details only when opened

---

## 🎯 Future Enhancements

- [ ] Batch operations for bulk request updates
- [ ] Export requests to CSV/PDF
- [ ] Advanced filtering and sorting options
- [ ] Request templates
- [ ] Automated email notifications
- [ ] Request assignment to specific admins
- [ ] Audit logging
- [ ] Custom status workflows
- [ ] SLA tracking
- [ ] Analytics and insights

---

## 📞 Support

For issues or questions:
1. Check Firebase Console for errors
2. Review Firestore security rules
3. Check console logs for error messages
4. Verify all dependencies are installed

---

**Last Updated:** 2024
**Version:** 1.0.0
