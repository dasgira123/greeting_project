import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final int greeted;
  final int total;
  final double progress;

  const ProgressCard({
    super.key,
    required this.greeted,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Năm Mới Sum Vầy!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$greeted/$total greeted',
                  style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Gửi đi lời chúc, nhận lại niềm vui. Hãy lan tỏa yêu thương trong dịp Tết này!',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}