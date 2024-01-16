import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;
  final Widget androidTv;

  const Responsive({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
    required this.androidTv,
  }) : super(key: key);

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 800;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 800 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 960;

  static bool isAndroidTv(BuildContext context) =>
      MediaQuery.of(context).size.width >= 960 && !kIsWeb? Platform.isAndroid:true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (kIsWeb){
          return desktop;
        }
        if (constraints.maxWidth >= 1200) {
          return desktop;
        }else if (constraints.maxWidth >= 900) {
          if(!kIsWeb&&Platform.isAndroid){
            return androidTv;
          }else{
            return desktop;
          }
        } else if (constraints.maxWidth >= 800) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
