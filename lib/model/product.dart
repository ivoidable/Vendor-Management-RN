class Product {
  String id;
  String vendorId;
  String productName;
  List<String> images;
  double price;
  int stock;
  String? productDescription;

  Product({
    required this.id,
    required this.vendorId,
    required this.productDescription,
    required this.productName,
    required this.images,
    required this.stock,
    required this.price,
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id'],
      vendorId: data['vendor_id'],
      productName: data['product_name'],
      productDescription: data['product_description'],
      price: data['price'],
      stock: data['stock'],
      images: data['images'] as List<String>,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'product_name': productName,
      'product_description': productDescription,
      'price': price,
      'stock': stock,
      'images': images.toList(),
    };
  }
}
