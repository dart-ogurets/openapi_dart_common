part of dart_openapi;

class DioClientDelegate implements ApiClientDelegate {
  final Dio client;

  DioClientDelegate([Dio client])
      : client = client ?? Dio();

  @override
  Future<ApiResponse> invokeAPI(String basePath, String path,
      Iterable<QueryParam> queryParams, Object body, String jsonBody, Options options) async {

    String url = basePath + path;

    // fill in query parameters
    Map<String, String> qp = {};
    queryParams.forEach((q) => qp[q.name] = q.value);

    options.responseType = ResponseType.stream;
    options.receiveDataWhenStatusError = true;

    try {
      final Response<ResponseBody> response = await client.request<
          ResponseBody>(url,
          options: options,
          data: jsonBody ?? body,
          queryParameters: qp);

      assert(response.data.stream is Stream<List<int>>);

      return ApiResponse()
        ..headers = _convertHeaders(response.headers)
        ..statusCode = response.statusCode
        ..body = response.data.stream;
    } catch (e, s) {
      if (e is DioError) {
        throw new ApiException.withInner(e.response.statusCode, e.response.data == null ? null : await utf8.decodeStream(e.response.data.stream), e, s);
      }

      throw e;
    }
  }

  Map<String, List<String>> _convertHeaders(Headers headers) {
    Map<String, List<String>> res = {};
    headers.forEach((k, v) => res[k] = v);
    return res;
  }
}