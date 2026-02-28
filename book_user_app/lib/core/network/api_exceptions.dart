import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() =>
      'ApiException(message: $message, statusCode: $statusCode)';
}

/// Helper function to parse error messages from backend
/// Handles both String and List<dynamic> message formats
String _parseErrorMessage(dynamic message) {
  if (message == null) {
    return 'An error occurred';
  }

  if (message is String) {
    return message;
  }

  if (message is List) {
    // Join multiple error messages
    return message.map((e) => e.toString()).join('\n');
  }

  return message.toString();
}

ApiException handleDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.cancel:
      return ApiException(message: "Request cancelled");
    case DioExceptionType.connectionTimeout:
      return ApiException(message: "Connection timeout");
    case DioExceptionType.sendTimeout:
      return ApiException(message: "Send timeout");
    case DioExceptionType.receiveTimeout:
      return ApiException(message: "Receive timeout");
    case DioExceptionType.badResponse:
      return ApiException(
        message: _parseErrorMessage(e.response?.data['message']),
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    case DioExceptionType.connectionError:
      return ApiException(message: "No internet connection");
    default:
      return ApiException(message: "Something went wrong");
  }
}
