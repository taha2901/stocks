import 'package:flutter/material.dart';

class CustomerEmptyWidget extends StatelessWidget {
  const CustomerEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            color: Colors.grey[600],
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد عملاء',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
