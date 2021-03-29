import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:pos_qcs/models/customer.dart';
import 'package:pos_qcs/models/item.dart';
import 'package:pos_qcs/models/sales_invoice.dart';
import 'package:pos_qcs/models/sales_item.dart';
import 'package:pos_qcs/models/posconfig.dart';
import 'package:pos_qcs/models/item_price.dart';

class DatabaseHelper {
  static const _databaseName = 'qcs_pos4.db';
  static const _databaseVersion = 4;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory dataDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(dataDirectory.path, _databaseName);
    return await openDatabase(dbPath,
        version: _databaseVersion, onCreate: _onCreateDB);
  }

  Future _onCreateDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${Customer.tblCustomer}(
        ${Customer.colid} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Customer.colname} TEXT,
        ${Customer.colmobile} TEXT,
        ${Customer.colcontactname} TEXT,
        ${Customer.coltrn} TEXT,
        ${Customer.colterritory} TEXT,
        ${Customer.colpricelist} TEXT,
        ${Customer.collocalcust} INTEGER
      )''');

    await db.execute(""" 
      CREATE TABLE ${Item.tblItem}(
        ${Item.colid} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Item.colitemname} TEXT,
        ${Item.colqty} TEXT,
        ${Item.colrate} TEXT
      )""");

    await db.execute(""" 
      CREATE TABLE ${ItemPrice.tblItemPrice}(
        ${ItemPrice.colid} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ItemPrice.colitemname} TEXT,
        ${ItemPrice.colpricelist} TEXT,
        ${ItemPrice.colrate} TEXT
      )""");

    await db.execute(""" 
      CREATE TABLE ${SalesItem.tblSalesItem}(
        ${SalesItem.colid} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${SalesItem.colitemname} TEXT,
        ${SalesItem.colqty} TEXT,
        ${SalesItem.colrate} TEXT,
        ${SalesItem.colamount} TEXT,
        ${SalesItem.colsalesinvoiceid} INTEGER
      )""");

    await db.execute(""" 
      CREATE TABLE ${SalesInvoice.tblSalesInvoice}(
        ${SalesInvoice.colid} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${SalesInvoice.colcustomer} TEXT,
        ${SalesInvoice.colpostingdate} TEXT,
        ${SalesInvoice.colnet} TEXT,
        ${SalesInvoice.colvat} TEXT,
        ${SalesInvoice.colgrandtotal} TEXT,
        ${SalesInvoice.colpaidamount} TEXT,
        ${SalesInvoice.colchangeamount} TEXT,
        ${SalesInvoice.coloutstandingamount} TEXT,
        ${SalesInvoice.colwriteoff} TEXT,
        ${SalesInvoice.colinvid} TEXT


      )""");

    await db.execute(""" 
      CREATE TABLE ${PosConfig.tblPosconfig}(
        ${PosConfig.colid} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${PosConfig.colurl} TEXT,
        ${PosConfig.colemail} TEXT,
        ${PosConfig.colpassword} TEXT,
        ${PosConfig.colwarehouse} TEXT,
        ${PosConfig.colcash} TEXT,
        ${PosConfig.colcurrentno} INTEGER
      )""");
  }

//Customer
  Future<int> insertCustomer(Customer customer) async {
    Database db = await database;
    return await db.insert(Customer.tblCustomer, customer.toMap());
  }

  Future<List<Customer>> fetchCustomers() async {
    Database db = await database;
    List<Map> customers = await db.query(Customer.tblCustomer);
    return customers.length == 0
        ? []
        : customers.map((x) => Customer.fromMap(x)).toList();
  }

  Future<int> updateCustomer(Customer customer) async {
    Database db = await database;
    return await db.update(Customer.tblCustomer, customer.toMap(),
        where: '${Customer.colid}=?', whereArgs: [customer.id]);
  }

  Future<int> deleteCustomer(int id) async {
    Database db = await database;
    return await db.delete(Customer.tblCustomer,
        where: '${Customer.colid}=?', whereArgs: [id]);
  }

  Future<int> deleteallCustomer() async {
    Database db = await database;
    return await db.delete(Customer.tblCustomer);
  }

  Future<List<Customer>> fetchCustomer(String cust) async {
    Database db = await database;
    List<Map> customer = await db.query(Customer.tblCustomer,
        where: '${Customer.colname}=?', whereArgs: [cust]);
    return customer.length == 0
        ? []
        : customer.map((x) => Customer.fromMap(x)).toList();
  }

  //Sales Head

  //Customer
  Future<int> insertSalesInvoice(SalesInvoice salesInvoice) async {
    Database db = await database;
    int siid =
        await db.insert(SalesInvoice.tblSalesInvoice, salesInvoice.toMap());
    return siid;
  }

  Future<List<SalesInvoice>> fetchSalesInvoices() async {
    Database db = await database;
    List<Map> salesinvoices = await db.query(SalesInvoice.tblSalesInvoice);
    return salesinvoices.length == 0
        ? []
        : salesinvoices.map((x) => SalesInvoice.fromMap(x)).toList();
  }

  //sales item
  Future<int> insertsalesitem(SalesItem salesitem) async {
    Database db = await database;
    return await db.insert(SalesItem.tblSalesItem, salesitem.toMap());
  }

  Future<List<SalesItem>> fetchSalesItems() async {
    Database db = await database;
    List<Map> salesitems = await db.query(SalesItem.tblSalesItem);
    return salesitems.length == 0
        ? []
        : salesitems.map((x) => SalesItem.fromMap(x)).toList();
  }

  Future<List<SalesItem>> fetchSalesItemlist(int invoiceid) async {
    Database db = await database;
    List<Map> salesitems = await db.query(SalesItem.tblSalesItem,
        where: '${SalesItem.colsalesinvoiceid}=?', whereArgs: [invoiceid]);
    return salesitems.length == 0
        ? []
        : salesitems.map((x) => SalesItem.fromMap(x)).toList();
  }

  //Inventory List

  Future<int> insertItem(Item item) async {
    Database db = await database;
    return await db.insert(Item.tblItem, item.toMap());
  }

  Future<int> deleteallItem() async {
    Database db = await database;
    return await db.delete(Item.tblItem);
  }

//Inventory - retrieve all

  Future<List<Item>> fetchItems() async {
    Database db = await database;
    List<Map> items = await db.query(Item.tblItem);
    return items.length == 0 ? [] : items.map((x) => Item.fromMap(x)).toList();
  }

//Inventory Search
  Future<List<Item>> searchProduct(String name) async {
    Database db = await database;
    var res = await db
        .rawQuery("SELECT * FROM Item WHERE itemname like '%" + name + "%'");
    List<Item> list =
        res.isNotEmpty ? res.map((c) => Item.fromMap(c)).toList() : [];

    return list;
  }

  //Price List

  Future<int> insertItemPrice(ItemPrice itemPrice) async {
    Database db = await database;
    return await db.insert(ItemPrice.tblItemPrice, itemPrice.toMap());
  }

  Future<int> deleteallItemPrice() async {
    Database db = await database;
    return await db.delete(ItemPrice.tblItemPrice);
  }

  Future<List<ItemPrice>> fetchItemprices() async {
    Database db = await database;
    List<Map> items = await db.query(ItemPrice.tblItemPrice);
    return items.length == 0
        ? []
        : items.map((x) => ItemPrice.fromMap(x)).toList();
  }

  Future<List<ItemPrice>> searchItemPrice(String item, String pricelist) async {
    print(item);
    print(pricelist);
    Database db = await database;
    List<Map> res = await db.rawQuery(
        "SELECT * FROM itemprices WHERE itemname =? and pricelist=?",
        [item, pricelist]);
    List<ItemPrice> list =
        res.isNotEmpty ? res.map((c) => ItemPrice.fromMap(c)).toList() : [];

    return list;
  }

  // Sales Invoice Items

  Future<int> deletesalesInvoice(int invid) async {
    Database db = await database;
    return await db
        .delete("salesinvoices", where: 'id = ?', whereArgs: [invid]);
  }

  Future<int> deletesalesItems(int invid) async {
    Database db = await database;
    return await db
        .delete("salesitems", where: 'salesinvoiceid = ?', whereArgs: [invid]);
  }

  Future<int> deleteallsalesInvoice() async {
    Database db = await database;
    return await db.delete(SalesInvoice.tblSalesInvoice);
  }

  Future<int> deleteallsalesItems() async {
    Database db = await database;
    return await db.delete(SalesItem.tblSalesItem);
  }

  //Settings
  Future<int> insertPosConfig(PosConfig posconfig) async {
    Database db = await database;
    return await db.insert(PosConfig.tblPosconfig, posconfig.toMap());
  }

  Future<List<PosConfig>> fetchPosConfigs() async {
    Database db = await database;
    List<Map> posconfigs = await db.query(PosConfig.tblPosconfig);
    return posconfigs.length == 0
        ? []
        : posconfigs.map((x) => PosConfig.fromMap(x)).toList();
  }

  Future<int> updatePosConfig(PosConfig posconfig) async {
    Database db = await database;
    return await db.update(PosConfig.tblPosconfig, posconfig.toMap(),
        where: '${PosConfig.colid}=?', whereArgs: [posconfig.id]);
  }

  Future<int> deletePosConfig(int id) async {
    Database db = await database;
    return await db.delete(PosConfig.tblPosconfig,
        where: '${PosConfig.colid}=?', whereArgs: [id]);
  }

  Future<List<PosConfig>> fetchPosConfigurl(String url) async {
    Database db = await database;
    List<Map> posconfigs = await db.query(PosConfig.tblPosconfig,
        where: '${PosConfig.colurl}=?', whereArgs: [url]);
    return posconfigs.length == 0
        ? []
        : posconfigs.map((x) => PosConfig.fromMap(x)).toList();
  }
}
