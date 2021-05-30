part of dart_openapi;
// @dart=2.9

class ApiClient {
  ApiClientDelegate apiClientDelegate;
  String basePath;

  // if this is set, to true, then errors will not be mapped as exceptions
  // they will be passed as ApiResponses so the client can deal with them
  bool passErrorsAsApiResponses = false;

  Map<String, String> _defaultHeaderMap = {};
  Map<String, Authentication> _authentications = {};

  ApiClient({this.basePath = "http://localhost", apiClientDelegate})
      : this.apiClientDelegate = apiClientDelegate ?? DioClientDelegate();

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

  /// Update query and header parameters based on authentication settings.
  /// @param authNames The authentications to apply
  void _updateParamsForAuth(List<String> authNames,
      List<QueryParam> queryParams, Map<String, dynamic> headerParams) {
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
  Future<ApiResponse> invokeAPI(String path, Iterable<QueryParam> queryParams,
      Object body, List<String> authNames, Options options) async {
    _updateParamsForAuth(authNames, queryParams, options.headers);

    options.headers.addAll(_defaultHeaderMap);

    return apiClientDelegate.invokeAPI(
        basePath, path, queryParams, body, options, passErrorsAsApiResponses: passErrorsAsApiResponses);
  }
}
