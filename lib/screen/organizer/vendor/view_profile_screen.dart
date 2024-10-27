import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vendor/model/product.dart';
import 'package:vendor/model/user.dart';

class ViewVendorProfileScreen extends StatelessWidget {
  Vendor vendor;
  ViewVendorProfileScreen({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              //TODO: Add Vendor Logo & Format
              Text("${vendor.businessName} By ${vendor.name.split(' ')[0]}"),
              Text(vendor.slogan ?? ""),
              Text(vendor.email),
              TextButton(
                onPressed: () {
                  if (vendor.phoneNumber != null) {
                    launchUrl(Uri.parse("tel:${vendor.phoneNumber!}"));
                  }
                },
                child: Text(vendor.phoneNumber!),
              ),
              SizedBox(
                height: 24,
              ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 4),
                itemBuilder: (context, index) {
                  return GridTile(
                    child: ProductWidget(
                      product: vendor.products[index],
                    ),
                  );
                },
                itemCount: vendor.products.length,
              ),
              //TODO: Add Catalog
            ],
          ),
        ),
      ),
    );
  }
}

class ProductWidget extends StatelessWidget {
  final Product product;
  const ProductWidget({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Column(
        children: [
          //Image will be changed to carousel
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Image.network(product.images.first),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Text(product.productName),
                Text("${product.price} SAR"),
              ],
            ),
          ),
          Text("${product.stock} Left"),
        ],
      ),
    );
  }
}
