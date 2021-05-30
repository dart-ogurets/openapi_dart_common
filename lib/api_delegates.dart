part of dart_openapi;

class QueryParam {
  String name;
  String value;

  QueryParam(this.name, this.value);
}

class ApiResponse {
  Stream<List<int>>? body;
  Map<String, List<String>> headers;
  int statusCode;
  Exception? innerException;
  StackTrace? stackTrace;

  ApiResponse(this.statusCode, this.headers, this.body);
}

// extra api if x-dart-rich-operation: operationName is tagged in path
class RichApiResponse<T> {
  int statusCode;
  Map<String, List<String>> headers;
  T? data;

  RichApiResponse(this.statusCode, this.headers, [this.data]);
}

abstract class ApiClientDelegate {
  Future<ApiResponse> invokeAPI(String basePath, String path,
      Iterable<QueryParam> queryParams, Object? body, Options options,
      {bool passErrorsAsApiResponses = false});
}

// a function that will convert a parameter to a string, used by the
// local api client to pass in the reference to this helper function lib
typedef String ParameterToString(dynamic value);
