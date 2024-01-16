import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../utils/storage.dart';
import '../widgets/responsive.dart';



class Config {
  static const String title = "OneList";
  static const bool textLogo = false;
  static const Color mainColor = Color.fromARGB(255, 82, 166, 236);
  static const Color fontColor = Color.fromARGB(255, 255, 255, 255);
  static const Color activeColor = Color.fromARGB(255, 244, 67, 54);


  //初始化，卡片个数
  void initCount(BuildContext context) async {
    int cardCount = await Storage().getIntData("card_count");
    if (cardCount == 0) {
      int count = 9;
      if (Responsive.isMobile(context)) {
        count = 3;
      }
      await Storage().setIntData("card_count", count);
    }
  }

  //获取卡片个数，此参数由用户设置
  Future<int> getCount() async {
    int cardCount = await Storage().getIntData("card_count");
    if (cardCount == 0) {
      cardCount = 9;
    }
    return cardCount;
  }

  //获取自动卡片高度
  double getAutoHeight(BuildContext context, isOriginals) {
    if (Responsive.isMobile(context)) {
      return 180;
    }
    if (!kIsWeb && !Platform.isWindows && Responsive.isAndroidTv(context)) {
      return 260.0;
    }
    return 260;
  }

  //获取卡片高度
  double getHeight(BuildContext context, bool isOriginals, int count) {
    double contextWidth = MediaQuery.of(context).size.width;
    double width = (contextWidth - 40) / count;
    double height = 16 / 9 * width;
    return height;
  }

  bool isAndroidTv(context) {
    return !kIsWeb && !Platform.isWindows && Responsive.isAndroidTv(context);
  }

  //横屏
  void changeScreenLeft() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  //竖屏
  void changeScreenDown() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }
}
