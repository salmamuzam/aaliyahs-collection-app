import 'package:flutter_test/flutter_test.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';

void main() {
  group('ProductModel Robustness Tests', () {
    test('Should parse valid JSON correctly', () {
      final json = {
        'id': 1,
        'name': 'Test Abaya',
        'description': 'A beautiful test abaya',
        'price': '150.00',
        'image': 'assets/test.png',
        'CategoryModel': 'Abayas',
        'images': ['img1.png', 'img2.png'],
      };

      final product = ProductModel.fromJson(json);

      expect(product.id, 1);
      expect(product.name, 'Test Abaya');
      expect(product.priceDouble, 150.0);
      expect(product.image, 'assets/test.png');
      expect(product.categoryName, 'Abayas');
    });

    test('Should handle missing image list gracefully', () {
      final json = {
        'id': 2,
        'name': 'Minimal Abaya',
        'description': 'No extra images here',
        'price': '100.00',
        'image': 'assets/main.png',
        'CategoryModel': 'Abayas',
      };

      final product = ProductModel.fromJson(json);

      expect(product.images, isEmpty);
      expect(product.image, 'assets/main.png');
    });

    test('Should handle numeric price values in JSON (robust parsing)', () {
       final json = {
        'id': 3,
        'name': 'Numeric Price Item',
        'description': 'Price is a number, not string',
        'price': 199.99,
        'image': 'assets/main.png',
        'CategoryModel': 'Abayas',
      };

      final product = ProductModel.fromJson(json);
      expect(product.priceDouble, 199.99);
    });

    test('Equality should be based on ID', () {
      final p1 = ProductModel(id: 1, name: 'A', description: '', price: '10', images: [], categoryId: 1, categoryName: '');
      final p2 = ProductModel(id: 1, name: 'B', description: '', price: '20', images: [], categoryId: 1, categoryName: '');
      final p3 = ProductModel(id: 2, name: 'A', description: '', price: '10', images: [], categoryId: 1, categoryName: '');

      expect(p1 == p2, isTrue);
      expect(p1 == p3, isFalse);
    });
  });
}
