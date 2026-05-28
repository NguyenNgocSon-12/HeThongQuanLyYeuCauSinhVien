import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() =>
      _SettingsPageState();
}

class _SettingsPageState
    extends State<SettingsPage> {
  bool notificationEnabled = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        title: const Text("Cài đặt"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          /// ================= HEADER =================
          Container(
            padding:
                const EdgeInsets.all(18),

            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2196F3),
                  Color(0xFF5C6BC0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),

              borderRadius:
                  BorderRadius.circular(20),

              boxShadow: [
                BoxShadow(
                  color:
                      Colors.blue.withOpacity(
                          0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),

            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color:
                        Colors.white.withOpacity(
                            0.2),

                    borderRadius:
                        BorderRadius.circular(
                            14),
                  ),

                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 32,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: const [
                      Text(
                        "Tùy chỉnh ứng dụng",
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        "Quản lý thông báo và giao diện hệ thống",
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,

                        style: TextStyle(
                          color:
                              Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          /// ================= NOTIFICATION =================
          _sectionTitle("Thông báo"),

          const SizedBox(height: 12),

          _buildCard(
            child: SwitchListTile(
              secondary: const Icon(
                Icons.notifications_active,
                color: Colors.orange,
              ),

              title:
                  const Text("Nhận thông báo"),

              subtitle: const Text(
                "Cập nhật trạng thái yêu cầu",
              ),

              value: notificationEnabled,

              onChanged: (value) {
                setState(() {
                  notificationEnabled =
                      value;
                });
              },
            ),
          ),

          const SizedBox(height: 25),

          /// ================= APPEARANCE =================
          _sectionTitle("Giao diện"),

          const SizedBox(height: 12),

          _buildCard(
            child: SwitchListTile(
              secondary: const Icon(
                Icons.dark_mode,
                color: Colors.indigo,
              ),

              title: const Text(
                "Dark Mode",
              ),

              subtitle: const Text(
                "Bật chế độ nền tối",
              ),

              value: darkMode,

              onChanged: (value) {
                setState(() {
                  darkMode = value;
                });
              },
            ),
          ),

          const SizedBox(height: 25),

          /// ================= APP INFO =================
          _sectionTitle("Ứng dụng"),

          const SizedBox(height: 12),

          _buildCard(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(
                    Icons.info,
                    color: Colors.blue,
                  ),

                  title: Text("Phiên bản"),

                  subtitle: Text("1.0.0"),
                ),

                Divider(height: 1),

                ListTile(
                  leading: Icon(
                    Icons.school,
                    color: Colors.green,
                  ),

                  title: Text("Đề tài"),

                  subtitle: Text(
                    "Hệ thống theo dõi yêu cầu sinh viên CNTT",
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// ================= SECTION TITLE =================
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1565C0),
      ),
    );
  }

  /// ================= CARD =================
  Widget _buildCard({
    required Widget child,
  }) {
    return Card(
      elevation: 3,

      shadowColor:
          Colors.black.withOpacity(0.08),

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: child,
    );
  }
}