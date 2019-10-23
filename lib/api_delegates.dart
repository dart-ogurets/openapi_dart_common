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
  Future<ApiResponse> invokeAPI(
      String basePath,
      String path,
      Iterable<QueryParam> queryParams,
      Object body,
      String jsonBody, Options options);
}

abstract class DeserializeDelegate {
  dynamic deserialize(dynamic value, String targetType);
  dynamic serialize(Object value);

  String parameterToString(dynamic value);
}