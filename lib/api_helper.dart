part of dart_openapi;

const _delimiters = const {'csv': ',', 'ssv': ' ', 'tsv': '\t', 'pipes': '|'};

// port from Java version
Iterable<QueryParam> convertParametersForCollectionFormat(
    DeserializeDelegate deserializeDelegate,
    String collectionFormat,
    String name,
    dynamic value) {
  var params = <QueryParam>[];

  // preconditions
  if (name == null || name.isEmpty || value == null) return params;

  if (value is! List) {
    params.add(QueryParam(name, parameterToString(deserializeDelegate, value)));
    return params;
  }

  List values = value as List;

  // get the collection format
  collectionFormat = (collectionFormat == null || collectionFormat.isEmpty)
      ? "csv"
      : collectionFormat; // default: csv

  if (collectionFormat == "multi") {
    return values.map(
        (v) => QueryParam(name, parameterToString(deserializeDelegate, v)));
  }

  String delimiter = _delimiters[collectionFormat] ?? ",";

  params.add(QueryParam(
      name,
      values
          .map((v) => parameterToString(deserializeDelegate, v))
          .join(delimiter)));
  return params;
}

/// Format the given parameter object into string.
String parameterToString(
    DeserializeDelegate deserializeDelegate, dynamic value) {
  if (value == null) {
    return '';
  } else if (value is DateTime) {
    return value.toUtc().toIso8601String();
  }

  return deserializeDelegate.parameterToString(value) ?? value.toString();
}

/// Returns the decoded body by utf-8 if application/json with the given headers.
/// Else, returns the decoded body by default algorithm of dart:http.
/// Because avoid to text garbling when header only contains "application/json" without "; charset=utf-8".
Future<String> decodeBodyBytes(ApiResponse response) async {
//  var contentType = response.headers['content-type'];

//  if (contentType != null && contentType.first.contains("application/json")) {
  // there simply isn't anything else to use
  try {
    var val = await utf8.decodeStream(response.body);
    return val == '' ? null : val;
  } catch (e) {
    print(e.toString()); // for time being
    return null;
  }
//  } else {
//    return await response.body.transform(String.)
//  }
}

//extension DateTimeOpenapiExtension on DateTime {
//  DateTime fromJson(dynamic json) {
//
//  }
//}

// this exists because we otherwise need an extension method DateTime.fromJson and i don't want to clash with other libs
DateTime openApiDateTimeFromJson(dynamic json) {
  return DateTime.parse(json as String);
}

// this is the same, but for a json object which is in fact a list of strings
List<DateTime> openApiDateTimeList(dynamic json) {
  List<String> dts = (json as List).cast<String>();
  return dts.map((s) => DateTime.parse(s)).toList();
}

