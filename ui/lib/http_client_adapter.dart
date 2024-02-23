// Use conditional import
import 'http_client_adapter_io.dart'
  if (dart.library.html) 'http_client_adapter_web.dart';
import 'package:dio/dio.dart';


HttpClientAdapter createHttpClientAdapter() => createHttpClientAdapterImpl();
