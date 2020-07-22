class Item {
  static const tblItem = 'items';
  static const colid = 'id';
  static const colitemname = 'itemname';
  static const colqty = 'qty';
  static const colrate = 'rate';

  Item({this.id, this.itemname, this.qty, this.rate});

  int id;
  String itemname;
  String qty;
  String rate;

  Item.fromMap(Map<String, dynamic> map) {
    id = map[colid];
    itemname = map[colitemname];
    qty = map[colqty];
    rate = map[colrate];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colitemname: itemname,
      colqty: qty,
      colrate: rate,
    };
    if (id != null) map[colid] = id;
    return map;
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        id: json['id'] as int,
        itemname: json['itemname'] as String,
        qty: json['qty'] as String,
        rate: json['rate'] as String);
  }
}
