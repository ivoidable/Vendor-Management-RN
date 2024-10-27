class Product {
  String vendorId;
  String productName;
  List<String> images;
  double price;
  int stock;

  Product({
    required this.vendorId,
    required this.productName,
    required this.images,
    required this.stock,
    required this.price,
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      vendorId: data['vendor_id'],
      productName: data['product_name'],
      price: data['price'],
      stock: data['stock'],
      images: List<String>.from(data['images'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vendor_id': vendorId,
      'product_name': productName,
      'price': price,
      'stock': stock,
      'images': images.toList(),
    };
  }
}
