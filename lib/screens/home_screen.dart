import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:one_list_tv/cubits/cubits.dart';
import 'package:one_list_tv/http/dio_http.dart';
import 'package:one_list_tv/widgets/widgets.dart';

import '../utils/config.dart';
import '../widgets/icon_button.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController? _scrollController;
  final FocusNode _errFocusNode = FocusNode();
  dynamic previews;
  dynamic data;
  bool loading = true;
  bool err = false;
  int count = 9;

  //定时刷新主页
  late Timer _timer;
  bool initTimer = false;
  String dataType = "tv";

  @override
  void initState() {
    super.initState();
    loadPreview();
    _scrollController = ScrollController()..addListener(() {});
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _errFocusNode.dispose();
    _timer.cancel();
    super.dispose();
  }

  //加载数据
  Future<void> loadDate() async {
    count = await Config().getCount();
    try {
      Response response =
          await DioWrapper().post("/v1/api/app/index?page=1&size=24", null);
      if (response.data["code"] == 403) {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return const LoginScreen();
        }), (route) => route == null);
      } else if (response.data["code"] != 200) {
        setState(() {
          loading = false;
          err = true;
          _errFocusNode.requestFocus();
        });
        showMsg(response.data["msg"]);
      }else{
        if (!initTimer) {
          _timer = Timer.periodic(const Duration(minutes: 12), (t) {
            debugPrint("刷新主页");
            initTimer = true;
            loadDate();
          });
        }
        data = response.data["data"];
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        err = true;
        _errFocusNode.requestFocus();
      });
      showMsg(e.toString());
    }
  }

  Future<void> loadPreview() async {
    try {
      String path = "/v1/api/played/data/list?data_type=$dataType&page=1&size=18";
      Response response = await DioWrapper().post(path, null);
      if (response.data["code"] == 403) {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return const LoginScreen();
        }), (route) => route == null);
      } else if (response.data["code"] != 200) {
        setState(() {
          loading = false;
          err = true;
          _errFocusNode.requestFocus();
        });
        showMsg(response.data["msg"]);
      } else {
        setState(() {
          previews = response.data["data"];
          dataType=="tv"?loadDate():null;
        });
      }
    } catch (e) {
      showMsg(e.toString());
    }
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

  //轮播图
  Widget slideSliver(data) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.width * 0.8
            : MediaQuery.of(context).size.width * 0.34,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Swiper(
            itemBuilder: (context, index) {
              return ContentHeader(
                data: data[index],
                scrollToTop: () {
                  _scrollController?.animateTo(0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.linear);
                },
              );
            },
            autoplay: true,
            duration: 500,
            autoplayDelay: 10000,
            itemCount: data.length,
            pagination: const SwiperPagination(),
            // control: const SwiperControl(),
          ),
        ),
      ),
    );
  }

  //播放记录
  Widget previewSliver() {
    return SliverPadding(
      padding: Responsive.isMobile(context)
          ? const EdgeInsets.only(left: 0, right: 0)
          : const EdgeInsets.only(left: 50, right: 50),
      sliver: SliverToBoxAdapter(
        child: Previews(
          onClick: (){
            dataType=="tv"?dataType = "movie":dataType="tv";
            loadPreview();
          },
          count: count,
          key: const PageStorageKey('previews'),
          title: '已播放',
          contentList: previews,
        ),
      ),
    );
  }

  //资源列表
  List<Widget> listSliver(dynamic data, dynamic previews) {
    List<Widget> listData = [];
    //轮播图
    listData.add(slideSliver(previews));
    //播放记录
    listData.add(previewSliver());
    for (int index = 0; index < data.length; index++) {
      // print(data[index]);
      listData.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: Responsive.isMobile(context)
                ? const EdgeInsets.only(left: 0, right: 0)
                : const EdgeInsets.only(left: 50, right: 50),
            child: ContentList(
              gallery:data[index],
              count: count,
              more: true,
              key: PageStorageKey(data[index]["title"].toString()),
              title: data[index]["title"].toString(),
              isOriginals: kIsWeb,
              contentList: data[index]["gallery_type"] == "tv"
                  ? data[index]["the_tv_list"]
                  : data[index]["the_movie_list"],
            ),
          ),
        ),
      );
    }
    return listData;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, 70.0),
        child: BlocBuilder<AppBarCubit, double>(
          builder: (context, scrollOffset) {
            return CustomAppBar(scrollOffset: scrollOffset);
          },
        ),
      ),
      body: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: loading
            ? const Loading()
            : err
                ? SizedBox(
                    width: 380,
                    height: 120,
                    child: CustomIconButton(
                      active: false,
                      focusNode: _errFocusNode,
                      icon: fluent.FluentIcons.error,
                      title: "应用无法正常使用，点击退出重启",
                      onSelected: () {
                        debugPrint("退出");
                      },
                      onClick: () {
                        exit(0);
                      },
                    ),
                  )
                : RefreshIndicator(
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: listSliver(data, previews),
                    ),
                    onRefresh: () async {
                      loadDate();
                    },
                  ),
      ),
    );
  }
}
