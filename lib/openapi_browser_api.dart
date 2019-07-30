library openapi_common_browser;

import 'package:http/http.dart';
import 'package:http/browser_client.dart';

import 'openapi.dart';

/// Use this one if you are using Flutter Web or are otherwise inside a web browser
class BrowserApiClientDelegate implements ApiClientDelegate {
  final BaseClient client;

  BrowserApiClientDelegate([BaseClient client])
      : client = client ?? BrowserClient();

  @override
  Future<ApiResponse> invokeAPI(
      String basePath,
      String queryString,
      String path,
      String method,
      Iterable<QueryParam> queryParams,
      Object body,
      String jsonBody,
      Map<String, String> headerParams,
      Map<String, String> formParams,
      String contentType,
      List<String> authNames) async {
    String url = basePath + path + queryString;

    if (body is MultipartRequest) {
      var request = MultipartRequest(method, Uri.parse(url));
      request.fields.addAll(body.fields);
      request.files.addAll(body.files);
      request.headers.addAll(body.headers);
      request.headers.addAll(headerParams);
      var response = await client.send(request);
      return ApiResponse()
        ..body = response.stream
        ..statusCode = response.statusCode
        ..headers = _convertHeaders(response.headers);
    } else {
      var msgBody = contentType == "application/x-www-form-urlencoded"
          ? formParams
          : jsonBody;

      var request = Request(method, Uri.parse(url));
      request.headers.addAll(headerParams);

      if (msgBody != null) {
        request.body = msgBody;
      }

      var response = await client.send(request);

      return ApiResponse()
        ..headers = _convertHeaders(response.headers)
        ..statusCode = response.statusCode
        ..body = response.stream;
    }
  }

  Map<String, List<String>> _convertHeaders(Map<String, String> headers) {
    Map<String, List<String>> res = {};
    headers.forEach((k, v) => res[k] = [v]);
    return res;
  }
}
