import 'package:dio/dio.dart';

import '../http/dio_http.dart';

class Servers {
  //读取,创建,删除
  Future<bool> server(String type, dynamic form) async {
    try {
      String path = "/v1/api/$type/renew";
      Response response = await DioWrapper().post(path, form);
      if (response.data["code"] == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
