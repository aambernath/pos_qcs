class PosConfig {
  static const tblPosconfig = 'posconfigs';
  static const colid = 'id';
  static const colurl = 'url';
  static const colemail = 'email';
  static const colpassword = 'password';
  static const colwarehouse = 'warehouse';
  static const colcash = 'cash';
  static const colcurrentno = 'currentno';

  PosConfig(
      {this.url,
      this.email,
      this.password,
      this.warehouse,
      this.cash,
      this.currentno});

  int id;
  String url;
  String email;
  String password;
  String warehouse;
  String cash;
  int currentno;

  PosConfig.fromMap(Map<String, dynamic> map) {
    id = map[colid];
    url = map[colurl];
    email = map[colemail];
    password = map[colpassword];
    warehouse = map[colwarehouse];
    cash = map[colcash];
    currentno = map[colcurrentno];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colurl: url,
      colemail: email,
      colpassword: password,
      colwarehouse: warehouse,
      colcash: cash,
      colcurrentno: currentno
    };
    if (id != null) map[colid] = id;
    return map;
  }
}
