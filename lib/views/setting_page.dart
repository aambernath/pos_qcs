import 'dart:io';
import 'package:flutter/material.dart';

import 'package:pos_qcs/models/customer.dart';
import 'package:pos_qcs/utils/database_helper.dart';
import 'package:pos_qcs/views/sales_invoice_page.dart';

class settingspage extends StatefulWidget {
  settingspage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _settingspageState createState() => _settingspageState();
}

class _settingspageState extends State<settingspage> {
  final _formKey = GlobalKey<FormState>();
  final _ctrlcustomername = TextEditingController();
  final _ctrlmobile = TextEditingController();
  final _ctrlcontactname = TextEditingController();
  final _ctrltrn = TextEditingController();
  final _ctrlterritory = TextEditingController();
  Customer _customer = Customer();
  DatabaseHelper _dbHelper;
  List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper.instance;
    _refreshCustomerList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer List"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[_form()],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _form() => Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _ctrlcustomername,
              decoration: InputDecoration(labelText: 'Customer Name'),
              onSaved: (val) => setState(() => _customer.name = val),
            ),
            TextFormField(
              controller: _ctrlmobile,
              decoration: InputDecoration(labelText: 'Mobile'),
              onSaved: (val) => setState(() => _customer.mobile = val),
            ),
            TextFormField(
              controller: _ctrlcontactname,
              decoration: InputDecoration(labelText: 'Contact Name'),
              onSaved: (val) => setState(() => _customer.contactname = val),
            ),
            TextFormField(
              controller: _ctrltrn,
              decoration: InputDecoration(labelText: 'TRN'),
              onSaved: (val) => setState(() => _customer.trn = val),
            ),
            TextFormField(
              controller: _ctrlterritory,
              decoration: InputDecoration(labelText: 'Territory'),
              onSaved: (val) => setState(() => _customer.territory = val),
            ),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    onPressed: () => _onSave(),
                    child: Text('Save'),
                    color: Colors.green,
                    textColor: Colors.white,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    onPressed: () => _onaddinvoice(),
                    child: Text('Add Invoice'),
                    color: Colors.blue,
                    textColor: Colors.white,
                  ),
                )
              ],
            )
          ],
        ),
      ));

  _refreshCustomerList() async {
    List<Customer> x = await _dbHelper.fetchCustomers();
    setState(() {
      _customers = x;
    });
  }

  _onaddinvoice() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => salesinvoicelist(
              customer: _customer,
            )));
  }

  _onSave() async {
    var form = _formKey.currentState;
    form.save();
    if (_customer.id == null)
      await _dbHelper.insertCustomer(_customer);
    else
      await _dbHelper.updateCustomer(_customer);
    _refreshCustomerList();
    form.reset();
  }

  _list() => Expanded(
        child: Card(
          margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: ListView.builder(
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.account_circle,
                        color: Colors.deepPurple, size: 40.0),
                    title: Text(
                      _customers[index].name.toUpperCase(),
                      style: TextStyle(
                          color: Colors.lime, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_customers[index].mobile),
                    onTap: () {
                      setState(() {
                        _customer = _customers[index];
                        _ctrlcustomername.text = _customers[index].name;
                        _ctrlmobile.text = _customers[index].mobile;
                        _ctrlcontactname.text = _customers[index].contactname;
                        _ctrltrn.text = _customers[index].trn;
                        _ctrlterritory.text = _customers[index].territory;
                      });
                    },
                    onLongPress: () {
                      setState(() {
                        _customer = _customers[index];
                        _ctrlcustomername.text = "";
                        _ctrlmobile.text = "";
                        _ctrlcontactname.text = "";
                        _ctrltrn.text = "";
                        _ctrlterritory.text = "";
                      });
                    },
                  ),
                  Divider(
                    height: 5.0,
                  )
                ],
              );
            },
            itemCount: _customers.length,
          ),
        ),
      );
}
