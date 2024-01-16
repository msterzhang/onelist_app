import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:one_list_tv/http/dio_http.dart';
import 'package:one_list_tv/screens/login_screen.dart';
import 'package:one_list_tv/screens/register_screen.dart';
import 'package:one_list_tv/utils/storage.dart';
import 'package:one_list_tv/widgets/widgets.dart';

import '../utils/assets.dart';
import '../utils/config.dart';
import '../widgets/icon_button.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  //"个人设置","授权设置", "清除缓存", "切换账户", "登出应用"
  List<String> contentList = [
    "影视卡片数量设置",
    "清除缓存",
    "切换账户",
    "切换服务器",
    "赞助作者",
    "软件信息",
    "登出应用"
  ];
  final FocusNode _subBtnFocusNode = FocusNode();
  final FocusNode _countFocusNode = FocusNode();
  final TextEditingController _count = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      loading = false;
    });
  }

  //显示信息
  void showMsg(String msg) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return material.SimpleDialog(
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

  //显示信息
  void showCard() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return material.SimpleDialog(
            backgroundColor: const Color(0xFF151C22),
            title: const Text(
              '感谢你的赞助！',
              style: TextStyle(
                color: Config.mainColor,
                fontSize: 28.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            children: [
              const Padding(
                padding: material.EdgeInsets.only(left: 40),
                child: Text(
                  '支付宝:',
                  style: TextStyle(
                    color: Config.fontColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Image.asset(
                Assets.zfbCard,
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: material.EdgeInsets.only(left: 40),
                child: Text(
                  '微信:',
                  style: TextStyle(
                    color: Config.fontColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Image.asset(
                Assets.wxCard,
                width: 200,
                height: 200,
              ),
            ],
          );
        });
    Timer(const Duration(seconds: 10), () {
      Navigator.pop(context);
    });
  }

  //视频卡片数设置
  void showCountForm() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return material.SimpleDialog(
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
              const Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  "横向视频卡片个数：",
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
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: material.TextField(
                  controller: _count,
                  focusNode: _countFocusNode,
                  decoration: material.InputDecoration(
                    hintText: 'count',
                    filled: true,
                    fillColor: material.Colors.white12,
                    border: material.OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                  cursorColor: Colors.white,
                  onSubmitted: (value) {
                    _countFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_subBtnFocusNode);
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: CustomColorIconButton(
                    active: false,
                    focusNode: _subBtnFocusNode,
                    title: "保  存",
                    onSelected: () {
                      // debugPrint("返回");
                    },
                    onClick: () async {
                      if (_count.text.isNotEmpty) {
                        try {
                          int count = int.parse(_count.text);
                          await Storage().setIntData("card_count", count);
                          Navigator.pop(context);
                          showMsg("设置成功,重启生效!");
                        } catch (e) {
                          showMsg(e.toString());
                        }
                      } else {
                        showMsg("数值不能为空");
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        });
  }

  Future<void> changeUser() async {
    await DioWrapper().loginOut();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryanimation) =>
            DrillInPageTransition(
          animation: animation,
          child: const LoginScreen(),
        ),
      ),
    );
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
            DrillInPageTransition(
          animation: animation,
          child: const RegisterScreen(),
        ),
      ),
    );
  }

  void showAll(String content) async {
    switch (content) {
      case "切换账户":
        {
          await changeUser();
        }
        break;
      case "切换服务器":
        {
          await changeServer();
        }
        break;
      case "赞助作者":
        {
          showCard();
        }
        break;
      case "登出应用":
        {
          await DioWrapper().loginOut();
          !kIsWeb ? exit(0) : null;
        }
        break;
      case "清除缓存":
        {
          await Storage().clearAll();
          showMsg("清除完毕");
        }
        break;
      case "软件信息":
        {
          showMsg("服务端开源地址：https://github.com/msterzhang/onelist\n客户端开源地址：https://github.com/msterzhang/onelist_app");
        }
        break;
      case "影视卡片数量设置":
        {
          int count = await Storage().getIntData("card_count");
          if (count == 0) {
            _count.text = "9";
          } else {
            _count.text = count.toString();
          }
          showCountForm();
          Timer(const Duration(seconds: 1), () {
            _countFocusNode.requestFocus();
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.black,
        child: loading
            ? const Loading()
            : Container(
                padding: Responsive.isMobile(context)
                    ? const EdgeInsets.all(5.0)
                    : const EdgeInsets.all(20.0),
                color: Colors.black,
                child: Column(
                  children: [
                    const HeaderTitleBar(
                      title: '设置中心',
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 8.0,
                        ),
                        scrollDirection: Axis.vertical,
                        itemCount: contentList.length,
                        itemBuilder: (BuildContext context, int index) {
                          String content = contentList[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: SizedBox(
                              height: 70,
                              width: double.infinity,
                              child: HoverButton(
                                focusEnabled: true,
                                focusNode: FocusNode(),
                                onFocusChange: ((focus) {
                                  if (focus) {
                                    // debugPrint(content);
                                  }
                                }),
                                onPressed: () {
                                  debugPrint(content);
                                  showAll(content);
                                },
                                builder:
                                    (BuildContext, Set<ButtonStates> state) {
                                  return FocusBorder(
                                    focused: state.isFocused,
                                    style: const FocusThemeData(
                                      glowFactor: 0.0,
                                      primaryBorder: BorderSide(
                                        width: 3,
                                        color: Config.fontColor,
                                      ),
                                    ),
                                    renderOutside: true,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        color: Config.mainColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                      ),
                                      padding: const EdgeInsets.all(5),
                                      child: Center(
                                        child: Text(
                                          content,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
