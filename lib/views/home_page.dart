import 'package:flutter/material.dart';
import 'package:pos_qcs/routes/drawer_navigation.dart';
import 'package:pos_qcs/utils/database_helper.dart';
import 'package:pos_qcs/models/posconfig.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatabaseHelper _dbHelper;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QCS POS'),
      ),
      drawer: DrawerNavigation(),
    );
  }
}
