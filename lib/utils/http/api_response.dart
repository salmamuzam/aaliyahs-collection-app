class ApiResponse<T> {
  final T? data;
  final String? statusCode;
  final bool success;
  final String? statusMessage;

  ApiResponse({
    this.data,
    this.statusCode,
    this.success = true,
    this.statusMessage,
  });

  @override
  String toString() {
    return 'ApiResponse<$T>{data: $data, statusCode: $statusCode, success: $success, statusMessage: $statusMessage}';
  }

  factory ApiResponse.fromError(String message, String statusCode) {
    return ApiResponse(
      success: false,
      statusCode: statusCode,
      statusMessage: message,
    );
  }
}
