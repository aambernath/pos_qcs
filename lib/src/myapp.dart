import 'package:flutter/material.dart';
import 'package:pos_qcs/views/home_page.dart';

class MyApp extends StatelessWidget {
  final appTitle = 'QCS POS';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      home: HomeScreen(),
    );
  }
}
