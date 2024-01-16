import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

String server = "https://one.jiohub.top";
String authorization = "";
// 相关参数
String key = "Authorization";
String serverKey = "server_host";

class DioWrapper {
  late Dio _dio;

  DioWrapper() {
    _dio = Dio(); // 创建Dio实例
    // 添加请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 在请求之前添加拦截逻辑
        // 例如，可以在此处添加认证信息、日志记录等
        return handler.next(options); // 继续发送请求
      },
      onResponse: (response, handler) {
        // 在接收到响应之前添加拦截逻辑
        // 例如，可以在此处处理通用的响应数据结构
        return handler.next(response); // 继续处理响应
      },
      onError: (DioException error, handler) {
        // 在请求或响应过程中出现错误时添加拦截逻辑
        // 例如，可以在此处处理特定的错误状态码
        return handler.next(error); // 继续处理错误
      },
    ));

    //证书校验

    !kIsWeb && server.contains("https")
        ? _dio.httpClientAdapter = IOHttpClientAdapter(
            createHttpClient: () {
              // Don't trust any certificate just because their root cert is trusted.
              final HttpClient client =
                  HttpClient(context: SecurityContext(withTrustedRoots: false));
              // You can test the intermediate / root cert here. We just ignore it.
              client.badCertificateCallback = (cert, host, port) => true;
              return client;
            },
            validateCertificate: (cert, host, port) {
              // Check that the cert fingerprint matches the one we expect.
              // We definitely require _some_ certificate.
              if (cert == null) {
                return false;
              }
              // Validate it any way you want. Here we only check that
              // the fingerprint matches the OpenSSL SHA256.
              return true;
            },
          )
        : null;

    // 设置超时时间
    _dio.options.connectTimeout = const Duration(seconds: 20); // 设置连接超时时间为20秒

    // 添加请求头
    kIsWeb
        ? null
        : _dio.options.headers['User-Agent'] =
            'one list tv/1.0'; // 添加自定义的User-Agent请求头
    _dio.options.headers['Authorization'] =
        authorization; // 添加自定义的User-Agent请求头
  }

  // 封装get请求
  Future<Response> get(String path) {
    String url = server + path;
    return _dio.get(url);
  }

  // 封装post请求
  Future<Response> post(String path, dynamic data) {
    String url = server + path;
    return _dio.post(url, data: data);
  }

  Future<Response> postNewHost(url, dynamic data) {
    return _dio.post(url, data: data);
  }


  String getServer() {
    return server;
  }

  //初始化检查Server
  Future<bool> initServer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(serverKey);
    if (data != null) {
      server = data;
      return true;
    } else {
      return false;
    }
  }

  //保存Server
  Future<void> setServer(data) async {
    server = data;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(serverKey, data);
  }

  //删除Server
  Future<void> removeServer() async {
    server = "";
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(serverKey);
  }

  //获取Authorization
  Future<bool> initAuthorization() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(key);
    if (data != null) {
      authorization = data;
      return true;
    } else {
      return false;
    }
  }

  //保存Authorization
  Future<void> setAuthorization(data) async {
    authorization = data;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, data);
  }

  //获取Authorization
  Future<String> getAuthorization() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(key);
    if (data != null) {
      return data;
    } else {
      return "";
    }
  }

  //注销登录，清理token，清理账户
  Future<void> loginOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
    prefs.remove("email");
    prefs.remove("password");
  }
}
