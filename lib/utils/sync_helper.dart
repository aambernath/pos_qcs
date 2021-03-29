import 'package:flutter/cupertino.dart';
import 'package:pos_qcs/models/item.dart';
import 'package:pos_qcs/models/sales_invoice.dart';
import 'package:pos_qcs/models/sales_item.dart';
import 'package:pos_qcs/models/customer.dart';
import 'package:pos_qcs/utils/database_helper.dart';
import 'package:requests/requests.dart';
import 'dart:convert';
import 'package:pos_qcs/models/posconfig.dart';
import 'package:pos_qcs/models/item_price.dart';

Item _item = Item();
Customer _customer = Customer();
List<SalesInvoice> _salesinvoices = [];
List<SalesItem> _salesitems = [];
PosConfig _posconfig = PosConfig();
List<PosConfig> _posconfigs = [];
List<Customer> _customers = [];
ItemPrice _itemprices = ItemPrice();

List lineitems = [];

sync_all() {
  //syncinvoice();
  syncitemprices();
}

syncitems() async {
  _posconfigs = await DatabaseHelper.instance.fetchPosConfigs();

  String loginurl = _posconfigs[0].url.toString() +
      "/api/method/login?usr=" +
      _posconfigs[0].email.toString() +
      "&pwd=" +
      _posconfigs[0].password.toString();

  print(loginurl);

  String itemurl = _posconfigs[0].url.toString() +
      '/api/resource/Item/?fields=["item_code","sale_rate"]&limit_page_length=0&filters=[["Item", "item_group", "=", "Products"]]';
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
  return x.statusCode;
}

syncitemprices() async {
  _posconfigs = await DatabaseHelper.instance.fetchPosConfigs();

  String loginurl = _posconfigs[0].url.toString() +
      "/api/method/login?usr=" +
      _posconfigs[0].email.toString() +
      "&pwd=" +
      _posconfigs[0].password.toString();

  print(loginurl);

  String itemurl = _posconfigs[0].url.toString() +
      '/api/resource/Item%20Price/?fields=["item_code","price_list_rate","price_list"]&limit_page_length=0';
  print(itemurl);

  await DatabaseHelper.instance.deleteallItemPrice();

  await Requests.get(loginurl);

  var x = await Requests.get(itemurl);

  var data = jsonDecode(x.content());
  print(data);

  for (int i = 0; i < data["data"].length; i++) {
    print(data["data"][i]["item_code"]);
    print(data["data"][i]["price_list"]);
    print(data["data"][i]["price_list_rate"]);
    _itemprices.itemname = data["data"][i]["item_code"];
    _itemprices.pricelist = data["data"][i]["price_list"];
    _itemprices.rate = data["data"][i]["price_list_rate"].toString();
    await DatabaseHelper.instance.insertItemPrice(_itemprices);
  }

  return x.statusCode;
}

sync_all_customers() async {
  _posconfigs = await DatabaseHelper.instance.fetchPosConfigs();

  String loginurl = _posconfigs[0].url.toString() +
      "/api/method/login?usr=" +
      _posconfigs[0].email.toString() +
      "&pwd=" +
      _posconfigs[0].password.toString();

  print(loginurl);

  String itemurl = _posconfigs[0].url.toString() +
      '/api/resource/Customer/?fields=["customer_name","tax_id", "default_price_list"]&limit_page_length=0&filters=[["Customer", "account_manager", "=", "' +
      _posconfigs[0].email.toString() +
      '"]]';
  print(itemurl);

  await DatabaseHelper.instance.deleteallCustomer();

  await Requests.get(loginurl);

  var x = await Requests.get(itemurl);

  var data = jsonDecode(x.content());

  for (int i = 0; i < data["data"].length; i++) {
    print(data["data"][i]["customer_name"]);
    _customer.name = data["data"][i]["customer_name"];
    _customer.trn = data["data"][i]["tax_id"].toString();
    _customer.pricelist = data["data"][i]["default_price_list"].toString();
    await DatabaseHelper.instance.insertCustomer(_customer);
  }

  return x.statusCode;
}

