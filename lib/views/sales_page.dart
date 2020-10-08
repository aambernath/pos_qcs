import 'dart:io';
import 'package:flutter/material.dart';

import 'package:pos_qcs/models/sales_invoice.dart';
import 'package:pos_qcs/models/sales_item.dart';
import 'package:pos_qcs/utils/database_helper.dart';
import 'package:pos_qcs/views/sales_invoice_page.dart';

class saleslist extends StatefulWidget {
  saleslist({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _saleslistState createState() => _saleslistState();
}

class _saleslistState extends State<saleslist> {
  final _formKey = GlobalKey<FormState>();

  SalesInvoice salesInvoice = SalesInvoice();
  DatabaseHelper _dbHelper;
  List<SalesInvoice> _salesInvoices = [];
  List<SalesItem> _salesitems = [];

  final _ctrlcustomer = TextEditingController();
  final _ctrlpostingdate = TextEditingController();
  final _ctrlpaidamount = TextEditingController();
  final _ctrlgrandtotal = TextEditingController();
  final _ctrlvat = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper.instance;
    _refreshSalesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sales Invoice List"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        child: Column(
          children: <Widget>[
            Container(
              child: new Row(
                children: <Widget>[
                  Container(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        new Text(
                          "Stored Invoice",
                          style: new TextStyle(
                              color: Colors.lightGreen, fontSize: 12.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _invoicehead(),
            _itemlist(),
            _totalfooter(),
            _list()
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _refreshSalesList() async {
    List<SalesInvoice> x = await _dbHelper.fetchSalesInvoices();
    setState(() {
      _salesInvoices = x;
    });
  }

  _invoicehead() => Card(
      child: Container(
          color: Colors.lightBlue[100],
          padding: EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(_ctrlcustomer.text)),
              Expanded(child: Text("Mobile :")),
              Expanded(child: Text("TRN:")),
            ],
          )));

  _itemlist() => Expanded(
        child: Container(
          margin: EdgeInsets.fromLTRB(5, 10, 10, 0),
          child: Scrollbar(
              child: ListView.builder(
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                    title: new Text(
                      _salesitems[index].itemname,
                      style: new TextStyle(fontSize: 14.0),
                    ),
                    subtitle: new Text("Qty: " +
                        _salesitems[index].qty.toString() +
                        " x " +
                        _salesitems[index].rate.toString() +
                        " AED"),
                    trailing: new Text(
                        "AED " +
                            (double.parse(_salesitems[index].rate) *
                                    double.parse(_salesitems[index].qty))
                                .toString(),
                        style: new TextStyle(fontSize: 14.0)),
                  ),
                ],
              );
            },
            itemCount: _salesitems.length,
          )),
        ),
      );

  _totalfooter() => Card(
      child: Container(
          color: Colors.lightBlue[100],
          padding: EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: <Widget>[
              Expanded(child: Text("Paid: " + _ctrlpaidamount.text)),
              Expanded(child: Text("Outstanding : " + _ctrlvat.text)),
              Expanded(
                  child: Text("Grand Total: " + "AED " + _ctrlgrandtotal.text)),
            ],
          )));

  _form() => Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text("Customer:"),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text(_ctrlcustomer.text),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text("Date:"),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text(_ctrlpostingdate.text),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text("Paid Amount:"),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text(_ctrlpaidamount.text),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text("Total:"),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text(_ctrlgrandtotal.text),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text("VAT:"),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text(_ctrlvat.text),
                )
              ],
            )
          ],
        ),
      ));

  _getitems(invoiceid) async {
    List<SalesItem> x = await _dbHelper.fetchSalesItemlist(invoiceid);
    setState(() {
      _salesitems = x;
    });
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
                      _salesInvoices[index].customer.toUpperCase(),
                      style: TextStyle(
                          color: Colors.lime, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_salesInvoices[index].grandtotal),
                    onTap: () {
                      setState(() {
                        salesInvoice = _salesInvoices[index];

                        _ctrlcustomer.text = _salesInvoices[index].customer;
                        _ctrlpostingdate.text =
                            _salesInvoices[index].postingdate;
                        _ctrlpaidamount.text = _salesInvoices[index].paidamount;
                        _ctrlgrandtotal.text = _salesInvoices[index].grandtotal;

                        _ctrlvat.text = _salesInvoices[index].outstandingamount;
                      });
                      _getitems(salesInvoice.id);
                    },
                  ),
                  Divider(
                    height: 5.0,
                  )
                ],
              );
            },
            itemCount: _salesInvoices.length,
          ),
        ),
      );
}
