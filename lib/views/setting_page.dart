import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

import 'package:pos_qcs/models/customer.dart';
import 'package:pos_qcs/utils/database_helper.dart';
import 'package:pos_qcs/views/sales_invoice_page.dart';
import 'package:pos_qcs/models/posconfig.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_qcs/utils/sync_helper.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';

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
  final _ctrlurl = TextEditingController();
  final _ctrlemail = TextEditingController();
  final _ctrlpassword = TextEditingController();
  final _ctrlwarehouse = TextEditingController();
  final _ctrlcash = TextEditingController();

  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];

  PosConfig _posconfig = PosConfig();
  DatabaseHelper _dbHelper;
  List<PosConfig> _posconfigs = [];
  String data;

  var wifiBSSID;
  var wifiIP;
  var wifiName;
  bool iswificonnected = false;
  bool isInternetOn = true;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper.instance;
    _refreshposconfigList();
    GetConnect();
    if (isInternetOn) {
      setState(() => data = "Internet available");
    } else {
      setState(() => data = "Internet Not available");
    }

    printerManager.scanResults.listen((devices) async {
      // print('UI: Devices found ${devices.length}');
      setState(() {
        _devices = devices;
      });
    });
  }

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    printerManager.startScan(Duration(seconds: 4));
  }

  void _stopScanDevices() {
    printerManager.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
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

  void GetConnect() async {
    print("test");
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        isInternetOn = false;
      });
    } else if (connectivityResult == ConnectivityResult.mobile) {
      iswificonnected = false;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      iswificonnected = true;
      print(iswificonnected);
    }
  }

  _form() => Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _ctrlurl,
              decoration: InputDecoration(labelText: 'URL'),
              onSaved: (val) => setState(() => _posconfig.url = val),
            ),
            TextFormField(
              controller: _ctrlemail,
              decoration: InputDecoration(labelText: 'Email'),
              onSaved: (val) => setState(() => _posconfig.email = val),
            ),
            TextFormField(
              controller: _ctrlpassword,
              decoration: InputDecoration(labelText: 'Password'),
              onSaved: (val) => setState(() => _posconfig.password = val),
            ),
            TextFormField(
              controller: _ctrlwarehouse,
              decoration: InputDecoration(labelText: 'Warehouse'),
              onSaved: (val) => setState(() => _posconfig.warehouse = val),
            ),
            TextFormField(
              controller: _ctrlcash,
              decoration: InputDecoration(labelText: 'Cash'),
              onSaved: (val) => setState(() => _posconfig.cash = val),
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
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    onPressed: () => _alert_item_sync(),
                    child: Text('Sync Items'),
                    color: Colors.pink,
                    textColor: Colors.white,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    onPressed: () => _alert_customer_sync(),
                    child: Text('Sync Customers'),
                    color: Colors.blue,
                    textColor: Colors.white,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    onPressed: () => _alert_price_sync(),
                    child: Text('Sync Item Price'),
                    color: Colors.deepOrangeAccent,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    onPressed: () => _alert_invoice_sync(),
                    child: Text('Sync Current Invoices'),
                    color: Colors.deepPurpleAccent,
                    textColor: Colors.white,
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text("Status:"),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text(data.toString()),
                )
              ],
            )
          ],
        ),
      ));

  _onSave() async {
    GetConnect();
    var form = _formKey.currentState;
    form.save();
    if (_posconfig.id == null)
      await _dbHelper.insertPosConfig(_posconfig);
    else
      await _dbHelper.updatePosConfig(_posconfig);
    _refreshposconfigList();
    form.reset();
  }

  _alert_price_sync() async {
    if (isInternetOn) {
      setState(() => data = "Internet available..Syncing");
      var code = await syncitemprices();
      print(code);
      if (code == 200)
        setState(() => data = "Item Price Sync Success");
      else
        setState(() => data = "Item Price Error");
    } else {
      setState(() => data = "No Internet");
    }
  }

  _alert_item_sync() async {
    if (isInternetOn) {
      setState(() => data = "Internet available..Syncing");
      var code = await syncitems();
      print(code);
      if (code == 200)
        setState(() => data = "Item Sync Success");
      else
        setState(() => data = "Item Sync Error");
    } else {
      setState(() => data = "No Internet");
    }
  }

  _alert_invoice_sync() async {
    if (isInternetOn) {
      setState(() => data = "Internet available..Syncing");
      var code = await syncinvoice();
      setState(() => data = "Syncing in Process...please wait!");
      print(code);
      if (code == 200)
        setState(() => data = "Invoice Sync Success");
      else
        print("Invoice Sync Error");
    } else {
      setState(() => data = "No Internet");
    }
  }

  _alert_customer_sync() async {
    if (isInternetOn) {
      setState(() => data = "Internet available..Syncing");
      var code = await sync_all_customers();
      print(code);
      if (code == 200)
        setState(() => data = "Customer Sync Success");
      else
        print("Customer Sync Error");
    } else {
      setState(() => data = "No Internet");
    }
  }

  _refreshposconfigList() async {
    List<PosConfig> x = await _dbHelper.fetchPosConfigs();
    setState(() {
      _posconfigs = x;
      _posconfig.id = _posconfigs[0].id;
      _posconfig.url = _posconfigs[0].url;
      _posconfig.email = _posconfigs[0].email;
      _posconfig.password = _posconfigs[0].password;
      _posconfig.warehouse = _posconfigs[0].warehouse;
      _posconfig.cash = _posconfigs[0].cash;
      _ctrlurl.text = _posconfig.url;
      _ctrlemail.text = _posconfig.email;
      _ctrlpassword.text = _posconfig.password;
      _ctrlwarehouse.text = _posconfig.warehouse;
      _ctrlcash.text = _posconfig.cash;
    });
    print(x[0].url);
  }
}
