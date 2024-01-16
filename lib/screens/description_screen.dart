import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:one_list_tv/screens/video_screen.dart';
import 'package:one_list_tv/utils/storage.dart';
import 'package:one_list_tv/widgets/icon_button.dart';

import '../http/dio_http.dart';
import '../servers/servers.dart';
import '../utils/config.dart';
import '../widgets/content_list.dart';
import '../widgets/loading.dart';
import '../widgets/person_list.dart';
import '../widgets/responsive.dart';
import '../widgets/season_list.dart';
import 'login_screen.dart';
import 'mobile_video_screen.dart';

class DescriptionScreen extends StatefulWidget {
  final dynamic content;

  const DescriptionScreen({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  State<DescriptionScreen> createState() => _DescriptionScreenState();
}

class _DescriptionScreenState extends State<DescriptionScreen>
    with WidgetsBindingObserver {
  late final FocusNode _playFocusNode = FocusNode();
  final FocusNode _errFocusNode = FocusNode();
  late final FocusNode _nextFocusNode = FocusNode();
  int speedItem = 0;
  dynamic previews;
  dynamic data;
  bool loading = true;
  bool err = false;
  //视频相关操作
  bool star = false;
  bool played = false;
  bool heart = false;
  dynamic form;

  int count = 9;
  bool isTv = false;
  late StateSetter _reloadTextSetter;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadDate();
    if (widget.content["name"]!=null){
      isTv = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      !kIsWeb && loading ? _playFocusNode.requestFocus() : null;
    });
  }

