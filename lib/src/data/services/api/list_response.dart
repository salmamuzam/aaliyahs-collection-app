class ListResponse<T> {
  final List<T> results;
  final Map<String, dynamic>? meta;

  ListResponse({
    required this.results,
    this.meta,
  });

  factory ListResponse.fromMap(Map<String, dynamic> json, T Function(Map<String, dynamic> json) fromJsonT) {
    var rawData = json['data'] ?? json;
    List<dynamic> items = [];
    
    if (rawData is List) {
       items = rawData;
    } else if (rawData is Map) {
       // Handle cases where data is keyed
       if (rawData['data'] is List) {
         items = rawData['data'];
       } else {
         items = rawData.values.whereType<Map<String, dynamic>>().toList();
       }
    }

    return ListResponse<T>(
      results: items.map((e) => fromJsonT(e as Map<String, dynamic>)).toList(),
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'ListResponse<$T>{results: ${results.length}, meta: $meta}';
  }
}
