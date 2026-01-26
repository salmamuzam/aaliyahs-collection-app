// ignore_for_file: avoid_print
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  var url = Uri.parse('https://aaliyahs-collection-ecom.up.railway.app/api/v1/home');
  var response = await http.get(url, headers: {'Accept': 'application/json'});
  print('Status: ${response.statusCode}');
  if (response.statusCode == 200) {
    var json = jsonDecode(response.body);
    if (json['data'] is Map) {
      print('Keys: ${json['data'].keys}');
    }
  } else {
    print('Body: ${response.body}');
  }
}
