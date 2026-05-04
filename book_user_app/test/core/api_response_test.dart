import 'package:book_user_app/core/network/api_exceptions.dart';
import 'package:book_user_app/core/network/api_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('throwIfApiFailure', () {
    test('does nothing for 2xx', () {
      expect(
        () => throwIfApiFailure(
          Response<dynamic>(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: const {'success': true},
          ),
        ),
        returnsNormally,
      );
    });

    test('throws ApiException with message for 403', () {
      expect(
        () => throwIfApiFailure(
          Response<dynamic>(
            requestOptions: RequestOptions(),
            statusCode: 403,
            data: const {'message': 'Forbidden'},
          ),
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Forbidden',
          ).having((e) => e.statusCode, 'statusCode', 403),
        ),
      );
    });
  });
}
