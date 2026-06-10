import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqData = [
      {
        "question": "Làm thế nào để tạo yêu cầu mới?",
        "answer": "Bạn có thể nhấn vào nút '+' (Yêu cầu mới) ở trang chủ, điền đầy đủ thông tin và nhấn Gửi."
      },
      {
        "question": "Thời gian xử lý yêu cầu là bao lâu?",
        "answer": "Thông thường, yêu cầu sẽ được xử lý trong vòng 3-5 ngày làm việc tùy vào tính chất công việc."
      },
      {
        "question": "Tôi có thể chỉnh sửa yêu cầu đã gửi không?",
        "answer": "Nếu yêu cầu đang ở trạng thái 'Chờ xử lý', bạn có thể liên hệ hỗ trợ để yêu cầu chỉnh sửa."
      },
      {
        "question": "Làm sao để biết yêu cầu đã được duyệt?",
        "answer": "Bạn có thể theo dõi trạng thái trực tiếp tại trang 'Tiến độ' hoặc nhận thông báo từ ứng dụng."
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Câu hỏi thường gặp (FAQ)")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqData.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              title: Text(
                faqData[index]['question']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(faqData[index]['answer']!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}