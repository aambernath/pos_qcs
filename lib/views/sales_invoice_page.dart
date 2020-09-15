import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pos_qcs/models/sales_invoice.dart';
import 'package:pos_qcs/models/sales_item.dart';
import 'package:pos_qcs/models/item.dart';
import 'package:pos_qcs/models/customer.dart';
import 'package:pos_qcs/utils/database_helper.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:oktoast/oktoast.dart';

class salesinvoicelist extends StatefulWidget {
  final String title;
  final Customer customer;
  salesinvoicelist({
    Key key,
    this.title,
    this.customer,
  }) : super(key: key);

  @override
  _salesinvoicelistState createState() => _salesinvoicelistState();
}

class _salesinvoicelistState extends State<salesinvoicelist> {
  final _formKey = GlobalKey<FormState>();
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  Item _item = Item();
  List<SalesItem> _salesitems = [];
  DatabaseHelper _dbHelper;
  List<Item> _items = [];
  Customer _customer = Customer();
  SalesInvoice _salesInvoice = SalesInvoice(
      net: "0",
      vat: "0",
      grandtotal: "0",
      changeamount: "0",
      outstandingamount: "0");

  TextEditingController controller = new TextEditingController();
  String filter;

  ScrollController scrollController;
  bool dialVisible = true;

  var _searchview = new TextEditingController();
  var _paidcontroller = new TextEditingController();
  bool _firstSearch = true;
  String _query = "";
  List<Item> _filteritems = [];

  final _ctrlqty = TextEditingController();
  final _ctrlrate = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper.instance;
    _refreshItemList();
    scrollController = ScrollController()
      ..addListener(() {
        setDialVisible(scrollController.position.userScrollDirection ==
            ScrollDirection.forward);
      });
    _customer = widget.customer;

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

