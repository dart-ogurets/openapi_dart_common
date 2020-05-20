part of dart_openapi;

class QueryParam {
  String name;
  String value;

  QueryParam(this.name, this.value);
}

class ApiResponse {
  Stream<List<int>> body;
  Map<String, List<String>> headers;
  int statusCode;
}

abstract class ApiClientDelegate {
  Future<ApiResponse> invokeAPI(String basePath, String path,
      Iterable<QueryParam> queryParams, Object body, Options options);
}

// a function that will convert a parameter to a string, used by the
// local api client to pass in the reference to this helper function lib
typedef String ParameterToString(dynamic value);
