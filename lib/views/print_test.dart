import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'dart:typed_data';

class printtest extends StatefulWidget {
  printtest({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object ( below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _printtestState createState() => _printtestState();
}

class _printtestState extends State<printtest> {
  String generatedPdfFilePath;
  var generatedPdfFile;

  @override
  void initState() {
    super.initState();
    generateExampleDocument();
  }

  Future<void> generateExampleDocument() async {
    var html1 = """<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>A simple, clean, and responsive HTML invoice template</title>
    
    <style>
    .invoice-box {
        max-width: 800px;
        margin: auto;
        padding: 30px;
        border: 1px solid #eee;
        box-shadow: 0 0 10px rgba(0, 0, 0, .15);
        font-size: 29px;
        line-height: 24px;
        font-family: 'Helvetica Neue', 'Helvetica', Helvetica, Arial, sans-serif;
        color: #555;
    }
    
    .invoice-box table {
        width: 100%;
        line-height: inherit;
        text-align: left;
    }
    
    .invoice-box table td {
        padding: 5px;
        vertical-align: top;
    }
    
    .invoice-box table tr td:nth-child(2) {
        text-align: right;
    }

    .invoice-box table tr td:nth-child(4) {
        text-align: right;
    }
    .invoice-box table tr td:nth-child(3) {
        text-align: right;
    }


    
    .invoice-box table tr.top table td {
        padding-bottom: 20px;
    }
    
    .invoice-box table tr.top table td.title {
        font-size: 45px;
        line-height: 45px;
        color: #333;
    }
    
    .invoice-box table tr.information table td {
        padding-bottom: 40px;
    }
    
    .invoice-box table tr.heading td {
        background: #eee;
        border-bottom: 1px solid #ddd;
        font-weight: bold;
    }
    
    .invoice-box table tr.details td {
        padding-bottom: 20px;
    }
    
    .invoice-box table tr.item td{
        border-bottom: 1px solid #eee;
    }
    
    .invoice-box table tr.item.last td {
        border-bottom: none;
    }
    
    .invoice-box table tr.total td:nth-child(2) {
        border-top: 2px solid #eee;
        font-weight: bold;
    }
    
    @media only screen and (max-width: 600px) {
        .invoice-box table tr.top table td {
            width: 100%;
            display: block;
            text-align: center;
        }
        
        .invoice-box table tr.information table td {
            width: 100%;
            display: block;
            text-align: center;
        }
    }
    
    /** RTL **/
    .rtl {
        direction: rtl;
        font-family: Tahoma, 'Helvetica Neue', 'Helvetica', Helvetica, Arial, sans-serif;
    }
    
    .rtl table {
        text-align: right;
    }
    
    .rtl table tr td:nth-child(2) {
        text-align: left;
    }
    </style>
</head>

<body>
    <div class="invoice-box">
        <table cellpadding="0" cellspacing="0">
            <tr class="top">
                <td colspan="4">
                    <table>
                        <tr>
                            <td class="title">
                                Beirut Automatic Bakery
                            </td>
                            
                            <td>
                                Invoice #: 123<br>
                                Created: January 1, 2015<br>
                                Due: February 1, 2015
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            
            <tr class="information">
                <td colspan="2">
                    <table>
                        <tr>
                            <td>
                                Sparksuite, Inc.<br>
                                12345 Sunny Road<br>
                                Sunnyville, CA 12345
                            </td>
                            
                            <td>
                                Acme Corp.<br>
                                John Doe<br>
                                john@example.com
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            
            <tr class="heading">
                <td>
                    Payment Method
                </td>
                
                <td>
                    Check #
                </td>
            </tr>
            
            <tr class="details">
                <td>
                    Check
                </td>
                
                <td>
                    1000
                </td>
            </tr>
            
            <tr class="heading">
                <td>
                    Item
                </td>
                
                <td>
                    Price
                </td>
            </tr>""";

    var html2 = """<tr class="item">
                <td>
                    Website design
                </td>
                
                <td>
                    300.00
                </td>
            </tr>
            
            <tr class="item">
                <td>
                    Hosting (3 months)
                </td>
                
                <td>
                    75.00
                </td>
            </tr>
            
            <tr class="item last">
                <td>
                    Domain name (1 year)
                </td>
                
                <td>
                    10.00
                </td>
            </tr>
            
            <tr class="total">
                <td></td>
                
                <td>
                   Total: 385.00
                </td>
            </tr>
        </table>
    </div>
</body>
</html> """;
    var htmlContent = html1 + html2;

    Directory appDocDir = await getApplicationDocumentsDirectory();
    var targetPath = '/storage/emulated/0/posinvoice/';
    var targetFileName = "testnew";
    print(targetPath);

    var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
        htmlContent, targetPath, targetFileName);
    generatedPdfFilePath = generatedPdfFile.path;
    print(generatedPdfFilePath);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(),
      body: Center(
        child: RaisedButton(
          child: Text("Open Generated PDF Preview"),
          onPressed: () => _share_pdf(generatedPdfFilePath),
        ),
      ),
    ));
  }

  _share_pdf(generatedPdfFile) async {
    final ByteData bytes =
        await rootBundle.load('/storage/emulated/0/Download/testnew.pdf');
    await Share.file(
      'PDF Document',
      'project.pdf',
      bytes.buffer.asUint8List(),
      '*/*',
    );
  }
}
