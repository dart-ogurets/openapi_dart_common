part of dart_openapi;

const _delimiters = {'csv': ',', 'ssv': ' ', 'tsv': '\t', 'pipes': '|'};

// port from Java version
Iterable<QueryParam> convertParametersForCollectionFormat(
    ParameterToString deserializeDelegate,
    String? collectionFormat,
    String? name,
    dynamic value) {
  var params = <QueryParam>[];

  // preconditions
  if (name == null || name.isEmpty || value == null) return params;

  if (value is! List) {
    params.add(QueryParam(name, deserializeDelegate(value)));
    return params;
  }

  List values = value;

  // get the collection format
  collectionFormat = (collectionFormat == null || collectionFormat.isEmpty)
      ? 'csv'
      : collectionFormat; // default: csv

  if (collectionFormat == 'multi') {
    return values.map((v) => QueryParam(name, deserializeDelegate(v)));
  }

  String delimiter = _delimiters[collectionFormat] ?? ',';

  params.add(QueryParam(
      name, values.map((v) => deserializeDelegate(v)).join(delimiter)));
  return params;
}

/// Returns the decoded body by utf-8 if application/json with the given headers.
/// Else, returns the decoded body by default algorithm of dart:http.
/// Because avoid to text garbling when header only contains 'application/json' without '; charset=utf-8'.
Future<String?> decodeBodyBytes(Stream<List<int>> body) async {
  try {
    return await utf8.decodeStream(body);
  } catch (e, s) {
    openapiLogger.warning("Cannot decode body", e, s);
    return null;
  }
}

/// Convert a DateTime to a string parameter. A {path} parameter requires encoding,
/// whereas a Query parameter doesn't. To ensure a non-breaking API, we use encode to default  true.
String openApiDateTimeParameterToString(dynamic value, [bool encode = true]) {
  if (encode) {
    return Uri.encodeComponent((value as DateTime).toUtc().toIso8601String());
  } else {
    return (value as DateTime).toUtc().toIso8601String();
  }
}

/// Convert a Date to a string parameter. A {path} parameter requires encoding,
/// whereas a Query parameter doesn't. To ensure a non-breaking API, we use encode to default  true.
String openApiDateParameterToString(dynamic value, [bool encode = true]) {
  if (encode) {
    return Uri.encodeComponent((value as DateTime).toDateString());
  } else {
    return (value as DateTime).toDateString();
  }
}

/// this exists because we otherwise need an extension method DateTime.fromJson and i don't want to clash with other libs
DateTime openApiDateTimeFromJson(dynamic json) {
  return DateTime.parse(json as String);
}

extension OpenApiDateTimeExtension on DateTime {
  String toDateString() {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}

extension DateTimeList on List<DateTime> {
  List<String?> toDateStringList() => map((e) => e.toDateString()).toList();
}

/// this is the same, but for a json object which is in fact a list of strings
List<DateTime> openApiDateTimeList(dynamic json) {
  List<String> dts = (json as List).cast<String>();

  return dts.map((s) => DateTime.parse(s)).toList();
}

final _regList = RegExp(r'^List<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

typedef Deserializer = dynamic Function(dynamic value, String targetType);

dynamic matchLeftovers(
    dynamic value, String targetType, Deserializer deserialize) {
  Match? match;

  if (value is List) {
    match = _regList.firstMatch(targetType);
    if (match != null) {
      final tt = match[1];

      if (tt != null) {
        return value.map((v) => deserialize(v, tt)).toList();
      }
    }
  }

  if (value is Map) {
    match = _regMap.firstMatch(targetType);
    if (match != null) {
      final tt = match[1];

      if (tt != null) {
        return Map.fromIterables(
            value.keys, value.values.map((v) => deserialize(v, tt)));
      }
    }
  }

  throw ApiException(
      500, 'Could not find a suitable class for deserialization');
}

extension ListFromNull<T> on List<T?> {
  List<T> fromNull() {
    List<T> vals = [];
    forEach((e) {
      if (e != null) {
        vals.add(e);
      }
    });
    return vals;
  }
}

extension MapFromNull<K, V> on Map<K, V> {
  Map<K, V> fromNull() {
    Map<K, V> vals = {};
    forEach((key, value) {
      if (key != null && value != null) {
        vals[key] = value;
      }
    });
    return vals;
  }
}
