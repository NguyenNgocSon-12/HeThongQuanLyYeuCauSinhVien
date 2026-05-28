import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        /// ================= AVATAR + INFO HEADER =================
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: const [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 35, color: Colors.blue),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nguyễn Văn A",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "MSSV: 20210001",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        /// ================= THÔNG TIN CÁ NHÂN =================
        const Text(
          "Thông tin cá nhân",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: const [

              ListTile(
                leading: Icon(Icons.email, color: Colors.blue),
                title: Text("Email"),
                subtitle: Text("sv@example.com"),
              ),

              Divider(height: 1),

              ListTile(
                leading: Icon(Icons.class_, color: Colors.green),
                title: Text("Lớp"),
                subtitle: Text("CNTT K20"),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        /// ================= TÀI KHOẢN =================
        const Text(
          "Tài khoản",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [

              ListTile(
                leading: const Icon(Icons.edit, color: Colors.orange),
                title: const Text("Chỉnh sửa thông tin"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(Icons.history, color: Colors.purple),
                title: const Text("Lịch sử yêu cầu"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(Icons.lock, color: Colors.red),
                title: const Text("Đổi mật khẩu"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}