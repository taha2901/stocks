import 'package:flutter/material.dart';

class CustomerLoadingWidget extends StatelessWidget {
  const CustomerLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.blueAccent,
      ),
    );
  }
}
