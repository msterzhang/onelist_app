import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  //储存值
  Future<void> setStringData(String key, String data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, data);
  }

  //获取储存值
  Future<String> getStringData(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(key);
    if (data != null) {
      return data.toString();
    } else {
      return "";
    }
  }

  //储存double值
  Future<void> setDoubleData(String key, double data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble(key, data);
  }

  //获取储存double值
  Future<double> getDoubleData(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final double? data = prefs.getDouble(key);
    if (data != null) {
      return data;
    } else {
      return 0;
    }
  }

  //储存int值
  Future<void> setIntData(String key, int data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, data);
  }

  //获取储存int值
  Future<int> getIntData(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? data = prefs.getInt(key);
    if (data != null) {
      return data;
    } else {
      return 0;
    }
  }

  //清除缓存
  Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("plyr_times");
    prefs.remove("plyr_speeds");
  }
  Future<void> removeData(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }


  //获取播放时间
  Future getCurrentTime(String id) async {
    int currentTime = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? plyrTimesData = prefs.getString("plyr_times");
    if (plyrTimesData != null) {
      dynamic plyrTimes = json.decode(plyrTimesData);
      for (dynamic item in plyrTimes['times']) {
        if (item['id'] == id) {
          currentTime = item['time'];
        }
      }
    }
    return currentTime;
  }

  // 保存播放进度时间
  void setCurrentTime(String id, int currentTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? playerTimesData = prefs.getString("plyr_times");
    if (playerTimesData == null) {
      Map<String, dynamic> playerTimes = {
        'times': [],
        'state': true,
      };
      playerTimes['times'].add({"id": id, "time": currentTime});
      await prefs.setString("plyr_times", json.encode(playerTimes));
    } else {
      bool get = false;
      Map<String, dynamic> plyrTimes = json.decode(playerTimesData);
      for (int i = 0; i < plyrTimes['times'].length; i++) {
        if (plyrTimes['times'][i]['id'] == id) {
          get = true;
          plyrTimes['times'][i] = {"id": id, "time": currentTime};
        }
      }
      if (!get) {
        plyrTimes['times'].add({"id": id, "time": currentTime});
      }
      await prefs.setString("plyr_times", json.encode(plyrTimes));
    }
  }

  // 保存播放进度
  void setSpeed(int id, int speedItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? plyrSpeedsData = prefs.getString("plyr_speeds");
    if (plyrSpeedsData == null) {
      Map<String, dynamic> plyrSpeeds = {
        'speeds': [],
        'state': true,
      };
      plyrSpeeds['speeds'].add({"id": id, "speed": speedItem});
      await prefs.setString("plyr_speeds", json.encode(plyrSpeeds));
    } else {
      bool get = false;
      Map<String, dynamic> plyrSpeeds = json.decode(plyrSpeedsData);

      for (int i = 0; i < plyrSpeeds['speeds'].length; i++) {
        if (plyrSpeeds['speeds'][i]['id'] == id) {
          get = true;
          plyrSpeeds['speeds'][i] = {"id": id, "speed": speedItem};
        }
      }
      if (!get) {
        plyrSpeeds['speeds'].add({"id": id, "speed": speedItem});
      }
      await prefs.setString("plyr_speeds", json.encode(plyrSpeeds));
    }
  }

  // 获取播放进度
  Future<int> getSpeed(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? plyrSpeedsData = prefs.getString("plyr_speeds");
    int speedItem = 0;
    if (plyrSpeedsData != null) {
      Map<String, dynamic> plyrSpeeds = json.decode(plyrSpeedsData);

      for (var item in plyrSpeeds['speeds']) {
        if (item['id'] == id) {
          speedItem = item['speed'];
        }
      }
    }
    return speedItem;
  }
}
