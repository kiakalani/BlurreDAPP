// Ensure this file is used only in web environments
import 'package:dio/dio.dart';

HttpClientAdapter createHttpClientAdapterImpl() {
  // Directly instantiate BrowserHttpClientAdapter for web
  return Dio().httpClientAdapter;
}

