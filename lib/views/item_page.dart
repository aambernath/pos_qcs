import 'package:flutter/material.dart';
import 'package:pos_qcs/models/item.dart';
import 'package:pos_qcs/utils/database_helper.dart';

class itemlist extends StatefulWidget {
  itemlist({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _itemlistState createState() => _itemlistState();
}

class _itemlistState extends State<itemlist> {
  final _formKey = GlobalKey<FormState>();
  Item _item = Item();
  DatabaseHelper _dbHelper;
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper.instance;
    _refreshItemList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Item List"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[_form(), _list()],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _form() => Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Item Name'),
              onSaved: (val) => setState(() => _item.itemname = val),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Qty'),
              onSaved: (val) => setState(() => _item.qty = val),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Rate'),
              onSaved: (val) => setState(() => _item.rate = val),
            ),
            Container(
              margin: EdgeInsets.all(10.0),
              child: RaisedButton(
                onPressed: () => _onSave(),
                child: Text('Save'),
                color: Colors.green,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ));

  _refreshItemList() async {
    List<Item> x = await _dbHelper.fetchItems();
    setState(() {
      _items = x;
    });
    print(x);
  }

  _onSave() async {
    var form = _formKey.currentState;
    form.save();
    await _dbHelper.insertItem(_item);
    _refreshItemList();
    form.reset();
  }

  _list() => Expanded(
        child: Card(
          margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: ListView.builder(
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.free_breakfast,
                        color: Colors.deepPurple, size: 40.0),
                    title: Text(
                      _items[index].itemname.toUpperCase(),
                      style: TextStyle(
                          color: Colors.lime, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(
                    height: 5.0,
                  )
                ],
              );
            },
            itemCount: _items.length,
          ),
        ),
      );
}
