import 'package:flutter/foundation.dart';

@immutable
class Product {
  Product(
      {required this.category,
      required this.productName,
      required this.price,
      required this.barcode});

  Product.fromJson(Map<String, Object?> json)
      : this(
            category: json['category']! as String,
            productName: json['productName']! as String,
            price: json['price']! as String,
            barcode: json['barcode']! as String);

  final String category;
  final String price;
  final String productName;
  final String barcode;

  Map<String, Object?> toJson() {
    return {
      'category': category,
      'productName': productName,
      'price': price,
      'barcode': barcode
    };
  }
}
