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
      String queryString,
      String path,
      String method,
      Iterable<QueryParam> queryParams,
      Object body,
      String jsonBody,
      Map<String, String> headerParams,
      Map<String, String> formParams,
      String contentType,
      List<String> authNames);
}

abstract class DeserializeDelegate {
  dynamic deserialize(dynamic value, String targetType);

  String parameterToString(dynamic value);
}

class ApiClient {
  final DeserializeDelegate deserializeDelegate;
  ApiClientDelegate apiClientDelegate;
  String basePath;

  Map<String, String> _defaultHeaderMap = {};
  Map<String, Authentication> _authentications = {};

  ApiClient(
      {this.basePath = "http://localhost",
      this.deserializeDelegate,
      this.apiClientDelegate})
      : assert(deserializeDelegate != null),
        assert(apiClientDelegate != null);

  void setDefaultHeader(String key, String value) {
    if (value == null) {
      _defaultHeaderMap.remove(key);
    } else {
      _defaultHeaderMap[key] = value;
    }
  }

  // ensure you set the Auth before calling an API that requires that type
  void setAuthentication(String key, Authentication auth) {
    if (auth == null) {
      _authentications.remove(key);
    } else {
      _authentications[key] = auth;
    }
  }

  dynamic deserialize(String json, String targetType) {
    // Remove all spaces.  Necessary for reg expressions as well.
    targetType = targetType.replaceAll(' ', '');

    if (targetType == 'String') return json;

    var decodedJson = jsonDecode(json);
    return deserializeDelegate.deserialize(decodedJson, targetType);
  }

  String serialize(Object obj) {
    String serialized = '';
    if (obj == null) {
      serialized = '';
    } else {
      serialized = json.encode(obj);
    }
    return serialized;
  }

  /// Update query and header parameters based on authentication settings.
  /// @param authNames The authentications to apply
  void _updateParamsForAuth(List<String> authNames,
      List<QueryParam> queryParams, Map<String, String> headerParams) {
    authNames.forEach((authName) {
      Authentication auth = _authentications[authName];
      if (auth == null) {
        throw ArgumentError("Authentication undefined: " + authName);
      }
      auth.applyToParams(queryParams, headerParams);
    });
  }

  T getAuthentication<T extends Authentication>(String name) {
    var authentication = _authentications[name];

    return authentication is T ? authentication : null;
  }

  // We don't use a Map<String, String> for queryParams.
  // If collectionFormat is 'multi' a key might appear multiple times.
  Future<ApiResponse> invokeAPI(
      String path,
      String method,
      Iterable<QueryParam> queryParams,
      Object body,
      Map<String, String> headerParams,
      Map<String, String> formParams,
      String contentType,
      List<String> authNames) async {
    _updateParamsForAuth(authNames, queryParams, headerParams);

    var ps = queryParams
        .where((p) => p.value != null)
        .map((p) => '${p.name}=${Uri.encodeQueryComponent(p.value)}');

    String queryString = ps.isNotEmpty ? '?' + ps.join('&') : '';

    headerParams.addAll(_defaultHeaderMap);
    
    if (contentType != null) {
      headerParams['Content-Type'] = contentType;
    }

    return apiClientDelegate.invokeAPI(
        basePath,
        queryString,
        path,
        method,
        queryParams,
        body,
        body is MultipartRequest ? null : serialize(body),
        headerParams,
        formParams,
        contentType,
        authNames);
  }
}
