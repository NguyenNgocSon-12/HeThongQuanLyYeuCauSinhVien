import 'package:flutter/material.dart';
import '../models/request_model.dart';

class RequestCard extends StatelessWidget {
  final RequestModel r;

  const RequestCard(this.r, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.description, color: Colors.blue),
        title: Text(
          r.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(r.status.text),

        /// STATUS CHIP
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: r.status.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            r.status.text,
            style: TextStyle(
              color: r.status.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
