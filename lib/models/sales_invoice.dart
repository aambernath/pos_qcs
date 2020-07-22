class SalesInvoice {
  static const tblSalesInvoice = 'salesinvoices';
  static const colid = 'id';
  static const colcustomer = 'customer';
  static const colpostingdate = 'postingdate';
  static const colnet = 'net';
  static const colvat = 'vat';
  static const colgrandtotal = 'grandtotal';
  static const colpaidamount = 'paidamount';
  static const colchangeamount = 'changeamount';
  static const coloutstandingamount = 'outstandingamount';

  SalesInvoice(
      {this.id,
      this.customer,
      this.postingdate,
      this.net,
      this.vat,
      this.grandtotal,
      this.paidamount,
      this.changeamount,
      this.outstandingamount});

  int id;
  String customer;
  String postingdate;
  String net;
  String vat;
  String grandtotal;
  String paidamount;
  String changeamount;
  String outstandingamount;

  SalesInvoice.fromMap(Map<String, dynamic> map) {
    id = map[colid];
    customer = map[colcustomer];
    postingdate = map[colpostingdate];
    vat = map[colvat];
    grandtotal = map[colgrandtotal];
    paidamount = map[colpaidamount];
    changeamount = map[colchangeamount];
    outstandingamount = map[coloutstandingamount];
    net = map[colnet];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colcustomer: customer,
      colpostingdate: postingdate,
      colnet: net,
      colvat: vat,
      colgrandtotal: grandtotal,
      colpaidamount: paidamount,
      colchangeamount: changeamount,
      coloutstandingamount: outstandingamount
    };
    if (id != null) map[colid] = id;
    return map;
  }
}
