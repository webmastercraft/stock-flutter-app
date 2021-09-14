import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

import '../login_screen.dart';

// ignore: must_be_immutable
class ScanMainScreen extends StatelessWidget {
  const ScanMainScreen({Key? key, required this.barcode}) : super(key: key);
  final String barcode;
  static final sampleDataArr = [
    {
      "category": "BEVERAGE",
      "product_name": "Cadbury Drink Choc 250 g",
      "price": "€1.85",
      "number": "5034660021537"
    },
    {
      "category": "BEVERAGE",
      "product_name": "Cadbury Drink Choc 2kg",
      "price": "€15.39",
      "number": "5034660022190"
    },
    {
      "category": "BEVERAGE",
      "product_name": "Nescafe Coffee Powder 500g",
      "price": "€10.35",
      "number": "7613035302907"
    },
    {
      "category": "BREAD",
      "product_name": "Breadcrumbs 1 kg ",
      "price": "€1.75",
      "number": "000702"
    }
  ];
  Future<void> scanBarcodeNormal(BuildContext context) async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ScanMainScreen(barcode: barcodeScanRes),
      ));
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/logo3x.png",
                  width: 40,
                  height: 40,
                )
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {},
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
            ]),
        body: MainWidget(barcode_string: barcode));
  }

  String getCurrentDate() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(now);
    return formatted;
  }

  int getProductIndex(String barcode) {
    FirebaseFirestore.instance
        .collection('products')
        .where('barcode', isEqualTo: barcode)
        .get()
        .then((value) {
      print('aaa');
      return 1;
    }).catchError((error) {
      return -1;
    });
    return -1;
  }
}

class MainWidget extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final String barcode_string;
  // ignore: non_constant_identifier_names
  MainWidget({required this.barcode_string});
  Future<void> scanBarcodeNormal(BuildContext context) async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ScanMainScreen(barcode: barcodeScanRes),
      ));
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
  }

  @override
  Widget build(BuildContext context) {
    final Future<QuerySnapshot> _productsStream = FirebaseFirestore.instance
        .collection('products')
        .where('barcode', isEqualTo: barcode_string)
        .get();
    return Container(
        child: FutureBuilder(
            future: _productsStream,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Something went wrong'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.docs.length != 0) {
                DocumentSnapshot data = snapshot.data!.docs[0];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Text(
                        data.get('productName'),
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Text(
                        data.get('category'),
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Text(
                        "€" + data.get('price'),
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Text(
                        data.get('barcode'),
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Text("Qty/count",
                          style: TextStyle(color: Colors.black, fontSize: 20)),
                    ),
                    SpinBox(
                      min: 1,
                      max: 10000,
                      value: 0,
                      textStyle: TextStyle(color: Colors.black, fontSize: 20),
                      onChanged: (value) => print(value),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Text('Prev Item'),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text('Next Item'),
                          ),
                        ))
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        onPressed: () => scanBarcodeNormal(context),
                        child: Text('Scan/Continue Scan'),
                      ),
                    )
                  ],
                );
              }
              return Center(
                child: Column(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Text(
                      'There is no match product.$barcode_string',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Expanded(
                      child: Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () => scanBarcodeNormal(context),
                            child: Text(
                              'Rescan',
                              style: new TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(50)),
                          )))
                ]),
              );
              // here your snapshot data is null so SharedPreferences has no data...
            } //end switch
            ));
  }
}
