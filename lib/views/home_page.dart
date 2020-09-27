import 'dart:ffi';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pos_qcs/routes/drawer_navigation.dart';
import 'package:pos_qcs/utils/database_helper.dart';
import 'package:pos_qcs/models/posconfig.dart';
import 'package:pos_qcs/models/sales_invoice.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SalesInvoice salesInvoice = SalesInvoice();
  DatabaseHelper _dbHelper;
  List<SalesInvoice> _salesInvoices = [];

  double totalsale = 0;
  double totalcash = 0;
  Timer _everySecond;

  final _ctrltotalsale = TextEditingController();
  final _ctrltotalcash = TextEditingController();
  final _ctrlinvoicecount = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper.instance;

    _everySecond = Timer.periodic(Duration(seconds: 30), (Timer t) {
      _refreshsalesinvoice();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QCS POS'),
      ),
      drawer: DrawerNavigation(),
      body: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text("No of Invoices:"),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text(_ctrlinvoicecount.text),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text("Sale Total:"),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text(_ctrltotalsale.text),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text("Total Cash Held:"),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text(_ctrltotalcash.text),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  _refreshsalesinvoice() async {
    List<SalesInvoice> x = await DatabaseHelper.instance.fetchSalesInvoices();
    double total = 0;
    double totalcash = 0;
    for (int i = 0; i < x.length; i++) {
      if (x[i].grandtotal.isNotEmpty) {
        total += double.parse(x[i].grandtotal);
      }
      if (x[i].paidamount.isNotEmpty) {
        totalcash += double.parse(x[i].paidamount);
      }
    }
    total = total.roundToDouble();
    totalcash = totalcash.roundToDouble();

    setState(() {
      _ctrlinvoicecount.text = x.length.toString();
      _ctrltotalsale.text = total.toString();
      _ctrltotalcash.text = totalcash.toString();
    });
  }
}
