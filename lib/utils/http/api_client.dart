import 'api_response.dart';
import 'http_method.dart';

abstract class ApiClient {
  Future<ApiResponse<T>> request<T>({
    required String path,
    required MethodType method,
    dynamic payload,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic> json)? fromJson,
  });

  void setToken(String token);
  void removeToken();
}
