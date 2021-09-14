import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:json_table/json_table.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../login_screen.dart';
import '../product.dart';
import 'add_product.dart';

class AdminHome extends StatefulWidget {
  AdminHome({this.uid});
  final String? uid;
  @override
  _CustomDataTableState createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<AdminHome> {
  bool toggle = true;
  Product _selectedProduct =
      new Product(category: '', productName: '', price: '', barcode: '');
  List<JsonTableColumn>? columns;
  @override
  void initState() {
    super.initState();
    columns = [
      JsonTableColumn("productName", label: "ProductName"),
      JsonTableColumn("category", label: "Category"),
      JsonTableColumn("price", label: "Price"),
      JsonTableColumn("barcode", label: "Barcode"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Future<QuerySnapshot> _productsStream =
        FirebaseFirestore.instance.collection('products').get();
    print(json);
    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
        actions: <Widget>[
          IconButton(
            alignment: Alignment.center,
            icon: Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Remove Product"),
                      content:
                          Text('Do you want to remove this selected product?'),
                      actions: [
                        TextButton(
                          child: Text("Ok"),
                          onPressed: () {
                            _removeProduct();
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () {
              FirebaseAuth auth = FirebaseAuth.instance;
              auth.signOut().then((res) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false);
              });
            },
          )
        ],
      ),
      body: FutureBuilder<QuerySnapshot>(
          future: _productsStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            List<Map<String, dynamic>> temps = [];
            snapshot.data!.docs.forEach((element) {
              Map<String, dynamic> string_data =
                  element.data() as Map<String, dynamic>;
              temps.add(string_data);
            });

            if (temps.isEmpty) {
              return Center(child: Text('There is no product'));
            }

            var json = jsonDecode(jsonEncode(temps));
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: JsonTable(
                json,
                columns: columns,
                allowRowHighlight: true,
                rowHighlightColor: Colors.yellow[500]!.withOpacity(0.7),
                paginationRowCount: 20,
                onRowSelect: (index, map) {
                  _selectedProduct = Product.fromJson(map);
                },
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => AddProduct()),
                (Route<dynamic> route) => false);
          },
          child: Icon(Icons.add, color: Colors.white)),
    );
  }

  _removeProduct() async {
    var collection = FirebaseFirestore.instance.collection('products');
    var snapshot = await collection
        .where('productName', isEqualTo: _selectedProduct.productName)
        .get();
    await snapshot.docs.first.reference.delete();
    this.setState(() {
      _selectedProduct =
          new Product(category: '', productName: '', price: '', barcode: '');
    });
  }
}
