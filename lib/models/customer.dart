class Customer {
  static const tblCustomer = 'customers';
  static const colid = 'id';
  static const colname = 'name';
  static const colmobile = 'mobile';
  static const colcontactname = 'contactname';
  static const coltrn = 'trn';
  static const colterritory = 'territory';
  static const colpricelist = 'pricelist';
  static const collocalcust = 'localcust';

  Customer(
      {this.id,
      this.name,
      this.mobile,
      this.contactname,
      this.trn,
      this.territory,
      this.pricelist,
      this.localcust});

  int id;
  String name;
  String mobile;
  String contactname;
  String trn;
  String territory;
  String pricelist;
  int localcust;

  Customer.fromMap(Map<String, dynamic> map) {
    id = map[colid];
    name = map[colname];
    mobile = map[colmobile];
    contactname = map[colcontactname];
    trn = map[coltrn];
    territory = map[colterritory];
    pricelist = map[colpricelist];
    localcust = map[collocalcust];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colname: name,
      colmobile: mobile,
      colcontactname: contactname,
      coltrn: trn,
      colterritory: territory,
      colpricelist: pricelist,
      collocalcust: localcust
    };
    if (id != null) map[colid] = id;
    return map;
  }
}
