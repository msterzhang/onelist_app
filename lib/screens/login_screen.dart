import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_list_tv/screens/register_screen.dart';
import 'package:one_list_tv/utils/utils.dart';
import 'package:one_list_tv/widgets/loading.dart';

import '../http/dio_http.dart';
import '../widgets/icon_button.dart';
import '../widgets/responsive.dart';
import 'nav_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _subBtnFocusNode = FocusNode();
  final FocusNode _changeBtnFocusNode = FocusNode();
  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    load();
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _subBtnFocusNode.dispose();
    _changeBtnFocusNode.dispose();
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

  Future<void> loadConfig() async {
    try {
      Response response = await DioWrapper().get("/v1/api/configs");
      if (response.data["code"] == 200) {
        await Storage().setStringData(
            "img_url", response.data["data"]["img_url"]);
      }
    } catch (e) {
      showMsg(e.toString());
    }
  }

  //加载
  Future<void> load() async {
    loadConfig();
    _email.text = await Storage().getStringData("email");
    _password.text = await Storage().getStringData("password");
    await Storage().getStringData("password");
    bool ok = await DioWrapper().initAuthorization();
    if (ok) {
      try {
        Response response = await DioWrapper().get("/v1/api/user/data");
        if (response.data["code"] == 200) {
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (BuildContext context) {
                return NavScreen();
              }), (route) => route == null);
        } else {
          showMsg(response.data["msg"]);
          setState(() {
            loading = false;
            _emailFocusNode.requestFocus();
          });
        }
      } catch (e) {
        // showMsg(e.toString());
        setState(() {
          loading = false;
          _emailFocusNode.requestFocus();
        });
      }
    } else {
      setState(() {
        loading = false;
        _emailFocusNode.requestFocus();
      });
    }
  }

  //登录
  Future<void> login() async {
    if (_email.text.isNotEmpty && _password.text.isNotEmpty) {
      try {
        dynamic form = {"user_email": _email.text, "user_password": _password.text};
        Response response = await DioWrapper().post("/v1/api/user/login", form);
        if (response.data["code"] == 200) {
          await DioWrapper().setAuthorization(response.data["data"]);
          await Storage().setStringData("email", _email.text);
          await Storage().setStringData("password", _password.text);
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return NavScreen();
          }), (route) => route == null);
        } else {
          showMsg(response.data["msg"]);
        }
      } catch (e) {
        showMsg(e.toString());
      }
    } else {
      showMsg("账号及密码不能为空!");
    }
  }

  Future<void> changeServer() async {
    await DioWrapper().loginOut();
    await DioWrapper().removeServer();
    await Storage().removeData("server_host");
    await Storage().removeData("server_name");
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryanimation) =>
            fluent.DrillInPageTransition(
              animation: animation,
              child: const RegisterScreen(),
            ),
      ),
    );
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

  //邮箱
  Widget emailPage() {
    return Row(
      children: [
        const Text(
          "邮箱:",
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
            controller: _email,
            focusNode: _emailFocusNode,
            decoration: InputDecoration(
              hintText: 'Email',
              filled: true,
              fillColor: Colors.white12,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 20),
            cursorColor: Colors.white,
            onSubmitted: (value) {
              _emailFocusNode.unfocus();
              FocusScope.of(context).requestFocus(_passwordFocusNode);
            },
          ),
        )
      ],
    );
  }

  //密码
  Widget passwordPage() {
    return Row(
      children: [
        const Text(
          "密码:",
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
            controller: _password,
            focusNode: _passwordFocusNode,
            decoration: InputDecoration(
              hintText: 'Password',
              filled: true,
              fillColor: Colors.white12,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 20),
            cursorColor: Colors.white,
            onSubmitted: (value) {
              _passwordFocusNode.unfocus();
              _subBtnFocusNode.requestFocus();
            },
            obscureText: true,
          ),
        ),
      ],
    );
  }

  //登录卡片
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
                      //邮箱
                      emailPage(),
                      const SizedBox(height: 20.0),
                      passwordPage(),
                      const SizedBox(
                        height: 40,
                      ),
                      SizedBox(
                          height: 65,
                          width: double.infinity,
                          child: CustomColorIconButton(
                            active: false,
                            focusNode: _subBtnFocusNode,
                            title: "提交登录",
                            onSelected: () {
                              // debugPrint("返回");
                            },
                            onClick: () {
                              login();
                            },
                          )
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                          height: 65,
                          width: double.infinity,
                          child: CustomColorIconButton(
                            active: false,
                            focusNode: _changeBtnFocusNode,
                            title: "切换服务器",
                            onSelected: () {
                              // debugPrint("返回");
                            },
                            onClick: () {
                              changeServer();
                            },
                          )
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _onKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (!_passwordFocusNode.hasFocus &&
          !_emailFocusNode.hasFocus &&
          !_subBtnFocusNode.hasFocus&&
          !_changeBtnFocusNode.hasFocus) {
        _emailFocusNode.requestFocus();
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (_changeBtnFocusNode.hasFocus){
          _subBtnFocusNode.requestFocus();
        }else if (_subBtnFocusNode.hasFocus) {
          _passwordFocusNode.requestFocus();
        } else if (_passwordFocusNode.hasFocus) {
          _emailFocusNode.requestFocus();
        }else {
          _emailFocusNode.requestFocus();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (_emailFocusNode.hasFocus) {
          _passwordFocusNode.requestFocus();
        } else if (_passwordFocusNode.hasFocus) {
          _subBtnFocusNode.requestFocus();
        }else if ( _subBtnFocusNode.hasFocus) {
          _changeBtnFocusNode.requestFocus();
        } else  {
          _emailFocusNode.requestFocus();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.space || event.logicalKey == LogicalKeyboardKey.escape) {
        _subBtnFocusNode.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //初始化卡片个数
    Config().initCount(context);
    return Scaffold(
      body: Container(
          color: Colors.black,
          child: loading
              ? const Center(
                  child: Loading(),
                )
              : fluent.RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: kIsWeb ? null : _onKey,
                  child: loginPage(),
                )),
    );
  }
}
