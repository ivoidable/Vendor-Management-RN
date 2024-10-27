import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vendor/model/product.dart';
import 'package:vendor/model/user.dart';

class ViewVendorProfileScreen extends StatelessWidget {
  Vendor vendor;
  ViewVendorProfileScreen({required this.vendor});

  Widget buildProfileImage(Vendor user) {
    String? imageUrl;
    imageUrl = user.logoUrl;

    return CircleAvatar(
      radius: 50,
      backgroundImage: (imageUrl.isNotEmpty) ? NetworkImage(imageUrl) : null,
      child: (imageUrl.isEmpty) ? const Icon(Icons.person, size: 50) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(vendor.name),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 24,
            ),
            buildProfileImage(vendor),
            const SizedBox(
              height: 16,
            ),
            Text(
              "${vendor.businessName}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              "By ${vendor.name.split(' ')[0]}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            vendor.slogan != null
                ? Text(vendor.slogan!)
                : const SizedBox(
                    height: 4,
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(vendor.email),
                vendor.phoneNumber == null
                    ? const SizedBox(
                        height: 12,
                      )
                    : TextButton(
                        onPressed: () {
                          if (vendor.phoneNumber != null) {
                            launchUrl(Uri.parse("tel:${vendor.phoneNumber!}"));
                          }
                        },
                        child: Text(vendor.phoneNumber!),
                      ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Container(
              height: Get.height * 0.55,
              width: Get.width * 0.88,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(12),
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 4,
                ),
                itemBuilder: (context, index) {
                  return GridTile(
                    child: ProductWidget(
                      product: vendor.products[index],
                    ),
                  );
                },
                itemCount: vendor.products.length,
              ),
            ),
            //TODO: Add Catalog
          ],
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
