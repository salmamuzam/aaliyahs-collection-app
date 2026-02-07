// Stores the model for categories
import 'package:aaliyahs_collection_estore/utils/constants/api_strings.dart';
import 'package:aaliyahs_collection_estore/utils/formatters/text_formatter.dart';

class CategoryModel {
  final int? id;
  final String name;
  final String iconURL;

  CategoryModel({this.id, required this.name, required this.iconURL});
  
  String get displayName => TFormatter.toSentenceCase(name);

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // Extensive fallback for image fields
    String url = json['image'] ?? 
                 json['icon_url'] ?? 
                 json['CategoryModel_image'] ?? 
                 json['image_url'] ?? 
                 json['icon'] ?? 
                 ''; 
    
    // Process URL to handle relative paths and localhost issues
    url = _processImageUrl(url);

    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      iconURL: url,
    );
  }

  static String _processImageUrl(String url) {
    if (url.isEmpty) return '';
    
    // 1. Handle Local Assets (Requirement 3)
    if (url.startsWith('assets/')) {
        return url;
    }

    // 2. Handle complete URLs pointing to localhost/emulator IPs
    if (url.startsWith('http')) {
        if (url.contains('localhost') || url.contains('127.0.0.1') || url.contains('10.0.2.2')) {
           final Uri uri = Uri.parse(url);
           return '$rootBaseURL${uri.path}';
        }
        return url;
    }

    // 3. Handle relative paths (e.g. /storage/... or storage/...)
    if (url.startsWith('/')) {
        return '$rootBaseURL$url';
    } else {
        // Prepend slash if missing
        return '$rootBaseURL/$url';
    }
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': iconURL,
    };
  }
}
