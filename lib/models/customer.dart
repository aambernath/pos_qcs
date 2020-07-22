class Customer {
  static const tblCustomer = 'customers';
  static const colid = 'id';
  static const colname = 'name';
  static const colmobile = 'mobile';
  static const colcontactname = 'contactname';
  static const coltrn = 'trn';
  static const colterritory = 'territory';

  Customer(
      {this.id,
      this.name,
      this.mobile,
      this.contactname,
      this.trn,
      this.territory});

  int id;
  String name;
  String mobile;
  String contactname;
  String trn;
  String territory;

  Customer.fromMap(Map<String, dynamic> map) {
    id = map[colid];
    name = map[colname];
    mobile = map[colmobile];
    contactname = map[colcontactname];
    trn = map[coltrn];
    territory = map[colterritory];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colname: name,
      colmobile: mobile,
      colcontactname: contactname,
      coltrn: trn,
      colterritory: territory
    };
    if (id != null) map[colid] = id;
    return map;
  }
}
