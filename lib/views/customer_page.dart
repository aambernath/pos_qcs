import 'dart:io';
import 'package:flutter/material.dart';

import 'package:pos_qcs/models/customer.dart';
import 'package:pos_qcs/utils/database_helper.dart';
import 'package:pos_qcs/views/sales_invoice_page.dart';

class customerlist extends StatefulWidget {
  customerlist({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _customerlistState createState() => _customerlistState();
}

class _customerlistState extends State<customerlist> {
  final _formKey = GlobalKey<FormState>();
  final _ctrlcustomername = TextEditingController();
  final _ctrlmobile = TextEditingController();
  final _ctrlcontactname = TextEditingController();
  final _ctrltrn = TextEditingController();
  final _ctrlterritory = TextEditingController();
  final _ctrlpricelist = TextEditingController();
  Customer _customer = Customer();
  DatabaseHelper _dbHelper;
  List<Customer> _customers = [];

  var _searchview = new TextEditingController();
  bool _firstSearch = true;
  String _query = "";
  List<Customer> _filteritems = [];

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
          children: <Widget>[
            _form(),
            //_list(),
            _createSearchView(),
            _firstSearch ? _createListView() : _performSearch()
          ],
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
              controller: _ctrltrn,
              decoration: InputDecoration(labelText: 'TRN'),
              onSaved: (val) => setState(() => _customer.trn = val),
            ),
            TextFormField(
              controller: _ctrlmobile,
              decoration: InputDecoration(labelText: 'Mobile'),
              onSaved: (val) => setState(() => _customer.mobile = val),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
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

    if (_customer.id == null) {
      _customer.localcust = 1;
      await _dbHelper.insertCustomer(_customer);
    } else {
      await _dbHelper.updateCustomer(_customer);
      _refreshCustomerList();
      form.reset();
    }
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

  _customerlistState() {
    //Register a closure to be called when the object changes.
    _searchview.addListener(() {
      if (_searchview.text.isEmpty) {
        //Notify the framework that the internal state of this object has changed.
        setState(() {
          _firstSearch = true;
          _query = "";
        });
      } else {
        setState(() {
          _firstSearch = false;
          _query = _searchview.text;
        });
      }
    });
  }

  //Create a SearchView
  Widget _createSearchView() {
    return new Container(
      decoration: BoxDecoration(border: Border.all(width: 1.0)),
      child: new TextField(
        controller: _searchview,
        decoration: InputDecoration(
          hintText: "Search",
          hintStyle: new TextStyle(color: Colors.grey[300]),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  //Create a ListView widget
  Widget _createListView() {
    return new Flexible(
      child: new ListView.builder(
          itemCount: _customers.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.add),
                  title: new Text(
                    _customers[index].name.toString(),
                    style: new TextStyle(fontSize: 14.0),
                  ),
                  subtitle: new Text(_customers[index].pricelist.toString(),
                      style: new TextStyle(fontSize: 14.0)),
                  onTap: () {
                    setState(() {
                      _customer = _customers[index];
                      _ctrlcustomername.text = _customers[index].name;
                      _ctrlmobile.text = _customers[index].mobile;
                      _ctrlcontactname.text = _customers[index].contactname;
                      _ctrltrn.text = _customers[index].trn;
                      _ctrlterritory.text = _customers[index].territory;
                      _ctrlpricelist.text = _customers[index].pricelist;
                    });
                  },
                ),
              ],
            );
          }),
    );
  }

  //Perform actual search
  Widget _performSearch() {
    _filteritems = new List<Customer>();
    for (int i = 0; i < _customers.length; i++) {
      var item = _customers[i];

      if (item.name.toLowerCase().contains(_query.toLowerCase())) {
        _filteritems.add(item);
      }
    }
    return _createFilteredListView();
  }

  Widget _createFilteredListView() {
    return new Flexible(
      child: new ListView.builder(
          itemCount: _filteritems.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.add),
                  title: new Text(
                    _filteritems[index].name.toString(),
                    style: new TextStyle(fontSize: 14.0),
                  ),
                  trailing: new Text(_filteritems[index].pricelist.toString(),
                      style: new TextStyle(fontSize: 14.0)),
                  onTap: () {
                    setState(() {
                      _customer = _filteritems[index];
                      _ctrlcustomername.text = _filteritems[index].name;
                      _ctrlmobile.text = _filteritems[index].mobile;
                      _ctrlcontactname.text = _filteritems[index].contactname;
                      _ctrltrn.text = _filteritems[index].trn;
                      _ctrlterritory.text = _filteritems[index].territory;
                      _ctrlpricelist.text = _filteritems[index].pricelist;
                    });
                  },
                ),
              ],
            );
          }),
    );
  }
}
