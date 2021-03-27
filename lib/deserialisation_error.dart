part of dart_openapi;

/// represents a failed deserialisation in nullSafe mode because
/// we cannot find a non-null version of the field
class DeserialisationError implements Exception {
  Map<String, dynamic> data;
  String fieldName;
  String className;
  String reason;

  DeserialisationError(this.data, this.fieldName, this.className, this.reason);
}
