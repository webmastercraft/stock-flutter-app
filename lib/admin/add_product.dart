import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../login_screen.dart';
import 'admin_home.dart';

class AddProduct extends StatelessWidget {
  final _productnameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add Product"),
          actions: <Widget>[
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
                      MaterialPageRoute(
                          builder: (context) => AdminHome(uid: "123")),
                      (Route<dynamic> route) => false);
                });
              },
            )
          ],
        ),
        body: Column(
          children: [
            Row(
              children: <Widget>[
                Expanded(
                  flex: 2, // 20%
                  child: Container(),
                ),
                Expanded(
                    flex: 6, // 60%
                    child: Container(
                        child: Column(
                      children: <Widget>[
                        FormBuilder(
                          key: _formKey,
                          // enabled: false,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(children: <Widget>[
                            FormBuilderTextField(
                              controller: _productnameController,
                              name: 'productname',
                              decoration:
                                  InputDecoration(labelText: 'ProductName'),
                              // valueTransformer: (text) => num.tryParse(text),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(context),
                                FormBuilderValidators.max(context, 70),
                              ]),
                              keyboardType: TextInputType.text,
                            ),
                            FormBuilderTextField(
                              controller: _categoryController,
                              name: 'category',
                              decoration:
                                  InputDecoration(labelText: 'Category'),
                              // valueTransformer: (text) => num.tryParse(text),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(context),
                                FormBuilderValidators.max(context, 70),
                              ]),
                              keyboardType: TextInputType.text,
                            ),
                            FormBuilderTextField(
                              controller: _priceController,
                              name: 'price',
                              decoration: InputDecoration(labelText: 'Price'),
                              // valueTransformer: (text) => num.tryParse(text),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(context),
                                FormBuilderValidators.max(context, 70),
                              ]),
                              keyboardType: TextInputType.text,
                            ),
                            FormBuilderTextField(
                                controller: _barcodeController,
                                name: 'barcode',
                                decoration:
                                    InputDecoration(labelText: 'Barcode'),
                                // valueTransformer: (text) => num.tryParse(text),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(context),
                                  FormBuilderValidators.numeric(context)
                                ]),
                                keyboardType: TextInputType.number),
                          ]),
                        )
                      ],
                    ))),
                Expanded(
                  flex: 2, // 20%
                  child: Container(),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: MaterialButton(
                      color: Colors.red,
                      onPressed: () {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          print(_formKey.currentState?.value);
                        } else {
                          print(_formKey.currentState?.value);
                          print('validation failed');
                          return;
                        }
                        _addProduct(context);
                      },
                      child: const Text(
                        'Add',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: MaterialButton(
                      color: Colors.red,
                      onPressed: () {
                        FirebaseAuth auth = FirebaseAuth.instance;
                        auth.signOut().then((res) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdminHome(uid: "123")),
                              (Route<dynamic> route) => false);
                        });
                      },
                      // color: Theme.of(context).colorScheme.secondary,
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  void _addProduct(BuildContext context) {
    String productname = _productnameController.text;
    String category = _categoryController.text;
    String price = _priceController.text;
    String barcode = _barcodeController.text;
    CollectionReference users =
        FirebaseFirestore.instance.collection('products');

    // Call the user's CollectionReference to add a new user
    users.add({
      'productName': productname, // John Doe
      'category': category, // Stokes and Sons
      'price': price, // 42
      'barcode': barcode // 42
    }).then((value) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Add Product"),
              content: Text('Product Added'),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdminHome(uid: "123")),
                        (Route<dynamic> route) => false);
                  },
                )
              ],
            );
          });
    }).catchError((error) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Add Product"),
              content: Text("Failed to add user: $error"),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });

    print('add attempt: $productname with $category');
  }
}
