import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:ui/location.dart';
import 'package:ui/sock.dart';
import 'http_client_adapter.dart'; // Make sure to import the conditional adapter file

class Authorization {
  late Dio _dio;
  //late BrowserHttpClientAdapter _adapter;
  late String _url;
  static Authorization? _auth;
  dynamic _adapter;
  // Singleton
  factory Authorization([String url = ""]) {
    // Creating the initial instance if not done yet.
    if (_auth == null) {
      _auth = Authorization._internal();
      _auth!._url = url;
      _auth!._dio = Dio();
      if (!kIsWeb) {
        // For platforms other than web, use dio_cookie_manager to manage cookies
        _auth!._dio.interceptors.add(CookieManager(CookieJar()));
      } else {
        _auth!._adapter = createHttpClientAdapter();
        _auth!._adapter.withCredentials = true;
        _auth!._dio.httpClientAdapter = _auth!._adapter;

        // For web, just add a http client adapter
      }
    }

    return _auth!;
  }
  Authorization._internal();

  // Post requests
  Future<Response> postRequest(String url, Map<String, dynamic> data) async {
    url = _url + url;
    return _dio.post(url,
        data: data,
        options: Options(
            validateStatus: (status) => status != null && status < 500));
  }

  // Get requests
  Future<Response> getRequest(String url) async {
    url = _url + url;
    return _dio.get(url);
  }

  Future<bool> isLoggedIn() async {
    var resp = await postRequest("/auth/logged_in/", {});

    if (resp.data['logged_in'] == true) {
      SocketIO('http://localhost:3001');
      LocationService().update_location();
      return true;
    }
    return false;
  }
}
