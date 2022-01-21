import 'package:flutter_test/flutter_test.dart';

import 'package:http_client/http_client.dart';

Future callBeforeSetTokenSchema() async {
  final client = HttpClient();
  try {
    await client.onFetch(
        auth: true,
        builder: (http, header) => http.get(Uri.parse('https://google.com')));
    fail('Exception not thrown');
  } catch (e) {
    expect(e, isInstanceOf<ArgumentError>());
  }
}

void main() {
  test('required auth header without set tokenSchema.', () async {
    await callBeforeSetTokenSchema();
  });
}
