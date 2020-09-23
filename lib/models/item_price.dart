class ItemPrice {
  static const tblItemPrice = 'itemprices';
  static const colid = 'id';
  static const colitemname = 'itemname';
  static const colpricelist = 'pricelist';
  static const colrate = 'rate';

  ItemPrice({this.id, this.itemname, this.pricelist, this.rate});

  int id;
  String itemname;
  String pricelist;
  String rate;

  ItemPrice.fromMap(Map<String, dynamic> map) {
    id = map[colid];
    itemname = map[colitemname];
    pricelist = map[colpricelist];
    rate = map[colrate];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colitemname: itemname,
      colpricelist: pricelist,
      colrate: rate,
    };
    if (id != null) map[colid] = id;
    return map;
  }

  factory ItemPrice.fromJson(Map<String, dynamic> json) {
    return ItemPrice(
        id: json['id'] as int,
        itemname: json['itemname'] as String,
        pricelist: json['pricelist'] as String,
        rate: json['rate'] as String);
  }
}
