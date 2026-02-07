import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';
import 'api_response.dart';
import 'http_method.dart';

class DioClient implements ApiClient {
  static final DioClient _instance = DioClient._internal();
  late Dio _client;
  static String? _baseUrl;

  factory DioClient({String? baseUrl}) {
    if (baseUrl != null) _baseUrl = baseUrl;
    return _instance;
  }

  DioClient._internal() {
    _client = Dio(
      BaseOptions(
        baseUrl: _baseUrl ?? '',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (kDebugMode) {
      _client.interceptors.add(LogInterceptor(
        request: false,
        requestHeader: false,
        responseHeader: false,
        logPrint: (obj) => debugPrint('🌐 DIO: $obj'),
      ));
    }
  }

  @override
  void removeToken() {
    _client.options.headers.remove('Authorization');
  }

  @override
  void setToken(String token) {
    _client.options.headers['Authorization'] = 'Bearer $token';
  }

  @override
  Future<ApiResponse<T>> request<T>({
    required String path,
    required MethodType method,
    dynamic payload,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    try {
      Response response;
      switch (method) {
        case MethodType.get:
          response = await _client.get(path, queryParameters: queryParameters);
          break;
        case MethodType.post:
          response = await _client.post(path, data: payload, queryParameters: queryParameters);
          break;
        case MethodType.put:
          response = await _client.put(path, data: payload, queryParameters: queryParameters);
          break;
        case MethodType.delete:
          response = await _client.delete(path, data: payload, queryParameters: queryParameters);
          break;
        case MethodType.patch:
          response = await _client.patch(path, data: payload, queryParameters: queryParameters);
          break;
      }

      final int statusCode = response.statusCode ?? 500;
      final bool isSuccess = statusCode >= 200 && statusCode < 300;

      // Parse data if available
      T? parsedData;
      if (response.data != null) {
        if (fromJson != null) {
          parsedData = fromJson(response.data is Map ? response.data : {'data': response.data});
        } else if (response.data is T) {
          parsedData = response.data;
        } else {
          try {
            parsedData = response.data as T;
          } catch (_) {}
        }
      }

      return ApiResponse<T>(
        data: parsedData,
        statusCode: statusCode.toString(),
        success: isSuccess,
        statusMessage: (response.data is Map) ? response.data['message'] : response.statusMessage,
      );
    } on DioException catch (e) {
      String message = 'An error occurred';
      if (e.response?.data != null && e.response?.data is Map) {
        message = e.response?.data['message'] ?? e.message;
      } else {
        message = e.message ?? 'Connection error';
      }
      return ApiResponse<T>.fromError(
        message,
        (e.response?.statusCode ?? 500).toString(),
      );
    } catch (e) {
      return ApiResponse<T>.fromError(e.toString(), '500');
    }
  }
}
