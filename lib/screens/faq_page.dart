import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Câu hỏi thường gặp", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: faqData.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                title: Text(
                  faqData[index]['question']!,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      faqData[index]['answer']!,
                      style: TextStyle(color: theme.hintColor, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}