syncinvoice() async {
  _salesinvoices = await DatabaseHelper.instance.fetchSalesInvoices();
  _salesitems = await DatabaseHelper.instance.fetchSalesItems();
  _posconfigs = await DatabaseHelper.instance.fetchPosConfigs();

  //var ret = await pushlocalcust();
  //print(ret);

  String loginurl = _posconfigs[0].url.toString() +
      "/api/method/login?usr=" +
      _posconfigs[0].email.toString() +
      "&pwd=" +
      _posconfigs[0].password.toString();

  print(loginurl);

  Map<String, dynamic> hdata;
  Map<String, dynamic> tdata;
  Map<String, dynamic> fdata;

  List<Map<String, dynamic>> te = [];

  var statuscode;
  await pushlocalcust();

  for (int i = 0; i < _salesinvoices.length; i++) {
    te = [];
    for (int j = 0; j < _salesitems.length; j++) {
      print(_salesitems[j].salesinvoiceid);
      print(_salesinvoices[i].id);
      if (_salesinvoices[i].id == _salesitems[j].salesinvoiceid) {
        tdata = {
          "item_code": "${_salesitems[j].itemname}",
          "qty": "${_salesitems[j].qty}",
          "rate": "${_salesitems[j].rate}"
        };
        print(tdata);
        te.add(tdata);
      }
    }
    //print(_salesinvoices[i].postingdate.substring(0, 4));
    hdata = {
      "naming_series": "ACC-SINV-.YYYY.-",
      "posting_date": "${_salesinvoices[i].postingdate}",
      //"due_date": "${_salesinvoices[i].postingdate}",
      "customer": "${_salesinvoices[i].customer.trimRight()}",
      "is_pos": "1",
      "write_off_amount": "${_salesinvoices[i].writeoff}",
      "write_off_account": "Write Off - BB",
      "pos_id": "${_salesinvoices[i].invid.toString()}",
      "company": "Beirut Automatic Bakery (L.L.C)",
      "update_stock": "1",
      "set_warehouse": "${_posconfigs[0].warehouse}",
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
          "mode_of_payment": "${_posconfigs[0].cash}",
          "amount": "${_salesinvoices[i].paidamount}"
        }
      ],
      "items": te
    };

    fdata = {'"data"': hdata};
    String jsondata = fdata.toString();
    print(jsondata);

    await Requests.get(loginurl);

    String syncloginurl =
        _posconfigs[0].url.toString() + '/api/resource/Sales%20Invoice';

    var response2 = await Requests.post(syncloginurl,
        json: {"data": hdata}, bodyEncoding: RequestBodyEncoding.JSON);

    statuscode = response2.statusCode;
    debugPrint(response2.content());
    print(statuscode);
    if (statuscode != null) {
      if (statuscode == 200) {
        await DatabaseHelper.instance.deletesalesInvoice(_salesinvoices[i].id);
        await DatabaseHelper.instance.deletesalesItems(_salesinvoices[i].id);
      }
    }
  }

  if (statuscode != null) {
    if (statuscode == 200) {
      // await DatabaseHelper.instance.deleteallsalesInvoice();
      //await DatabaseHelper.instance.deleteallsalesItems();
      return statuscode;
    }
  }
  //await DatabaseHelper.instance.deleteallsalesInvoice();
}

pushlocalcust() async {
  String loginurl = _posconfigs[0].url.toString() +
      "/api/method/login?usr=" +
      _posconfigs[0].email.toString() +
      "&pwd=" +
      _posconfigs[0].password.toString();

  String itemurl = _posconfigs[0].url.toString() + '/api/resource/Customer';

  _customers = await DatabaseHelper.instance.fetchCustomers();

  Map<String, dynamic> hdata;
  Map<String, dynamic> fdata;

  //List<Map<String, dynamic>> te = [];

  var response2;

  for (int i = 0; i < _customers.length; i++) {
    if (_customers[i].localcust == 1) {
      hdata = {
        "customer_type": "Company",
        "customer_name": "${_customers[i].name.trimRight()}",
        "customer_group": "Commercial",
        "territory": "United Arab Emirates",
        "tax_id": "${_customers[i].trn}",
        "mobile": "${_customers[i].mobile}",
        "account_manager": "${_posconfigs[0].email.toString()}"
      };

      fdata = {'"data"': hdata};
      String jsondata = fdata.toString();

      response2 = await Requests.post(itemurl,
          json: {"data": hdata}, bodyEncoding: RequestBodyEncoding.JSON);

      _customers[i].localcust = 0;
      await DatabaseHelper.instance.updateCustomer(_customers[i]);
    }
  }
}
