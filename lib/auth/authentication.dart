part of dart_openapi;
// @dart=2.9

abstract class Authentication {
  /// Apply authentication settings to header and query params.
  void applyToParams(
      List<QueryParam> queryParams, Map<String, dynamic> headerParams);
}