  _showMyDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Printer'),
          content: SingleChildScrollView(
              child: SizedBox(
                  height: 250,
                  width: double.maxFinite,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _devices.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () => _testPrint(_devices[index]),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.print),
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          Text(_devices[index].name ?? ''),
                                          Text(_devices[index].address),
                                          Text(
                                            'Click to print a test receipt',
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Divider(),
                            ],
                          ),
                        );
                      }))),
        );
      },
    );
  }

  void _testPrint(PrinterBluetooth printer) async {
    printerManager.selectPrinter(printer);

    const PaperSize paper = PaperSize.mm58;

    // TEST PRINT
    // final PosPrintResult res =
    // await printerManager.printTicket(await testTicket(paper));

    // DEMO RECEIPT
    final PosPrintResult res =
        await printerManager.printTicket(await demoReceipt(paper));
    showToast(res.msg);
  }

  Future<Ticket> demoReceipt(PaperSize paper) async {
    final Ticket ticket = Ticket(paper);

    ticket.text('Beirut Automatic Bakery',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    ticket.text('Industrial Area 2', styles: PosStyles(align: PosAlign.center));
    ticket.text('Al Quoz, Dubai', styles: PosStyles(align: PosAlign.center));
    ticket.text('Tel: +97143387804', styles: PosStyles(align: PosAlign.center));
    ticket.text('TRN:',
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    ticket.hr();

    ticket.row([
      PosColumn(text: 'Item', width: 7),
      PosColumn(text: 'Qty', width: 1),
      PosColumn(
          text: 'Rate', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'Total', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    for (int i = 0; i < _salesitems.length; i++) {
      ticket.row([
        PosColumn(text: _salesitems[i].itemname, width: 7),
        PosColumn(text: _salesitems[i].qty, width: 1),
        PosColumn(
            text: _salesitems[i].rate,
            width: 2,
            styles: PosStyles(align: PosAlign.right)),
        PosColumn(
            text: _salesitems[i].qty,
            width: 2,
            styles: PosStyles(align: PosAlign.right)),
      ]);
    }

    ticket.hr();

    ticket.row([
      PosColumn(
          text: 'NET',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: _salesInvoice.net,
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
    ]);

    ticket.row([
      PosColumn(
          text: 'VAT',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: _salesInvoice.vat,
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
    ]);

    ticket.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: _salesInvoice.grandtotal,
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
    ]);

    ticket.hr(ch: '=', linesAfter: 1);

    ticket.row([
      PosColumn(
          text: 'Paid',
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
      PosColumn(
          text: 'AED ' + _salesInvoice.paidamount,
          width: 5,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
    ]);
    ticket.row([
      PosColumn(
          text: 'Change',
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
      PosColumn(
          text: 'AED ' + _salesInvoice.changeamount,
          width: 5,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
    ]);

    ticket.feed(2);
    ticket.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy H:m');
    final String timestamp = formatter.format(now);
    ticket.text(timestamp,
        styles: PosStyles(align: PosAlign.center), linesAfter: 2);

    // Print QR Code from image
    // try {
    //   const String qrData = 'example.com';
    //   const double qrSize = 200;
    //   final uiImg = await QrPainter(
    //     data: qrData,
    //     version: QrVersions.auto,
    //     gapless: false,
    //   ).toImageData(qrSize);
    //   final dir = await getTemporaryDirectory();
    //   final pathName = '${dir.path}/qr_tmp.png';
    //   final qrFile = File(pathName);
    //   final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
    //   final img = decodeImage(imgFile.readAsBytesSync());

    //   ticket.image(img);
    // } catch (e) {
    //   print(e);
    // }

    // Print QR Code using native function
    // ticket.qrcode('example.com');

    ticket.feed(2);
    ticket.cut();
    return ticket;
  }

  _salesinvoicelistState() {
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

    _paidcontroller.addListener(() {
      if (_paidcontroller.text.isNotEmpty) {
        _calculatetotals();
      }
    });
  }

  //Floating Button tools
  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  Widget buildBody() {
    return ListView.builder(
      controller: scrollController,
      itemCount: 30,
      itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
    );
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      // child: Icon(Icons.add),
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      visible: dialVisible,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.save, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () => _onSave(),
          label: 'Save',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.green,
        ),
        SpeedDialChild(
          child: Icon(Icons.print, color: Colors.white),
          backgroundColor: Colors.deepOrange,
          onTap: () => _showMyDialog(),
          label: 'Print',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.deepOrangeAccent,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
    return Scaffold(
      appBar: AppBar(
        title: Text("Sales Invoice"),
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
                          formattedDate,
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
            _outstanding(),
            _createSearchView(),
            _firstSearch ? _createListView() : _performSearch()
          ],
        ),
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: buildSpeedDial(),
    );
  }

  _refreshItemList() async {
    List<Item> x = await _dbHelper.fetchItems();
    setState(() {
      _items = x;
    });
  }

  _refreshSalesItemList() async {
    List<Item> x = await _dbHelper.fetchItems();
    setState(() {
      _items = x;
    });
  }

  _onSave() async {
    _calculatetotals();
    _salesInvoice.customer = _customer.name;
    _salesInvoice.postingdate =
        DateFormat('kk:mm:ss \n EEE d MMM').format(DateTime.now());
    _salesInvoice.paidamount = _paidcontroller.text.toString();

    var salesinvoiceid = await _dbHelper.insertSalesInvoice(_salesInvoice);
    print(salesinvoiceid);
    for (int i = 0; i < _salesitems.length; i++) {
      _salesitems[i].salesinvoiceid = salesinvoiceid;
      await _dbHelper.insertsalesitem(_salesitems[i]);
    }
  }

  _calculatetotals() {
    _startScanDevices();
    double total = 0;

    for (int i = 0; i < _salesitems.length; i++) {
      _salesitems[i].amount =
          (double.parse(_salesitems[i].qty) * double.parse(_salesitems[i].rate))
              .toString();
      total = total +
          (double.parse(_salesitems[i].qty) *
              double.parse(_salesitems[i].rate));
    }
    setState(() {
      _salesInvoice.net = total.toStringAsFixed(2);
      _salesInvoice.vat = (total * 0.05).toStringAsFixed(2);
      _salesInvoice.changeamount = "0";
      _salesInvoice.outstandingamount = "0";
      _salesInvoice.grandtotal =
          (double.parse(_salesInvoice.net) + double.parse(_salesInvoice.vat))
              .toStringAsFixed(2);
      _salesInvoice.paidamount = _paidcontroller.text.toString();
      if (_paidcontroller.text.isNotEmpty) {
        if (double.parse(_paidcontroller.text) <=
            double.parse(_salesInvoice.grandtotal))
          _salesInvoice.outstandingamount =
              (double.parse(_salesInvoice.grandtotal) -
                      double.parse(_paidcontroller.text))
                  .toStringAsFixed(2);

        if (double.parse(_paidcontroller.text) >
            double.parse(_salesInvoice.grandtotal))
          _salesInvoice.changeamount = (double.parse(_paidcontroller.text) -
                  double.parse(_salesInvoice.grandtotal))
              .toStringAsFixed(2);
        _salesInvoice.paidamount = _paidcontroller.text.toString();
      }
    });
  }

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
                    onTap: () async {
                      setState(() {
                        _ctrlqty.text = _salesitems[index].qty;
                        _ctrlrate.text = _salesitems[index].rate;
                      });

                      final String newText =
                          await _asyncInputDialog(context, index);

                      setState(() {});
                      _calculatetotals();
                    },
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
              Expanded(child: Text("Net: " + _salesInvoice.net)),
              Expanded(child: Text("Vat : " + _salesInvoice.vat)),
              Expanded(
                  child: Text(
                      "Grand Total: " + "AED " + _salesInvoice.grandtotal)),
            ],
          )));

  _outstanding() => Card(
      child: Container(
          color: Colors.lightBlue[100],
          padding: EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _paidcontroller,
                  decoration: InputDecoration(
                    labelText: 'Paid Amount',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              Expanded(child: Text("Change :" + _salesInvoice.changeamount)),
              Expanded(
                  child:
                      Text("Outstanding: " + _salesInvoice.outstandingamount)),
            ],
          )));

  _invoicehead() => Card(
      child: Container(
          color: Colors.lightBlue[100],
          padding: EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(_customer.name.toString())),
              Expanded(child: Text("Mobile :" + _customer.mobile.toString())),
              Expanded(child: Text("TRN :" + _customer.trn.toString())),
            ],
          )));

  _searchhead() => Container(
        margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: new Column(
          children: <Widget>[
            _createSearchView(),
            _firstSearch ? _createListView() : _performSearch()
          ],
        ),
      );

  //qty rate editting form

  Future<String> _asyncInputDialog(BuildContext context, index) async {
    String sampleText = '';
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Qty or Rate'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                autofocus: true,
                controller: _ctrlqty,
                decoration: new InputDecoration(labelText: 'QTY'),
                onChanged: (value) {
                  _salesitems[index].qty = value;
                },
              )),
              new Expanded(
                  child: new TextField(
                autofocus: true,
                controller: _ctrlrate,
                decoration: new InputDecoration(labelText: 'Rate'),
                onChanged: (value) {
                  _salesitems[index].rate = value;
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(sampleText);
              },
            ),
          ],
        );
      },
    );
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
          itemCount: _items.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.add),
                  title: new Text(
                    _items[index].itemname.toString(),
                    style: new TextStyle(fontSize: 14.0),
                  ),
                  trailing: new Text(
                      "Rate: AED " + _items[index].rate.toString(),
                      style: new TextStyle(fontSize: 14.0)),
                  onTap: () {
                    var flag = 1;
                    SalesItem nval = SalesItem(
                        itemname: _items[index].itemname,
                        rate: _items[index].rate,
                        qty: "1");
                    for (var i = 0; i < _salesitems.length; i++) {
                      if (_salesitems[i].itemname == _items[index].itemname) {
                        setState(() {
                          _salesitems[i].qty =
                              (double.parse(_salesitems[i].qty) + 1).toString();
                        });

                        flag = 0;
                      }
                    }
                    if (flag == 1) {
                      setState(() {
                        _salesitems.add(nval);
                      });
                    }
                    _calculatetotals();
                  },
                ),
              ],
            );
          }),
    );
  }

  //Perform actual search
  Widget _performSearch() {
    _filteritems = new List<Item>();
    for (int i = 0; i < _items.length; i++) {
      var item = _items[i];

      if (item.itemname.toLowerCase().contains(_query.toLowerCase())) {
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
                    _filteritems[index].itemname.toString(),
                    style: new TextStyle(fontSize: 14.0),
                  ),
                  trailing: new Text(
                      "Rate: AED " + _filteritems[index].rate.toString(),
                      style: new TextStyle(fontSize: 14.0)),
                  onTap: () {
                    var flag = 1;
                    SalesItem nval = SalesItem(
                        itemname: _filteritems[index].itemname,
                        rate: _filteritems[index].rate,
                        qty: "1");
                    for (var i = 0; i < _salesitems.length; i++) {
                      if (_salesitems[i].itemname ==
                          _filteritems[index].itemname) {
                        setState(() {
                          _salesitems[i].qty =
                              (double.parse(_salesitems[i].qty) + 1).toString();
                        });

                        flag = 0;
                      }
                    }
                    if (flag == 1) {
                      setState(() {
                        _salesitems.add(nval);
                      });
                    }
                    _calculatetotals();
                  },
                ),
              ],
            );
          }),
    );
  }
}
