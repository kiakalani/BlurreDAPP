import 'package:dio/dio.dart';

HttpClientAdapter createHttpClientAdapterImpl() {
  // For non-web platforms, we create and return the default adapter
  // directly from Dio's factory method or constructor, if available.
  return Dio().httpClientAdapter;
}
