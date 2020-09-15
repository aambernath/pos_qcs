import 'package:flutter/cupertino.dart';
import 'package:pos_qcs/models/item.dart';
import 'package:pos_qcs/models/sales_invoice.dart';
import 'package:pos_qcs/models/sales_item.dart';
import 'package:pos_qcs/models/customer.dart';
import 'package:pos_qcs/utils/database_helper.dart';
import 'package:requests/requests.dart';
import 'dart:convert';
import 'package:pos_qcs/models/posconfig.dart';

Item _item = Item();
List<SalesInvoice> _salesinvoices = [];
List<SalesItem> _salesitems = [];
PosConfig _posconfig = PosConfig();
List<PosConfig> _posconfigs = [];
List<Customer> _customers = [];

List lineitems = [];

sync_all() {
  syncinvoice();
}

Future<Requests> syncitems() async {
  _posconfigs = await DatabaseHelper.instance.fetchPosConfigs();

  String loginurl = _posconfigs[0].url.toString() +
      "/api/method/login?usr=" +
      _posconfigs[0].email.toString() +
      "&pwd=" +
      _posconfigs[0].password.toString();

  print(loginurl);

  String itemurl = _posconfigs[0].url.toString() +
      '/api/resource/Item/?fields=["item_code","sale_rate"]';
  print(itemurl);

  await DatabaseHelper.instance.deleteallItem();

  await Requests.get(loginurl);

  var x = await Requests.get(itemurl);

  var data = jsonDecode(x.content());

  for (int i = 0; i < data["data"].length; i++) {
    print(data["data"][i]["item_code"]);
    _item.itemname = data["data"][i]["item_code"];
    _item.rate = data["data"][i]["sale_rate"].toString();
    await DatabaseHelper.instance.insertItem(_item);
  }
}

Future<Requests> sync_all_customers() async {
  _posconfigs = await DatabaseHelper.instance.fetchPosConfigs();
  _customers = await DatabaseHelper.instance.fetchCustomers();

  String loginurl = _posconfigs[0].url.toString() +
      "/api/method/login?usr=" +
      _posconfigs[0].email.toString() +
      "&pwd=" +
      _posconfigs[0].password.toString();

  print(loginurl);

  String itemurl = _posconfigs[0].url.toString() +
      '/api/resource/Customer/?fields=["item_code","sale_rate"]';
  print(itemurl);

  await DatabaseHelper.instance.deleteallItem();

  await Requests.get(loginurl);

  var x = await Requests.get(itemurl);

  var data = jsonDecode(x.content());

  for (int i = 0; i < data["data"].length; i++) {
    print(data["data"][i]["item_code"]);
    _item.itemname = data["data"][i]["item_code"];
    _item.rate = data["data"][i]["sale_rate"].toString();
    await DatabaseHelper.instance.insertItem(_item);
  }
}

Future<Requests> syncinvoice() async {
  await Requests.get(
      'http://157.230.32.98/api/method/login?usr=account@bb.ae&pwd=account_123');

  _salesinvoices = await DatabaseHelper.instance.fetchSalesInvoices();
  _salesitems = await DatabaseHelper.instance.fetchSalesItems();

  Map<String, dynamic> hdata;
  Map<String, dynamic> tdata;
  Map<String, dynamic> fdata;

  List<Map<String, dynamic>> te = [];

  for (int i = 0; i < _salesinvoices.length; i++) {
    for (int j = 0; j < _salesitems.length; j++) {
      if (_salesinvoices[i].id == _salesitems[j].salesinvoiceid) {
        tdata = {
          "item_code": "${_salesitems[j].itemname}",
          "qty": "${_salesitems[j].qty}",
          "rate": "${_salesitems[j].rate}"
        };
        te.add(tdata);
      }
    }
    hdata = {
      "naming_series": "ACC-SINV-.YYYY.-",
      "customer": "${_salesinvoices[i].customer}",
      "is_pos": "1",
      "company": "Beirut Bakery",
      "update_stock": "1",
      "set_warehouse": "Van 1 - BB",
      "taxes_and_charges": "UAE VAT 5% - BB",
      "taxes": [
        {
          "charge_type": "On Net Total",
          "account_head": "VAT 5% - BB",
          "description": "5% VAT",
          "rate": "5"
        }
      ],
      "payments": [
        {
          "mode_of_payment": "Cash - van 2",
          "amount": "${_salesinvoices[i].paidamount}"
        }
      ],
      "items": te
    };

    fdata = {'"data"': hdata};
    String jsondata = fdata.toString();
    print(jsondata);

    var response2 = await Requests.post(
        'http://157.230.32.98/api/resource/Sales%20Invoice',
        json: {"data": hdata},
        bodyEncoding: RequestBodyEncoding.JSON);

    debugPrint(response2.content());
  }
  await DatabaseHelper.instance.deleteallsalesInvoice();
}