  void initTabs(){
    heart = data["heart"];
    played = data["played"];
    star = data["star"];
    form = {
      "data_id": data["id"],
      "data_type": isTv?"tv":"movie",
    };
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _playFocusNode.dispose();
    _errFocusNode.dispose();
    _nextFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  //加载数据
  Future<void> loadDate() async {
    count = await Config().getCount();
    try {
      String path = isTv
          ? "/v1/api/thetv/id?id=${widget.content["id"]}"
          : "/v1/api/themovie/id?id=${widget.content["id"]}";
      Response response = await DioWrapper().post(path, null);
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

      previews = response.data["like"];
      data = response.data["data"];
      //初始化收藏情况
      initTabs();
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        err = true;
        _errFocusNode.requestFocus();
      });
      showMsg(e.toString());
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

  Widget btnList(){
    return Row(
      children: [
        isTv?const SizedBox():CustomIconButton(
          active: false,
          icon: FluentIcons.play,
          title: '播放',
          focusNode: _playFocusNode,
          onSelected: () {
            // debugPrint('Play');
          },
          onClick: () {
            if (Responsive.isMobile(context)) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation,
                      secondaryanimation) =>
                      DrillInPageTransition(
                        animation: animation,
                        child: MobileVideoScreen(
                          content: data,
                          episode: null,
                        ),
                      ),
                ),
              );
            } else {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation,
                      secondaryanimation) =>
                      DrillInPageTransition(
                        animation: animation,
                        child: VideoScreen(
                          content: data,
                          episode: null,
                        ),
                      ),
                ),
              );
            }
          },
        ),
        //操作台
        CustomIconButton(
          active: played,
          focusNode: FocusNode(),
          icon: played
              ? material.Icons.done
              : material.Icons.done,
          title: '已播放',
          onSelected: () {
            debugPrint('已播放');
          },
          onClick: () async {
            _playFocusNode.requestFocus();
            bool complete = false;
            complete = await Servers().server("played", form);
            setState(() {
              if (complete) {
                played = !played;
              }
            });
          },
        ),
        CustomIconButton(
          active: star,
          focusNode: FocusNode(),
          icon: star
              ? FluentIcons.favorite_star_fill
              : FluentIcons.favorite_star,
          title: '收藏',
          onSelected: () {
            debugPrint('收藏');
          },
          onClick: () async {
            _playFocusNode.requestFocus();
            bool complete = false;
            complete = await Servers().server("star", form);
            setState(() {
              if (complete) {
                star = !star;
              }
            });
          },
        ),
        CustomIconButton(
          active: heart,
          focusNode: FocusNode(),
          icon: heart
              ? FluentIcons.heart_fill
              : FluentIcons.heart,
          title: '最爱',
          onSelected: () {
            debugPrint('最爱');
          },
          onClick: () async {
            _playFocusNode.requestFocus();
            bool complete = false;
            complete = await Servers().server("heart", form);
            setState(() {
              if (complete) {
                heart = !heart;
              }
            });
          },
        ),
      ],
    );
  }

  //视频信息
  Widget videoData() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Responsive.isMobile(context)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Container(
                        height: 280.0,
                        width: 200.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                "${DioWrapper().getServer()}/t/p/w220_and_h330_face${widget.content["poster_path"]}"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        data["title"] ?? data["name"],
                        softWrap: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "评分:${data["vote_average"].toStringAsFixed(1)}" ??
                            "评分:",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "发行时间:${data["release_date"] ?? data["last_air_date"]}" ??
                            "发行时间:",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text("简介:${widget.content["overview"]}" ?? "简介:",
                          softWrap: true, // 允许自动换行
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: btnList(),
                      ),
                    )
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 320.0,
                      width: 200.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                              "${DioWrapper().getServer()}/t/p/w220_and_h330_face${widget.content["poster_path"]}"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 320.0,
                      width: 650,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, left: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              data["title"] ?? data["name"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "评分:${data["vote_average"].toStringAsFixed(1)}" ??
                                  "评分:",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                                "发行时间:${data["release_date"] ?? data["last_air_date"]}" ??
                                    "发行时间:",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                )),
                            // release_date
                            Text("简介:${widget.content["overview"]}" ?? "简介:",
                                softWrap: true, // 允许自动换行
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold)),
                            const Expanded(child: SizedBox()),
                            btnList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        Responsive.isMobile(context)
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                    iconButtonMode: IconButtonMode.large,
                    icon: const Icon(
                      FluentIcons.back,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              )
      ],
    );
  }

  //电视剧分季
  Widget seasonsSliver(dynamic seasons,String title) {
    return SeasonList(
      data: data,
      count: count,
      key: PageStorageKey(title),
      more: false,
      title: title,
      isOriginals: kIsWeb,
      contentList: seasons,
    );
  }

  //演职人员
  Widget personsSliver(dynamic persons,String title) {
    return PersonList(
      count: count,
      key: PageStorageKey(title),
      more: false,
      title: title,
      isOriginals: kIsWeb,
      contentList: persons,
    );
  }

  //推荐视频
  Widget previewsSliver(dynamic previews, String title) {
    return ContentList(
      gallery: null,
      count: count,
      key: PageStorageKey(title),
      more: false,
      title: title,
      isOriginals: kIsWeb,
      contentList: previews,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            image: DecorationImage(
              opacity: 0.3,
              image: CachedNetworkImageProvider(
                  "${DioWrapper().getServer()}/t/p/w1920_and_h1080_bestv2${widget.content["backdrop_path"]}"),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: Responsive.isMobile(context)
                ? const EdgeInsets.all(5.0)
                : const EdgeInsets.all(20.0),
            alignment: Alignment.center,
            child: SingleChildScrollView(
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
                              height: 30,
                            ),
                            videoData(),
                            const SizedBox(
                              height: 20,
                            ),
                            // listViews(data),
                            const SizedBox(
                              height: 20,
                            ),
                            isTv?seasonsSliver(data["the_seasons"],"分季"):const SizedBox(),
                            const SizedBox(
                              height: 20,
                            ),
                            personsSliver(data["the_persons"], "演职人员"),
                            const SizedBox(
                              height: 20,
                            ),
                            previewsSliver(previews, "推荐"),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }
}
