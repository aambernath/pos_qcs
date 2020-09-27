import 'package:flutter/material.dart';
import 'package:pos_qcs/views/item_page.dart';
import 'package:pos_qcs/views/customer_page.dart';
import 'package:pos_qcs/views/sales_page.dart';
import 'package:pos_qcs/utils/sync_helper.dart';
import 'package:pos_qcs/views/setting_page.dart';
import 'package:pos_qcs/utils/database_helper.dart';
import 'package:pos_qcs/models/posconfig.dart';

class DrawerNavigation extends StatelessWidget {
  final String title;

  DrawerNavigation({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    NetworkImage('http://157.230.32.98/files/bb_logo.jpg'),
              ),
              accountName: Text('Beirut Bakery'),
              //accountEmail: Text('getemail().toString()'),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: Icon(Icons.contacts),
              title: Text('Customer'),
              subtitle: Text('View / Add Customers'),
              trailing: Icon(Icons.view_list),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => customerlist())),
            ),
            ListTile(
              leading: Icon(Icons.shopping_basket),
              title: Text('Inventory'),
              subtitle: Text('Current Stock'),
              trailing: Icon(Icons.view_list),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => itemlist())),
            ),
            ListTile(
              leading: Icon(Icons.library_books),
              title: Text('Sales Invoices'),
              subtitle: Text('View Invoices held'),
              trailing: Icon(Icons.view_list),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => saleslist())),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings & Sync'),
              subtitle: Text('set user details & sync'),
              trailing: Icon(Icons.view_list),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => settingspage())),
            ),
          ],
        ),
      ),
    );
  }
}
