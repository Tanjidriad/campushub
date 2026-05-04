import 'package:dio/dio.dart';
import 'package:book_user_app/core/network/api_exceptions.dart';

/// Throws [ApiException] when [Response.statusCode] is outside 2xx.
void throwIfApiFailure(Response<dynamic> response) {
  final code = response.statusCode ?? 0;
  if (code >= 200 && code < 300) return;

  final raw = response.data;
  var message = 'Request failed';
  if (raw is Map) {
    final m = raw['message'];
    if (m is String) {
      message = m;
    } else if (m is List) {
      message = m.map((e) => e.toString()).join('\n');
    }
  }

  throw ApiException(message: message, statusCode: code, data: raw);
}
