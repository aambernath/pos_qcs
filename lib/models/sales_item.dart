class SalesItem {
  static const tblSalesItem = 'salesitems';
  static const colid = 'id';
  static const colitemname = 'itemname';
  static const colqty = 'qty';
  static const colrate = 'rate';
  static const colamount = 'amount';
  static const colsalesinvoiceid = 'salesinvoiceid';

  SalesItem(
      {this.id,
      this.itemname,
      this.qty,
      this.rate,
      this.amount,
      this.salesinvoiceid});

  int id;
  String itemname;
  String qty;
  String rate;
  String amount;
  int salesinvoiceid;

  SalesItem.fromMap(Map<String, dynamic> map) {
    id = map[colid];
    itemname = map[colitemname];
    qty = map[colqty];
    rate = map[colrate];
    amount = map[colamount];
    salesinvoiceid = map[colsalesinvoiceid];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colitemname: itemname,
      colqty: qty,
      colrate: rate,
      colamount: amount,
      colsalesinvoiceid: salesinvoiceid
    };
    if (id != null) map[colid] = id;
    return map;
  }
}
