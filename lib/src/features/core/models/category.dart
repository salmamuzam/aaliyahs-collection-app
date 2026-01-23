// Stores the model for categories

class Category {
  final int? id;
  final String name;
  final String iconURL;

  Category({this.id, required this.name, required this.iconURL});

  factory Category.fromJson(Map<String, dynamic> json) {
    String url = json['image'] ?? json['icon_url'] ?? ''; // Try 'image' first, fallback to 'icon_url'
    // IP Translation
    url = url.replaceAll('localhost', '192.168.1.11');
    url = url.replaceAll('127.0.0.1', '192.168.1.11');
    url = url.replaceAll('10.0.2.2', '192.168.1.11');

    return Category(
      id: json['id'],
      name: json['name'] ?? '',
      iconURL: url,
    );
  }
}
