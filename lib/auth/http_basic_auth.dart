part of dart_openapi;

class HttpBasicAuth implements Authentication {
  String? _username;
  String? _password;

  @override
  void applyToParams(
      List<QueryParam> queryParams, Map<String, dynamic> headerParams) {
    if (_username != null || _password != null) {
      String str = "${_username ?? ""}:${_password ?? ""}";
      headerParams["Authorization"] =
          "Basic ${base64.encode(utf8.encode(str))}";
    }
  }

  set username(String username) => _username = username;

  set password(String password) => _password = password;
}
