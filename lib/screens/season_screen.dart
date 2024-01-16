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
import '../utils/assets.dart';
import '../utils/config.dart';
import '../widgets/loading.dart';
import '../widgets/responsive.dart';
import 'login_screen.dart';
import 'mobile_video_screen.dart';

class SeasonScreen extends StatefulWidget {
  final dynamic content;
  final int seasonId;
  final String seasonName;

  const SeasonScreen({
    Key? key,
    required this.content,
    required this.seasonId,
    required this.seasonName,
  }) : super(key: key);

  @override
  State<SeasonScreen> createState() => _SeasonScreenState();
}

class _SeasonScreenState extends State<SeasonScreen>
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
  String speedKey = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
    loadDate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      !kIsWeb && loading ? _playFocusNode.requestFocus() : null;
    });
  }

  void initTabs() {
    heart = widget.content["heart"];
    played = widget.content["played"];
    star = widget.content["star"];
    form = {
      "data_id": widget.content["id"],
      "data_type": "tv",
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

  Future<void> initData() async {
    //存当前季信息
    await Storage().setIntData("seasonId", widget.seasonId);
    await Storage().setStringData("seasonName", widget.seasonName);
    speedKey = "${widget.content["id"]}_${widget.seasonId}";
    speedItem = await Storage().getIntData(speedKey);
  }

  //加载数据
  Future<void> loadDate() async {
    try {
      String path = "/v1/api/theseason/id?id=${widget.seasonId}";
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

  Widget btnList() {
    return Row(
      children: [
        CustomIconButton(
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
                  pageBuilder: (context, animation, secondaryanimation) =>
                      DrillInPageTransition(
                    animation: animation,
                    child: MobileVideoScreen(
                      content: widget.content,
                      episode: data,
                    ),
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryanimation) =>
                      DrillInPageTransition(
                    animation: animation,
                    child: VideoScreen(
                      content: widget.content,
                      episode: data,
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
          icon: played ? material.Icons.done : material.Icons.done,
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
          icon:
              star ? FluentIcons.favorite_star_fill : FluentIcons.favorite_star,
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
          icon: heart ? FluentIcons.heart_fill : FluentIcons.heart,
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
                        widget.content["title"] ?? widget.content["name"],
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
                        widget.seasonName,
                        softWrap: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "评分:${widget.content["vote_average"].toStringAsFixed(1)}" ??
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
                        "标签:${widget.content["video_tags"]}" ?? "标签:",
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
                              widget.content["title"] ?? widget.content["name"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                widget.seasonName,
                                softWrap: true,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              "评分:${widget.content["vote_average"].toStringAsFixed(1)}" ??
                                  "评分:",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                                "发行时间:${widget.content["release_date"] ?? widget.content["last_air_date"]}" ??
                                    "标签:",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                )),
                            Text("标签:${widget.content["video_tags"]}" ?? "标签:",
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

  //选集按钮
  List<Widget> listViews() {
    List<Widget> listData = [];
    for (int index = 0; index < data["episodes"].length; index++) {
      dynamic episode = data["episodes"][index];
      Widget card = Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              height: MediaQuery.of(context).size.width * 0.3 * 9 / 16,
              width: MediaQuery.of(context).size.width * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                image: episode["still_path"].length != 0
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(
                            "${DioWrapper().getServer()}/t/p/w710_and_h400_multi_faces${episode["still_path"]}"),
                        fit: BoxFit.cover,
                      )
                    : const DecorationImage(
                        image: AssetImage(Assets.noCard),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${index + 1}.${episode["name"]}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  episode["overview"].length != 0
                      ? Text(
                          "简介:${episode["overview"]}",
                          softWrap: true, // 允许自动换行
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Text("简介:无",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            CustomIconButton(
              active: speedItem == index,
              icon: FluentIcons.play,
              title: '播放',
              focusNode: FocusNode(),
              onSelected: () {
                // debugPrint('Play');
              },
              onClick: () async {
                await Storage().setIntData(speedKey, index);
                if (Responsive.isMobile(context)) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryanimation) =>
                          DrillInPageTransition(
                            animation: animation,
                            child: MobileVideoScreen(
                              content: widget.content,
                              episode: data,
                            ),
                          ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryanimation) =>
                          DrillInPageTransition(
                            animation: animation,
                            child: VideoScreen(
                              content: widget.content,
                              episode: data,
                            ),
                          ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(
              width: 40,
            ),
          ],
        ),
      );
      listData.add(card);
    }
    return listData;
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
            // color: Colors.black,
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
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const SizedBox(
                              height: 30,
                            ),
                            videoData(),
                            const SizedBox(
                              height: 20,
                            ),
                            const SizedBox(
                              height: 50,
                              child: Text("剧集信息",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                            Column(
                              children: listViews(),
                            )
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }
}
