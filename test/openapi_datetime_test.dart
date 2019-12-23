

import 'package:openapi_dart_common/openapi.dart';
import 'package:test/test.dart';

void main() {
  test('We can parse a datetime from dynamic', () {
    final now = DateTime.now();
    dynamic json = now.toIso8601String();
    expect(openApiDateTimeFromJson(json), now);
  });

  test('We have a dynamic list of datetimes and it comes back as a properly typed list', () {
    final exact = [DateTime.now().add(Duration(seconds: 1)), DateTime.now().add(Duration(seconds: 1))];
    dynamic list = exact.map((dt) => dt.toIso8601String() as dynamic).toList() as dynamic;
    final decoded = openApiDateTimeList(list);
    expect(decoded, exact);
  });
}