import 'package:flutter/material.dart';

class NGOHomeScreen extends StatelessWidget {
  const NGOHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NGO Home'), backgroundColor: Color(0xFF43A047)),
      body: Center(
        child: Text('Browse available food posts.'),
      ),
    );
  }
}
