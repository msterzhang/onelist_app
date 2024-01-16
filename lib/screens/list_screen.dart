import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:one_list_tv/widgets/header_title_bar.dart';
import 'package:one_list_tv/widgets/icon_button.dart';

import '../http/dio_http.dart';
import '../utils/config.dart';
import '../widgets/loading.dart';
import '../widgets/movie_item.dart';
import '../widgets/responsive.dart';
import 'description_screen.dart';
import 'login_screen.dart';

class ListScreen extends StatefulWidget {
  final String dataType;
  final String galleryUid;
  final String galleryTitle;

  const ListScreen({
    Key? key,
    required this.dataType,
    required this.galleryUid,
    required this.galleryTitle,
  }) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _errFocusNode = FocusNode();
  late final FocusNode _nextFocusNode = FocusNode();
  late final FocusNode _oneFocusNode = FocusNode();
  dynamic data;
  bool loading = true;
  bool err = false;
  bool isOriginals = false;
  int page = 1;
  int size = 27;
  int count = 9;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadDate();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _errFocusNode.dispose();
    _nextFocusNode.dispose();
    _oneFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  //加载数据
  Future<void> loadDate() async {
    count = await Config().getCount();
    size = 3 * count;
    bool show = false;
    if (!loading) {
      show = true;
      showLoading("加载中");
    }
    try {
      String api ="/v1/api/thetv/sort?gallery_uid=${widget.galleryUid}&mode=updated_at&order=DESC&page=$page&size=$size";
      if (widget.dataType=="movie"){
        api ="/v1/api/themovie/sort?gallery_uid=${widget.galleryUid}&mode=updated_at&order=DESC&page=$page&size=$size";
      }
      Response response = await DioWrapper().post(api, null);
      if (response.data["code"] == 403) {
        Navigator.pushAndRemoveUntil(context,
            material.MaterialPageRoute(builder: (BuildContext context) {
          return const LoginScreen();
        }), (route) => route == null);
      } else if (response.data["code"] != 200) {
        setState(() {
          loading = false;
          err = true;
          _errFocusNode.requestFocus();
        });
        showMsg(response.data["msg"]);
      }
      data = response.data["data"];
      if (!loading) {
        show = false;
        Navigator.pop(context);
      }
      setState(() {
        loading = false;
        err = false;
      });
      // 等待UI更新完成后自动滚动到第一个元素
      Timer(const Duration(seconds: 1), () {
       try{
         _scrollController.animateTo(
           0,
           duration: const Duration(milliseconds: 500),
           curve: Curves.easeInOut,
         );
         _oneFocusNode.requestFocus();
       }catch(e){
         // debugPrint(e.toString());
       }
      });

    } catch (e) {
      setState(() {
        loading = false;
        err = true;
        _errFocusNode.requestFocus();
      });
      showMsg(e.toString());
      if (show) {
        Navigator.pop(context);
      }
    }
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

  //加载中
  void showLoading(String text) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Center(
            child: Container(
              decoration: BoxDecoration(
                  color: material.Colors.black54,
                  borderRadius: BorderRadius.circular(3.0),
                  boxShadow: const [
                    //阴影
                    BoxShadow(
                      color: material.Colors.black12,
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
                    child: material.CircularProgressIndicator(
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

  //视频卡片
  Widget listDataViews() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 210,
      child: GridView.builder(
        padding: const EdgeInsets.all(10.0),
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count, //每行三列
          childAspectRatio: 0.7, //显示区域宽高相等
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          final dynamic content = data[index];
          return MovieItemWidget(
            height: Config().getHeight(context, isOriginals, count),
            content: content,
            isOriginals: isOriginals,
            onItemSelected: () {
              if (index == 0) {
                _scrollController.animateTo(0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.linear);
              }
            },
            onItemPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryanimation) =>
                      DrillInPageTransition(
                    animation: animation,
                    child: DescriptionScreen(
                      content: content,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  //底部按钮组
  Widget footerView() {
    return Row(
      children: [
        const Expanded(child: SizedBox()),
        CustomIconButton(
          active: false,
          focusNode: FocusNode(),
          icon: FluentIcons.chevron_left,
          title: '',
          onSelected: () {},
          onClick: () {
            int newPage = page - 1;
            if (newPage >= 0) {
              page--;
              loadDate();
            }
            debugPrint("上一页");
          },
        ),
        CustomIconButton(
          active: false,
          focusNode: FocusNode(),
          icon: FluentIcons.chevron_right,
          title: '',
          onSelected: () {},
          onClick: () {
            page++;
            loadDate();
            debugPrint("下一页");
          },
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
          padding: Responsive.isMobile(context)
              ? const EdgeInsets.all(5.0)
              : const EdgeInsets.all(20.0),
          alignment: Alignment.center,
          child: SizedBox(
            child: loading
                ? const Loading()
                : err
                    ? SizedBox(
                        width: 340,
                        height: 120,
                        child: CustomIconButton(
                          active: true,
                          focusNode: _errFocusNode,
                          icon: FluentIcons.error,
                          title: "发生错误，点击返回",
                          onSelected: () {
                            debugPrint("返回");
                          },
                          onClick: () {
                            Navigator.pop(context);
                          },
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: HeaderTitleBar(title: widget.galleryTitle),
                              ),
                              const SizedBox(
                                width: 20,
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SingleChildScrollView(
                              child: Column(
                            children: [
                              data == null
                                  ? SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height -
                                              230,
                                      child: Center(
                                        child: SizedBox(
                                          width: 340,
                                          height: 120,
                                          child: CustomIconButton(
                                            active: false,
                                            focusNode: _errFocusNode,
                                            icon: FluentIcons.error,
                                            title: "没有内容咯，点击返回上一页",
                                            onSelected: () {
                                              debugPrint("返回");
                                            },
                                            onClick: () {
                                              int newPage = page - 1;
                                              if (newPage >= 0) {
                                                page--;
                                                loadDate();
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    )
                                  : listDataViews(),
                              const SizedBox(height: 20),
                              footerView(),
                              const SizedBox(height: 10),
                            ],
                          ))
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
