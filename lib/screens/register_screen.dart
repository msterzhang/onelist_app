import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_list_tv/utils/utils.dart';

import '../http/dio_http.dart';
import '../widgets/icon_button.dart';
import '../widgets/loading.dart';
import '../widgets/responsive.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _server = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final FocusNode _serverFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _sendBtnFocusNode = FocusNode();
  final FocusNode _clearBtnFocusNode = FocusNode();
  DioWrapper dioWrapper = DioWrapper();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    _serverFocusNode.dispose();
    _sendBtnFocusNode.dispose();
    _nameFocusNode.dispose();
    _clearBtnFocusNode.dispose();
    super.dispose();
  }

  //加载中
  void showLoading(String text) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Center(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(3.0),
                  boxShadow: const [
                    //阴影
                    BoxShadow(
                      color: Colors.black12,
                      //offset: Offset(2.0,2.0),
                      blurRadius: 10.0,
                    )
                  ]),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              constraints: const BoxConstraints(minHeight: 120, minWidth: 180),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  //显示信息
  void showMsg(String msg) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: const Color(0xFF151C22),
            title: const Text(
              '提示',
              style: TextStyle(
                color: Config.mainColor,
                fontSize: 28.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  msg,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        });
    Timer(const Duration(seconds: 3), () {
      Navigator.pop(context);
    });
  }

  Future<void> loadData() async {
    bool ok = await dioWrapper.initServer();
    if (ok) {
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation, secondaryanimation) =>
                  fluent.DrillInPageTransition(
                    animation: animation,
                    child: const LoginScreen(),
                  )));
    } else {
      setState(() {
        loading = false;
      });
      !kIsWeb ? _serverFocusNode.requestFocus() : null;
    }
  }

  String removeTrailingSlash(String url) {
    return url.endsWith("/") ? url.substring(0, url.length - 1) : url;
  }

  //连接服务器
  Future<void> connect() async {
    _server.text = removeTrailingSlash(_server.text);
    if (_server.text.isNotEmpty && _name.text.isNotEmpty) {
      try {
        Response response =
            await dioWrapper.get("${_server.text}/onelist/ping");
        if (response.data["code"] == 200) {
          showMsg("连接成功!");
          await Storage().setStringData("server_host", _server.text);
          await Storage().setStringData("server_name", _name.text);
          bool ok = await dioWrapper.initServer();
          if (ok) {
            Timer(const Duration(seconds: 3), () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryanimation) =>
                      fluent.DrillInPageTransition(
                    animation: animation,
                    child: const LoginScreen(),
                  ),
                ),
              );
            });
          } else {
            showMsg("服务器初始化失败!");
          }
        } else {
          showMsg(response.data["msg"]);
        }
      } catch (e) {
        showMsg(e.toString());
      }
    } else {
      showMsg("服务器地址及备注名称均不能为空!");
    }
  }

  //头像logo
  Widget headerImage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 130.0,
      width: 130.0,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage(Assets.header),
          fit: BoxFit.cover,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: getRandomColor(), width: 4.0),
      ),
    );
  }

  //服务器
  Widget serverPage() {
    return Row(
      children: [
        const Text(
          "地址:",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28.0,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(2.0, 4.0),
                blurRadius: 6.0,
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: TextField(
            controller: _server,
            focusNode: _serverFocusNode,
            decoration: InputDecoration(
              hintText: 'server',
              filled: true,
              fillColor: Colors.white12,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 20),
            cursorColor: Colors.white,
            onSubmitted: (value) {
              if (!kIsWeb) {
                _serverFocusNode.unfocus();
                FocusScope.of(context).requestFocus(_nameFocusNode);
              }
            },
          ),
        )
      ],
    );
  }

  //服务器备注名称
  Widget namePage() {
    return Row(
      children: [
        const Text(
          "备注:",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28.0,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(2.0, 4.0),
                blurRadius: 6.0,
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: TextField(
            controller: _name,
            focusNode: _nameFocusNode,
            decoration: InputDecoration(
              hintText: 'name',
              filled: true,
              fillColor: Colors.white12,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 20),
            cursorColor: Colors.white,
            onSubmitted: (value) {
              if (!kIsWeb) {
                _nameFocusNode.unfocus();
                FocusScope.of(context).requestFocus(_sendBtnFocusNode);
              }
            },
          ),
        )
      ],
    );
  }

  //连接服务器卡片
  Widget loginPage() {
    return Stack(
      children: [
        // 背景图
        Image.asset(
          Assets.background,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        // 登录框
        Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                headerImage(),
                Container(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width - 10
                      : kIsWeb || Platform.isWindows
                          ? MediaQuery.of(context).size.width * 0.36
                          : MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //服务器
                        serverPage(),
                        const SizedBox(height: 20.0),
                        namePage(),
                        const SizedBox(height: 20.0),
                        SizedBox(
                          height: 65,
                          width: double.infinity,
                          child: CustomColorIconButton(
                            active: false,
                            focusNode: _sendBtnFocusNode,
                            title: "连接服务器",
                            onSelected: () {
                              // debugPrint("返回");
                            },
                            onClick: () {
                              connect();
                            },
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        SizedBox(
                          height: 65,
                          width: double.infinity,
                          child: CustomColorIconButton(
                            active: false,
                            focusNode: _clearBtnFocusNode,
                            title: "清除服务器",
                            onSelected: () {
                              // debugPrint("返回");
                            },
                            onClick: () async {
                              await Storage().removeData("server_host");
                              await Storage().removeData("server_name");
                              _name.text = "";
                              _server.text = "";
                              showMsg("清除成功");
                            },
                          ),
                        ),
                      ]),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  //按键处理
  void _onKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (_nameFocusNode.hasFocus) {
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          _serverFocusNode.requestFocus();
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          _sendBtnFocusNode.requestFocus();
        }
      } else if (_serverFocusNode.hasFocus) {
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          _clearBtnFocusNode.requestFocus();
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          _nameFocusNode.requestFocus();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.black,
          child: loading
              ? const Loading()
              : RawKeyboardListener(
                  focusNode: FocusNode(),
              onKey: kIsWeb ? null : _onKey,
              child: loginPage())
      ),
    );
  }
}
