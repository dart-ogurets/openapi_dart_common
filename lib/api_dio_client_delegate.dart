part of dart_openapi;

class DioClientDelegate implements ApiClientDelegate {
  final Dio client;

  DioClientDelegate([Dio? client]) : client = client ?? Dio();

  @override
  Future<ApiResponse> invokeAPI(String basePath, String path,
      Iterable<QueryParam> queryParams, Object? body, Options options,
      {bool passErrorsAsApiResponses = false}) async {
    String url = basePath + path;

    // fill in query parameters, taking care to deal with duplicate
    // field names
    Map<String, dynamic> qp = {};
    queryParams.forEach((q) {
      if (qp.containsKey(q.name)) {
        final val = qp[q.name];
        if (val is List) {
          val.add(q.value);
        } else {
          qp[q.name] = [val, q.value];
        }
      } else {
        qp[q.name] = q.value;
      }
    });

    options.responseType = ResponseType.stream;
    options.receiveDataWhenStatusError = true;

    // Dio can't cope with this in both places, it just adds them together in a stupid way
    if (options.headers != null && options.headers!['Content-Type'] != null) {
      options.contentType = options.headers!['Content-Type'];
      options.headers!.remove('Content-Type');
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

      return ApiResponse(response.statusCode ?? 500,
          _convertHeaders(response.headers), response.data?.stream);
    } catch (e, s) {
      if (e is DioError) {
        if (passErrorsAsApiResponses) {
          if (e.response == null) {
            return ApiResponse(500, {}, null)
              ..innerException = e
              ..stackTrace = s;
          }

          if (e.response!.data is ResponseBody) {
            final response = e.response!;
            final data = response.data as ResponseBody;

            return ApiResponse(response.statusCode ?? 500,
                _convertHeaders(response.headers), data.stream);
          } else {
            print(
                "e is not responsebody ${e.response.runtimeType.toString()} ${e.response!.data?.runtimeType.toString() ?? ''}");
          }
        }

        if (e.response == null) {
          throw ApiException.withInner(500, 'Connection error', e, s);
        } else {
          throw ApiException.withInner(
              e.response?.statusCode ?? 500,
              e.response?.data == null
                  ? null
                  : await utf8.decodeStream(e.response?.data.stream),
              e,
              s);
        }
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
