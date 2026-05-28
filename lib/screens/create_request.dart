import 'package:flutter/material.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() =>
      _CreateRequestScreenState();
}

class _CreateRequestScreenState
    extends State<CreateRequestScreen> {
  final TextEditingController
      contentController =
      TextEditingController();

  final List<String> templates = [
    "Xin giấy xác nhận sinh viên",
    "Xin nghỉ học",
    "Xin cấp lại thẻ sinh viên",
    "Đăng ký học phần",
    "Khác",
  ];

  String? selectedTemplate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7FC),

      /// ================= APPBAR =================
      appBar: AppBar(
        title: const Text(
          "Tạo yêu cầu mới",
        ),

        centerTitle: true,

        elevation: 0,

        backgroundColor:
            const Color(0xFF1565C0),

        foregroundColor: Colors.white,
      ),

      /// ================= BODY =================
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [
            /// ================= HEADER =================
            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xFF1565C0),
                    Color(0xFF42A5F5),
                  ],
                  begin:
                      Alignment.topLeft,
                  end: Alignment
                      .bottomRight,
                ),

                borderRadius:
                    BorderRadius.circular(
                        24),

                boxShadow: [
                  BoxShadow(
                    color: Colors.blue
                        .withOpacity(0.2),

                    blurRadius: 14,

                    offset:
                        const Offset(
                            0, 6),
                  ),
                ],
              ),

              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  Row(
                    children: [
                      Icon(
                        Icons
                            .edit_document,
                        color:
                            Colors.white,
                        size: 32,
                      ),

                      SizedBox(width: 10),

                      Text(
                        "Gửi yêu cầu",
                        style: TextStyle(
                          color:
                              Colors.white,
                          fontSize: 24,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  Text(
                    "Điền đầy đủ thông tin để Khoa CNTT xử lý nhanh hơn.",
                    style: TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ================= FORM CARD =================
            Container(
              padding:
                  const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                        22),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.05),

                    blurRadius: 10,

                    offset:
                        const Offset(
                            0, 5),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  /// ================= REQUEST TYPE =================
                  const Text(
                    "Loại yêu cầu",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  DropdownButtonFormField<
                      String>(
                    value:
                        selectedTemplate,

                    decoration:
                        InputDecoration(
                      prefixIcon:
                          const Icon(
                        Icons.list_alt,
                      ),

                      hintText:
                          "Chọn loại yêu cầu",

                      filled: true,

                      fillColor:
                          const Color(
                              0xFFF3F6FA),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    14),

                        borderSide:
                            BorderSide
                                .none,
                      ),
                    ),

                    items: templates
                        .map((template) {
                      return DropdownMenuItem(
                        value: template,
                        child:
                            Text(template),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedTemplate =
                            value;
                      });
                    },
                  ),

                  const SizedBox(
                      height: 20),

                  /// ================= CONTENT =================
                  const Text(
                    "Nội dung chi tiết",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  TextField(
                    controller:
                        contentController,

                    maxLines: 6,

                    decoration:
                        InputDecoration(
                      hintText:
                          "Nhập nội dung yêu cầu...",

                      alignLabelWithHint:
                          true,

                      filled: true,

                      fillColor:
                          const Color(
                              0xFFF3F6FA),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    14),

                        borderSide:
                            BorderSide
                                .none,
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 20),

                  /// ================= ATTACH FILE =================
                  OutlinedButton.icon(
                    style:
                        OutlinedButton
                            .styleFrom(
                      minimumSize:
                          const Size(
                              double.infinity,
                              50),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    14),
                      ),
                    ),

                    onPressed: () {
                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Chức năng upload file sẽ được cập nhật",
                          ),
                        ),
                      );
                    },

                    icon: const Icon(
                      Icons.attach_file,
                    ),

                    label: const Text(
                      "Đính kèm minh chứng",
                    ),
                  ),

                  const SizedBox(
                      height: 28),

                  /// ================= SUBMIT BUTTON =================
                  SizedBox(
                    width:
                        double.infinity,
                    height: 55,

                    child:
                        ElevatedButton.icon(
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                                0xFF1565C0),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      16),
                        ),
                      ),

                      onPressed: () {
                        if (selectedTemplate ==
                            null) {
                          ScaffoldMessenger.of(
                                  context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Vui lòng chọn loại yêu cầu",
                              ),
                            ),
                          );

                          return;
                        }

                        if (contentController
                            .text
                            .trim()
                            .isEmpty) {
                          ScaffoldMessenger.of(
                                  context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Vui lòng nhập nội dung",
                              ),
                            ),
                          );

                          return;
                        }

                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              "Đã gửi: $selectedTemplate",
                            ),
                          ),
                        );

                        Navigator.pop(
                            context);
                      },

                      icon: const Icon(
                        Icons.send,
                        color:
                            Colors.white,
                      ),

                      label: const Text(
                        "Gửi yêu cầu",

                        style: TextStyle(
                          color:
                              Colors.white,
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}