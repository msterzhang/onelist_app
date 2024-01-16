import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:fplayer/fplayer.dart';
import 'package:one_list_tv/screens/projection_screen.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../http/dio_http.dart';
import '../servers/servers.dart';
import '../utils/config.dart';
import '../utils/storage.dart';
import 'login_screen.dart';

class MobileVideoScreen extends StatefulWidget {
  final dynamic content;
  final dynamic episode;

  const MobileVideoScreen({Key? key, this.content, this.episode})
      : super(key: key);

  @override
  State<MobileVideoScreen> createState() => _MobileVideoScreenState();
}

class _MobileVideoScreenState extends State<MobileVideoScreen>
    with WidgetsBindingObserver {
  final FPlayer player = FPlayer();
  Map<String, String> headers = <String, String>{};

  // 视频索引,单个视频可不传
  int speedItem = 0;
  int seekTime = 0;
  String timeKey = "";
  int errNum = 10;
  bool start = false;
  bool isTv = false;
  String galleryHost = DioWrapper().getServer();
  String seasonName = "";
  int seasonId = 0;
  String speedKey = "";

  // 视频列表
  List<VideoItem> videoList = [];

  // 倍速列表
  Map<String, double> speedList = {
    "2.0": 2.0,
    "1.5": 1.5,
    "1.0": 1.0,
    "0.5": 0.5,
  };


  @override
  void initState() {
    super.initState();
    if (widget.content["name"] != null) {
      isTv = true;
    }
    getGalleryHost();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() async {
    super.dispose();
    try {
      await ScreenBrightness().resetScreenBrightness();
    } catch (e) {
      debugPrint(e.toString());
    }
    player.release();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: //从后台切换前台，界面可见
        player.start();
        break;
      case AppLifecycleState.paused: // 界面不可见，后台
        player.pause();
        break;
      case AppLifecycleState.detached: // APP结束时调用
        break;
    }
  }


  Future<void> getGalleryHost() async {
    try {
      String path = "/v1/api/gallery/host?id=${widget.content["gallery_uid"]}";
      Response response = await DioWrapper().post(path, null);
      if (response.data["code"] == 403) {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) {
              return const LoginScreen();
            }), (route) => route == null);
      } else if (response.data["code"] != 200) {
        showMsg(response.data["msg"]);
      }
      String data = response.data["data"];
      if (data.isNotEmpty) {
        galleryHost = data;
      }
      loadVideoList();
    } catch (e) {
      showMsg(e.toString());
    }
  }

  //清洗播放链接
  Future<String> loadUrl(String url) async {
    timeKey = isTv
        ? "${widget.content["id"]}_${seasonId}_$speedItem"
        : "${widget.content["id"]}";
    Storage().setIntData(speedKey, speedItem);
    seekTime = await Storage().getCurrentTime(timeKey);
    return url;
  }

  //  加载全部播放链接
  Future<void> loadVideoList() async {
    if(!widget.content["played"]){
      dynamic form = {
        "data_id": widget.content["id"],
        "data_type": isTv?"tv":"movie",
      };
      await Servers().server("played", form);
    }
    if (isTv) {
      String url = "";
      for (int index = 0;
      index < widget.episode["episodes"].length;
      index++) {
        url = galleryHost + widget.episode["episodes"][index]["url"];
        VideoItem videoItem = VideoItem(
          title: "第${index + 1}集",
          url: url,
        );
        videoList.add(videoItem);
      }
      seasonId = await Storage().getIntData("seasonId");
      seasonName = await Storage().getStringData("seasonName");
      speedKey = "${widget.content["id"]}_$seasonId";
      speedItem = await Storage().getIntData(speedKey);
    }else{
      String url = galleryHost + widget.content["url"];
      VideoItem videoItem = VideoItem(
        title: widget.content["title"],
        url: url,
      );
      videoList.add(videoItem);
    }
    setState(() {
      speedItem;
      start;
    });
    startPlay();
  }

  void startPlay() async {
    // 视频播放相关配置
    await player.setOption(FOption.hostCategory, "enable-snapshot", 1);
    await player.setOption(FOption.hostCategory, "request-screen-on", 1);
    await player.setOption(FOption.hostCategory, "request-audio-focus", 1);
    await player.setOption(FOption.playerCategory, "reconnect", 20);
    await player.setOption(FOption.playerCategory, "framedrop", 20);
    await player.setOption(FOption.playerCategory, "enable-accurate-seek", 1);
    await player.setOption(FOption.playerCategory, "mediacodec", 1);
    await player.setOption(FOption.playerCategory, "packet-buffering", 0);
    await player.setOption(FOption.playerCategory, "soundtouch", 1);

    setVideoUrl(videoList[speedItem].url);
  }

  //加载视频
  Future<void> setVideoUrl(String url) async {
    url = await loadUrl(url);
    try {
      await player.setDataSource(url,
          headers: headers, autoPlay: true, showCover: true);
    } catch (error) {
      showMsg("播放-异常: $error");
      return;
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

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double videoHeight = mediaQueryData.size.width * 9 / 16;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            FView(
              player: player,
              width: double.infinity,
              height: videoHeight,
              color: Colors.black,
              fsFit: FFit.contain,
              // 全屏模式下的填充
              fit: FFit.fill,
              // 正常模式下的填充
              panelBuilder: fPanelBuilder(
                // 单视频配置
                title: '视频标题',
                // 右下方截屏按钮
                isSnapShot: true,
                // 右上方按钮组开关
                isRightButton: true,
                // 右上方按钮组
                rightButtonList: [
                  InkWell(
                    onTap: () {
                      String url = player.dataSource.toString();
                      player.pause();
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryanimation) =>
                                  fluent.DrillInPageTransition(
                            animation: animation,
                            child: ProjectionScreen(
                              url: url,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(5),
                        ),
                      ),
                      child: const Icon(
                        Icons.airplay,
                        color: Config.fontColor,
                        size: 18,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showMsg("暂时未开发");
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(5),
                        ),
                      ),
                      child: const Icon(
                        Icons.download,
                        color: Config.fontColor,
                        size: 18,
                      ),
                    ),
                  )
                ],
                // 字幕功能：待内核提供api
                // caption: true,
                // 视频列表开关
                isVideos: true,
                // 视频列表列表
                videoList: videoList,
                // 当前视频索引
                videoIndex: speedItem,
                // 全屏模式下点击播放下一集视频按钮
                playNextVideoFun: () async {
                  speedItem++;
                  await player.reset();
                  setState(() {
                    speedItem;
                  });
                  setVideoUrl(videoList[speedItem].url);
                },
                settingFun: () {
                  print('设置按钮点击事件');
                },
                // 自定义倍速列表
                speedList: speedList,
                // 清晰度开关
                isResolution: false,
                // 自定义清晰度列表
                // resolutionList: resolutionList,
                // 视频播放错误点击刷新回调
                onError: () async {
                  if (errNum > 0) {
                    await player.reset();
                    setVideoUrl(videoList[speedItem].url);
                    errNum--;
                  } else {
                    showMsg("视频加载错误");
                  }
                },
                // 视频播放完成回调
                onVideoEnd: () async {
                  var index = speedItem + 1;
                  if (index < videoList.length) {
                    await player.reset();
                    setState(() {
                      speedItem = index;
                    });
                    setVideoUrl(videoList[index].url);
                  }
                },
                onVideoTimeChange: () {
                  int currentTime = player.currentPos.inMilliseconds;
                  Storage().setCurrentTime(timeKey, currentTime);
                },
                onVideoPrepared: () async {
                  try {
                    if (seekTime >= 1) {
                      await player.seekTo(seekTime);
                    }
                  } catch (error) {
                    print("视频初始化完快进-异常: $error");
                  }
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      //按钮组
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                player.stop();
                                String url = player.dataSource.toString();
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryanimation) =>
                                        fluent.DrillInPageTransition(
                                      animation: animation,
                                      child: ProjectionScreen(
                                        url: url,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.airplay,
                                      color: Config.fontColor,
                                      size: 26,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "投屏",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                              child: InkWell(
                            onTap: () {
                              showMsg("资源不支持");
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.download,
                                    color: Config.fontColor,
                                    size: 26,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text("下载",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w500,
                                      ))
                                ],
                              ),
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Text(
                            "选集",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          Text(
                            !isTv? '完结'
                                : "更新到第${widget.episode["episodes"].length}集",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 45,
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          itemCount: videoList.length,
                          itemBuilder: (context, index) {
                            bool isCurrent = speedItem == index;
                            Color textColor = Config.fontColor;
                            Color bgColor = Colors.transparent;
                            Color borderColor = Config.fontColor;
                            if (isCurrent) {
                              textColor = textColor = Config.fontColor;
                              bgColor = Config.mainColor;
                              borderColor = Config.mainColor;
                            }
                            return GestureDetector(
                              onTap: () async {
                                await player.reset();
                                Storage().setIntData(speedKey, speedItem);
                                setState(() {
                                  speedItem = index;
                                });
                                setVideoUrl(videoList[index].url);
                              },
                              child: Container(
                                width: 80,
                                margin:
                                    EdgeInsets.only(left: index == 0 ? 0 : 5),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: bgColor,
                                  border: Border.all(
                                    width: 1.5,
                                    color: borderColor,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  isTv?videoList[index].title:"超清",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Text(
                        widget.content["title"]??widget.content["name"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "年代:${widget.content["last_air_date"]??widget.content["release_date"]}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
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

                      Text("简介:${widget.content["overview"]}" ?? "简介:",
                          softWrap: true,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w300)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
