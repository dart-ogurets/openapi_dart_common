part of dart_openapi;
// @dart=2.9

class DioClientDelegate implements ApiClientDelegate {
  final Dio client;

  DioClientDelegate([Dio client]) : client = client ?? Dio();

  @override
  Future<ApiResponse> invokeAPI(String basePath, String path,
      Iterable<QueryParam> queryParams, Object body, Options options) async {
    String url = basePath + path;

    // fill in query parameters
    Map<String, String> qp = {};
    queryParams.forEach((q) => qp[q.name] = q.value);

    options.responseType = ResponseType.stream;
    options.receiveDataWhenStatusError = true;

    // Dio can't cope with this in both places, it just adds them together in a stupid way
    if (options.headers['Content-Type'] != null) {
      options.contentType = options.headers['Content-Type'];
      options.headers.remove('Content-Type');
    }

    try {
      Response<ResponseBody> response;

      if (['GET', 'HEAD', 'DELETE'].contains(options.method)) {
        response = await client.request<ResponseBody>(url,
            options: options, queryParameters: qp);
      } else {
        response = await client.request<ResponseBody>(url,
            options: options, data: body, queryParameters: qp);
      }

      return ApiResponse()
        ..headers = _convertHeaders(response?.headers)
        ..statusCode = response?.statusCode ?? 500
        ..body = response?.data.stream;
    } catch (e, s) {
      if (e is DioError) {
        if (e.response == null) {
          throw ApiException.withInner(500, 'Connection error', e, s);
        } else {
          throw ApiException.withInner(
              e.response.statusCode,
              e.response.data == null
                  ? null
                  : await utf8.decodeStream(e.response.data.stream),
              e,
              s);
        }
      }

      throw e;
    }
  }

  Map<String, List<String>> _convertHeaders(Headers headers) {
    Map<String, List<String>> res = {};
    headers?.forEach((k, v) => res[k] = v);
    return res;
  }
}
