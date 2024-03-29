# OpenAPI Common Library for Dart Client Code Generator

This library forms the core reusable library for the [Maven plugin](https://github.com/dart-ogurets/dart-openapi-maven).

It is intended to allow you to generate a single client library from an OpenAPI file, and allow you to reuse it across
multiple clients - Flutter for Web (browser), Flutter and Dart CLI (such as when using 
[Ogurets](https://pub.dev/packages/ogurets) for e2e testing).

### How to use

This library contains all of the necessary parts required to wire up your generated code from the Maven plugin. 
Add these to your `pubspec.yaml` and then combine them together.

```yaml
dependencies:
  openapi_dart_common: ^3.2.1 
  your_generated_lib:
    path:
      ../your_generated_lib
```

(for example)

In your application, each of the generated Services will require an ApiClient. 
As of version 2.0 we have swapped to Dio, which takes care of browser vs CLI, so you
only need to specify DioClientDelegate() if you wish to override the Dio instance (providing extra options, etc). 
 
It also needs to know how to deserialize specific models and enums - those from your generated code, so a typical 
creation could look like this:

```dart
    _apiClient = ApiClient(
      basePath: "http://localhost:8903",
      apiClientDelegate: DioClientDelegate());
```

and then you can use your _apiClient instance in your models, consistently across all platforms:

```dart
    _personService = PersonServiceApi(_apiClient);
```      

You can also override the `BaseClient` that is passed into the `ApiClient` if you need to customise it, but be
careful not to mix those requiring `dart:html` (which only exists in the browser) with `dart:io` (everywhere else).

#### Maven

If you don't have Maven installed, you can install it fairly easily on Linux and Mac (its in brew), it will require
a JDK implementation so if you don't have done get one from https://adoptopenjdk.net/. Alternatively you can use it from 
Docker.



