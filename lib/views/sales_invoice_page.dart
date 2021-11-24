import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pos_qcs/models/sales_invoice.dart';
import 'package:pos_qcs/models/sales_item.dart';
import 'package:pos_qcs/models/item.dart';
import 'package:pos_qcs/models/customer.dart';
import 'package:pos_qcs/models/item_price.dart';
import 'package:pos_qcs/utils/database_helper.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pos_qcs/models/posconfig.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'dart:typed_data';

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
  List<PosConfig> _posconfigs = [];
  var salesinvoiceid;
  String generatedPdfFilePath;

  SalesInvoice _salesInvoice = SalesInvoice(
      net: "0",
      vat: "0",
      grandtotal: "0",
      changeamount: "0",
      outstandingamount: "0",
      writeoff: "0");

  TextEditingController controller = new TextEditingController();
  String filter;

  ScrollController scrollController;
  bool dialVisible = true;

  var _searchview = new TextEditingController();
  var _paidcontroller = new TextEditingController();
  var _writecontroller = new TextEditingController();

  bool _firstSearch = true;
  String _query = "";
  List<Item> _filteritems = [];

  final _ctrlqty = TextEditingController();
  final _ctrlrate = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper.instance;
    salesinvoiceid = null;

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
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<Ticket> demoReceipt(PaperSize paper) async {
    final Ticket ticket = Ticket(paper);
    _posconfigs = await DatabaseHelper.instance.fetchPosConfigs();

    ticket.text('Beirut Automatic Bakery',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);
    ticket.text('Al Quoz, Dubai', styles: PosStyles(align: PosAlign.center));
    ticket.text('Tel: +97143387804', styles: PosStyles(align: PosAlign.center));
    ticket.text('TAX INVOICE', styles: PosStyles(align: PosAlign.center));
    ticket.text('TRN: 100393295900003',
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);
    ticket.row([
      PosColumn(text: 'Cashier:', width: 4),
      PosColumn(text: "${_posconfigs[0].warehouse}", width: 8),
    ]);
    ticket.row([
      PosColumn(text: 'Invoice No :', width: 4),
      PosColumn(text: "${_salesInvoice.invid}", width: 2),
      PosColumn(
          text: " - " + salesinvoiceid.toString(),
          width: 6,
          styles: PosStyles(align: PosAlign.left))
    ]);
    ticket.row([
      PosColumn(text: 'Customer :', width: 4),
      PosColumn(text: "${_salesInvoice.customer}", width: 8),
    ]);
    ticket.row([
      PosColumn(text: 'Cust TRN :', width: 4),
      PosColumn(text: "${_customer.trn}", width: 8),
    ]);

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
      String total =
          (double.parse(_salesitems[i].qty) * double.parse(_salesitems[i].rate))
              .toString();

      if (_salesitems[i].itemname.length >= 18) {
        ticket.row([
          PosColumn(text: _salesitems[i].itemname, width: 12),
        ]);
        ticket.row([
          PosColumn(text: "", width: 7),
          PosColumn(text: _salesitems[i].qty, width: 1),
          PosColumn(
              text: _salesitems[i].rate,
              width: 2,
              styles: PosStyles(align: PosAlign.right)),
          PosColumn(
              text: total, width: 2, styles: PosStyles(align: PosAlign.right)),
        ]);
      } else {
        ticket.row([
          PosColumn(text: _salesitems[i].itemname, width: 7),
          PosColumn(text: _salesitems[i].qty, width: 1),
          PosColumn(
              text: _salesitems[i].rate,
              width: 2,
              styles: PosStyles(align: PosAlign.right)),
          PosColumn(
              text: total, width: 2, styles: PosStyles(align: PosAlign.right)),
        ]);
      }
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

    _writecontroller.addListener(() {
      if (_writecontroller.text.isNotEmpty) {
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
        if (salesinvoiceid == null)
          SpeedDialChild(
            child: Icon(Icons.save, color: Colors.white),
            backgroundColor: Colors.green,
            onTap: () => _onSave(),
            label: 'Save',
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.green,
          ),
        //  if (salesinvoiceid != null)
        //    SpeedDialChild(
        //      child: Icon(Icons.print, color: Colors.white),
        //      backgroundColor: Colors.deepOrange,
        //      onTap: () => _showMyDialog(),
        //      label: 'Print',
        //      labelStyle: TextStyle(fontWeight: FontWeight.w500),
        //      labelBackgroundColor: Colors.deepOrangeAccent,
        //    ),
        if (salesinvoiceid != null)
          SpeedDialChild(
            child: Icon(Icons.print, color: Colors.white),
            backgroundColor: Colors.deepOrange,
            onTap: () => _pdfprint(),
            label: 'PDF',
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.deepOrangeAccent,
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy H:m').format(now);
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
    _salesInvoice.postingdate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _salesInvoice.paidamount = _paidcontroller.text.toString();
    _salesInvoice.writeoff = _writecontroller.text.toString();
    _salesInvoice.invid = DateFormat('dd-MM-yyyy-mmss').format(DateTime.now());
    print("invoiceid:");
    print(salesinvoiceid);

    if (salesinvoiceid == null) {
      salesinvoiceid = await _dbHelper.insertSalesInvoice(_salesInvoice);

      for (int i = 0; i < _salesitems.length; i++) {
        _salesitems[i].salesinvoiceid = salesinvoiceid;
        await _dbHelper.insertsalesitem(_salesitems[i]);
      }
    }
    // _create_invoice_pdf(_salesInvoice.customer);
  }

  _onPrint() async {
    _salesInvoice.printyes = 1;

    // _create_invoice_pdf(_salesInvoice.customer);
  }

  _pdfprint() async {
    _create_invoice_pdf(_salesInvoice.id);
    _onPrint();
  }

  Future<void> _create_invoice_pdf(cust_name) async {
    _posconfigs = await DatabaseHelper.instance.fetchPosConfigs();
    var html1 = """<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>A simple, clean, and responsive HTML invoice template</title>
    
    <style>

@page {
    /* dimensions for the whole page */
    margin:0;
}

html {
    /* off-white, so body edge is visible in browser */
    background: #eee;
}

body {
    /* A5 dimensions */
    margin:0;
    overflow: hidden;
  position: relative;
  box-sizing: border-box;
    width: 210mm;
    height: 147mm;
    font-size:26.5px;

    
}



    .box-title{
  font-weight:bold;
}
.heading-row td{
  font-weight:bold;
  text-align:center;
  border-bottom:solid 1px red;
}
.total-row td{
  font-weight:bold;
}
.v-row td{
  border:1px;
}
@media print{
  
}
    </style>
</head>
<body>
<div class="container-fluid">
  <div id="bill-display">
    <!-- ----- HEADER ---- -->
    <table style="width:100%;">
      <caption class="text-center">TAX INVOICE </caption>
      <tr>
        <td colspan="3" rowspan="3">
          <div class="box-title">
            BEIRUT AUTOMATIC BAKERY L.L.C
          </div>
          <div class="box-content">
           P.O Box 37496, Dubai, U.A.E<br>
        Phone #: +971 4 338 7804<br>
        Fax #: +971 4 338 7682<br>
        Email: beirutbakery1965@gmail.com<br>
        TRN: <b>100393295900003</b>
          </div>
        </td>
        <td colspan="2">
          <div class="box-title">Invoice No</div>
          <div class="box-content">${_salesInvoice.invid}</div>
        </td>
        <td colspan="2">
          <div class="box-title">Date</div>
          <div class="box-content">${DateFormat('dd-MM-yyyy').format(DateTime.now())}</div>
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <div class="box-title">Customer</div>
          <div class="box-content">${_salesInvoice.customer}</div>
        </td>
        <td colspan="2">
          <div class="box-title">CUST TRN</div>
          <div class="box-content">${_customer.trn}</div>
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <div class="box-title"></div>
          <div class="box-content"></div>
        </td>
        <td colspan="2">
          <div class="box-title"></div>
          <div class="box-content"></div>
        </td>
      </tr>
      <tr>
        <td colspan="3" rowspan="3">
          <div class="box-title"></div>
          <div class="box-content">
            
          </div>
        </td>
        <td colspan="4">
          <div class="box-title"></div>
          <div class="box-content"></div>
        </td>
      </tr>
      <tr></tr><tr></tr>
      <!-- ----- BODY ---- -->
      <tr class="heading-row v-row" style="width:100%;">
        <td>No.</td>
        <td>Item</td>
        <td></td>
        <td>Quantity</td>
        <td>Rate</td>
        <td></td>
        <td></td>
        <td>Amount</td>
      </tr>

      
      
           """;

    var html2 = "";

    for (int i = 0; i < _salesitems.length; i++) {
      String total =
          (double.parse(_salesitems[i].qty) * double.parse(_salesitems[i].rate))
              .toString();

      html2 += """
        <tr class="v-row">
        <td>1</td>
        <td>${_salesitems[i].itemname}</td>
        <td></td>
        <td>${_salesitems[i].qty}</td>
        
        <td class="text-right">${_salesitems[i].rate} </td>
        <td></td>
        <td></td>
        <td class="text-right"> $total</td>
         </tr>
              
            """;

      var html3 = "";

      html3 += """ 
        <hr>
        <br><br><br>
        <tr class="total-row v-row">
        <td colspan="3" class="text-right"> </td>
        <td class="text-right"></td>
        <td></td>
        <td></td>
        <td></td>
        <td class="text-right"> </td>
      </tr>
        <br><br><br>
        <tr class="total-row v-row">
        <td colspan="3" class="text-right">Net Total (AED)</td>
        <td class="text-right"></td>
        <td></td>
        <td></td>
        <td></td>
        <td class="text-right">${_salesInvoice.net}</td>
      </tr>
      <tr class="total-row v-row">
        <td colspan="3" class="text-right">Vat (AED)</td>
        <td class="text-right"></td>
        <td></td>
        <td></td>
        <td></td>
        <td class="text-right">${_salesInvoice.vat}</td>
      </tr>
      <tr class="total-row v-row">
        <td colspan="3" class="text-right">Grand Total (AED)</td>
        <td class="text-right"></td>
        <td></td>
        <td></td>
        <td></td>
        <td class="text-right">${_salesInvoice.grandtotal}</td>
      </tr>
      <!-- ----- FOOTER ---- -->
      <tr>
        <td colspan="3">
          <div class="box-content"></div>
          <div class="box-title"></div>
        </td>
        <td colspan="4"></td>
      </tr>
      <tr>
        <td colspan="3">
          Paid Amount: <span id="comp-vat-tin">AED ${_salesInvoice.paidamount}</span><br>
          Change: <span id="comp-cst-no">AED ${_salesInvoice.paidamount}</span><br>
          
        </td>
        <td colspan="4">
          <div class="box-title text-right">
            
          </div>
        </td>
      </tr>
      <tr>
        <td colspan="7" class="text-center">
                    Thank you!
        </td>
      </tr>
    </table>
  </div>
  
</div>
</body?
</html> """;
      var htmlContent = html1 + html2 + html3;

      Directory appDocDir = await getApplicationDocumentsDirectory();
      var targetPath = '/storage/emulated/0/Download/';
      var targetFileName = cust_name;
      print(targetPath);

      var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
          htmlContent, targetPath, targetFileName);
      generatedPdfFilePath = generatedPdfFile.path;
      print(generatedPdfFilePath);
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
      _salesInvoice.writeoff = _writecontroller.text.toString();
      _salesInvoice.net = total.toStringAsFixed(2);
      _salesInvoice.vat = (total * 0.05).toStringAsFixed(2);
      _salesInvoice.changeamount = "0";
      _salesInvoice.outstandingamount = "0";
      _salesInvoice.grandtotal =
          (double.parse(_salesInvoice.net) + double.parse(_salesInvoice.vat))
              .toStringAsFixed(2);

      if (_writecontroller.text.isNotEmpty) {
        _salesInvoice.grandtotal = (double.parse(_salesInvoice.grandtotal) -
                double.parse(_salesInvoice.writeoff))
            .toStringAsFixed(2);
      }

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
                      if (_salesInvoice.printyes != 1) {
                        setState(() {
                          _ctrlqty.text = _salesitems[index].qty;
                          _ctrlrate.text = _salesitems[index].rate;
                        });

                        final String newText =
                            await _asyncInputDialog(context, index);

                        setState(() {});
                        _calculatetotals();
                      }
                    },
                    onLongPress: () => _deletelineitem(index),
                  ),
                ],
              );
            },
            itemCount: _salesitems.length,
          )),
        ),
      );

  _deletelineitem(index) {
    print("longpress");
    _salesitems.removeAt(index);
    _calculatetotals();
    setState(() {});
  }

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
              Expanded(
                child: TextField(
                  controller: _writecontroller,
                  decoration: InputDecoration(
                    labelText: 'Write off',
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
                keyboardType: TextInputType.number,
                decoration: new InputDecoration(labelText: 'QTY'),
                onChanged: (value) {
                  _salesitems[index].qty = value;
                },
              )),
              new Expanded(
                  child: new TextField(
                autofocus: true,
                controller: _ctrlrate,
                keyboardType: TextInputType.number,
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
                  onTap: () => _addlineitem(index),
                ),
              ],
            );
          }),
    );
  }

  _addfilterlineitem(index) async {
    var flag = 1;
    var rrate;

    List<ItemPrice> p_rate = [];

    print(_customer.pricelist);
    if (_customer.pricelist != null) {
      p_rate = await _dbHelper.searchItemPrice(
          _items[index].itemname, _customer.pricelist);
    }
    //print(p_rate[0].rate);
    if (p_rate.isNotEmpty) {
      rrate = p_rate[0].rate;
    } else {
      rrate = _filteritems[index].rate;
    }

    SalesItem nval = SalesItem(
        itemname: _filteritems[index].itemname, rate: rrate, qty: "1");
    for (var i = 0; i < _salesitems.length; i++) {
      if (_salesitems[i].itemname == _filteritems[index].itemname) {
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
  }

  _addlineitem(index) async {
    var flag = 1;
    var rrate;
    List<ItemPrice> p_rate = [];

    print(_customer.pricelist);
    if (_customer.pricelist != null) {
      p_rate = await _dbHelper.searchItemPrice(
          _items[index].itemname, _customer.pricelist);
    }
    //print(p_rate[0].rate);
    if (p_rate.isEmpty) {
      rrate = _items[index].rate;
    } else {
      rrate = p_rate[0].rate;
    }

    SalesItem nval =
        SalesItem(itemname: _items[index].itemname, rate: rrate, qty: "1");
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
                  onTap: () => _addfilterlineitem(index),
                ),
              ],
            );
          }),
    );
  }
}
