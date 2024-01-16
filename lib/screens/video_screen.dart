import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:one_list_tv/widgets/icon_button.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import '../http/dio_http.dart';
import '../servers/servers.dart';
import '../utils/config.dart';
import '../utils/storage.dart';
import '../widgets/loading.dart';
import 'login_screen.dart';

class VideoScreen extends StatefulWidget {
  final dynamic content;
  final dynamic episode;

  const VideoScreen({Key? key, this.content, this.episode}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  double progress = 0;
  double speed = 1;
  late Timer _timer;
  late Timer _timerPlayControl;
  bool _timerInit = false;
  bool _timerPlayControlInit = false;
  bool _hidePlayControl = false;
  bool _isVideoLoading = true;
  bool _isVideoBuffering = false;
  bool _videoErr = false;
  bool _loadTime = false;
  bool isTv = false;
  bool loading = true;

  late final FocusNode _sliderFocusNode = FocusNode();
  late final FocusNode _errFocusNode = FocusNode();
  int errNum = 10;

  //视频url
  List<String> listUrl = [];
  int speedItem = 0;
  String url = "";
  String title = "";
  String timeKey = "";
  String speedKey = "";
  String galleryHost = DioWrapper().getServer();

  //电视剧相关信息
  String seasonName = "";
  int seasonId = 0;
  Map<String, String> headers = <String, String>{};

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    if (widget.content["name"] != null) {
      isTv = true;
    }
    getGalleryHost();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _timerInit ? _timer.cancel() : null;
    _timerPlayControlInit ? _timerPlayControl.cancel() : null;
    _sliderFocusNode.dispose();
    _errFocusNode.dispose();
    Wakelock.disable();
  }

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

  //监控视频加载，如果20s内未完成加载，则显示加载错误
  void watchPlayer() {
    Timer.periodic(const Duration(seconds: 20), (t) {
      if (!_controller.value.isInitialized) {
        try {
          setState(() {
            _isVideoLoading = false;
            _videoErr = true;
            _errFocusNode.requestFocus();
          });
        } catch (e) {
          // debugPrint(e.toString());
        }
      }
    });
  }

  //获取播放链接
  void loadUrl() {
    timeKey = isTv
        ? "${widget.content["id"]}_${seasonId}_$speedItem"
        : "${widget.content["id"]}";
    if (!isTv) {
      url = galleryHost + widget.content["url"];
    } else {
      if (widget.episode["episodes"].length > speedItem) {
        for (int index = 0;
            index < widget.episode["episodes"].length;
            index++) {
          if (index == speedItem) {
            url = galleryHost + widget.episode["episodes"][index]["url"];
          }
        }
        // debugPrint(url);
      } else {
        speedItem = 0;
      }
    }
    if (url.isEmpty) {
      showMsg("播放链接错误");
    }
  }

  //加载数据
  Future<void> loadData() async {
    if (isTv) {
      seasonId = await Storage().getIntData("seasonId");
      seasonName = await Storage().getStringData("seasonName");
      speedKey = "${widget.content["id"]}_$seasonId";
      speedItem = await Storage().getIntData(speedKey);
    }
    watchPlayer();
    initPlayer();

    if(!widget.content["played"]){
      dynamic form = {
        "data_id": widget.content["id"],
        "data_type": isTv?"tv":"movie",
      };
      await Servers().server("played", form);
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> getGalleryHost() async {
    try {
      String path = "/v1/api/gallery/host?id=${widget.content["gallery_uid"]}";
      Response response = await DioWrapper().post(path, null);
      if (response.data["code"] == 403) {
        Navigator.pushAndRemoveUntil(context,
            material.MaterialPageRoute(builder: (BuildContext context) {
          return const LoginScreen();
        }), (route) => route == null);
      } else if (response.data["code"] != 200) {
        setState(() {
          loading = false;
          _errFocusNode.requestFocus();
        });
        showMsg(response.data["msg"]);
      }
      String data = response.data["data"];
      if (data.isNotEmpty) {
        galleryHost = data;
      }
      loadData();
    } catch (e) {
      showMsg(e.toString());
    }
  }

  //初始化播放器
  Future<void> initPlayer() async {
    loadUrl();
    int currentTimeOld = await Storage().getCurrentTime(timeKey);
    if (_loadTime) {
      _controller.dispose();
    }
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: kIsWeb ? <String, String>{} : headers,
    )
      ..initialize().then((_) {
        _loadTime = true;
        _controller.seekTo(Duration(seconds: currentTimeOld));
        setState(() {
          _isVideoLoading = false;
          updateTime();
        });
      }).catchError((e) {
        debugPrint("controller.initialize() error occurs: $e");
        setState(() {
          _isVideoLoading = false;
          _videoErr = true;
          _errFocusNode.requestFocus();
        });
      })
      ..addListener(() {
        if (_controller.value.isBuffering) {
          setState(() {
            _isVideoBuffering = true;
          });
        } else {
          setState(() {
            _isVideoBuffering = false;
          });
        }
        if (_controller.value.hasError) {
          debugPrint("视频加载错误");
          restart();
        }
        if (_loadTime) {
          int currentTime = _controller.value.position.inSeconds;
          Storage().setCurrentTime(timeKey, currentTime);
        }
      })
      ..play();
    changePlayControl();
  }

  //重载视频
  Future<void> restart() async {
    if (_loadTime) {
      _controller.dispose();
    }
    int currentTimeOld = await Storage().getCurrentTime(timeKey);
    if (errNum > 0) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: kIsWeb ? <String, String>{} : headers,
      )
        ..initialize().then((_) {
          _controller.seekTo(Duration(seconds: currentTimeOld));
          _loadTime = true;
          setState(() {
            _isVideoLoading = false;
            updateTime();
          });
        }).catchError((e) {
          debugPrint("视频加载错误: $e");
          setState(() {
            _isVideoLoading = false;
            _videoErr = true;
            _errFocusNode.requestFocus();
          });
        })
        ..addListener(() {
          if (_controller.value.isBuffering) {
            setState(() {
              _isVideoBuffering = true;
            });
          } else {
            setState(() {
              _isVideoBuffering = false;
            });
          }
          if (_controller.value.hasError) {
            debugPrint("视频重载错误");
            restart();
          }
          if (_loadTime) {
            int currentTime = _controller.value.position.inSeconds;
            Storage().setCurrentTime(timeKey, currentTime);
          }
        })
        ..play();
    } else {
      setState(() {
        debugPrint("显示重载错误返回按钮!");
        _isVideoLoading = false;
        _videoErr = true;
        _errFocusNode.requestFocus();
      });
    }
    errNum--;
  }

  //加载中
  void showLoading(String text) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Center(
            child: Container(
              decoration: material.BoxDecoration(
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

  //更新时间
  void updateTime() async {
    _timerInit ? _timer.cancel() : null;
    _timer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (_controller.value.isPlaying) {
        int position = _controller.value.position.inSeconds;
        int duration = _controller.value.duration.inSeconds;
        setState(() {
          progress = (position / duration) * 100;
        });
        _timerInit = true;
      }
    });
  }

  //控制播放控件的显隐
  void changePlayControl() {
    _timerPlayControlInit ? _timerPlayControl.cancel() : null;
    _timerPlayControl = Timer(const Duration(seconds: 10), () {
      if (_controller.value.isPlaying) {
        try {
          setState(() {
            _hidePlayControl = true;
          });
        } catch (e) {
          // debugPrint("");
        }
      }
      _timerPlayControlInit = true;
    });
  }

  //改变播放状态
  void changePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _timer.cancel();
      } else {
        _controller.play();
        updateTime();
      }
      changePlayControl();
    });
  }

  //时间格式化
  String formatTime(int time) {
    int hours = time ~/ 3600;
    int minutes = (time % 3600) ~/ 60;
    int seconds = time % 60;
    String hoursStr = (hours < 10) ? '0$hours' : '$hours';
    String minutesStr = (minutes < 10) ? '0$minutes' : '$minutes';
    String secondsStr = (seconds < 10) ? '0$seconds' : '$seconds';
    return '$hoursStr:$minutesStr:$secondsStr';
  }

  //按键处理
  void _onKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (_sliderFocusNode.hasFocus) {
        if (event.logicalKey == LogicalKeyboardKey.mediaPlayPause ||
            event.logicalKey == LogicalKeyboardKey.enter) {
          changePlay();
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          _controller.setVolume(_controller.value.volume + 0.1);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          _controller.setVolume(_controller.value.volume - 0.1);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          setState(() {
            int position = _controller.value.position.inSeconds;
            int duration = _controller.value.duration.inSeconds;
            int number = position - 15;
            if (number < 0) {
              number = 0;
            }
            progress = number / duration * 100;
            _controller.seekTo(Duration(seconds: number));
            changePlayControl();
          });
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          setState(() {
            int position = _controller.value.position.inSeconds;
            int duration = _controller.value.duration.inSeconds;
            int number = position + 15;
            if (number >= duration) {
              number = duration;
            }
            progress = number / duration * 100;
            _controller.seekTo(Duration(seconds: number));
          });
        } else if (event.logicalKey == LogicalKeyboardKey.space) {
          changePlay();
        } else if (event.logicalKey == LogicalKeyboardKey.backspace ||
            event.logicalKey == LogicalKeyboardKey.escape) {
          _sliderFocusNode.nextFocus();
        }
      } else {
        if (event.logicalKey == LogicalKeyboardKey.enter) {
          _sliderFocusNode.requestFocus();
        } else if (event.logicalKey == LogicalKeyboardKey.backspace ||
            event.logicalKey == LogicalKeyboardKey.escape) {
          if (!_hidePlayControl) {
            Navigator.of(context).pop(true);
          }
        }
        setState(() {
          _hidePlayControl = false;
        });
      }
      //调节音量
      if (event.logicalKey == LogicalKeyboardKey.audioVolumeUp) {
        _controller.setVolume(_controller.value.volume + 0.1);
      } else if (event.logicalKey == LogicalKeyboardKey.audioVolumeDown ) {
        _controller.setVolume(_controller.value.volume - 0.1);
      }
      changePlayControl();
    }
  }

  //拖住进度条
  void onChangTime(double value) {
    setState(() {
      progress = value;
      int duration = _controller.value.duration.inSeconds;
      int position = progress * duration ~/ 100;
      _controller.seekTo(Duration(seconds: position));
      _controller.play();
    });
  }

  //获取进度条上的标签
  String getLab(double progress) {
    if (progress.isNaN) {
      return "";
    }
    if (kIsWeb) {
      return "${progress.toInt()}%";
    } else if (Platform.isWindows) {
      return "${progress.toInt()}%";
    } else {
      return "";
    }
  }

  //进度条
  Widget _slider() {
    if (progress.isNaN) {
      progress = 0;
    }
    return Slider(
      style: SliderThemeData(
          activeColor: ButtonState.all(Config.activeColor),
          inactiveColor: ButtonState.all(Config.fontColor)),
      focusNode: _sliderFocusNode,
      autofocus: true,
      label: getLab(progress),
      value: progress,
      onChangeStart: (v) => setState(() {
        _controller.pause();
        changePlayControl();
      }),
      onChangeEnd: (v) => setState(() {
        _controller.play();
        changePlayControl();
      }),
      onChanged: (double value) {
        if (kIsWeb) {
          onChangTime(value);
        } else if (Platform.isWindows) {
          onChangTime(value);
        }
      },
    );
  }

  //缓冲中
  Widget bufferLoading() {
    return Center(
      child: Container(
        decoration: material.BoxDecoration(
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
        constraints: const BoxConstraints(minHeight: 120, minWidth: 160),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 30,
              width: 30,
              child: material.CircularProgressIndicator(
                strokeWidth: 3,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "缓冲中",
                style: TextStyle(
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
  }

  //播放器所有按钮
  Widget _playButtons() {
    return Column(
      children: [
        Row(
          children: [
            Text(formatTime(_controller.value.position.inSeconds),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w300)),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: _slider(),
            ),
            const SizedBox(
              width: 20,
            ),
            Text(formatTime(_controller.value.duration.inSeconds),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w300)),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            const Expanded(child: SizedBox()),
            const SizedBox(
              width: 10,
            ),
            isTv
                ? RoundIconButton(
                    icon: FluentIcons.previous,
                    title: "",
                    size: 28,
                    color: Colors.white,
                    onSelected: () {
                      debugPrint("上一集");
                    },
                    onClick: () {
                      speedItem--;
                      if (speedItem < 0) {
                        speedItem = 0;
                      }
                      Storage().setIntData(speedKey, speedItem);
                      initPlayer();
                    },
                  )
                : const SizedBox(),
            const SizedBox(
              width: 10,
            ),
            //快退
            RoundIconButton(
              icon: FluentIcons.double_chevron_left_med,
              title: "",
              size: 28,
              color: Colors.white,
              onSelected: () {
                debugPrint("快退");
              },
              onClick: () {
                int position = _controller.value.position.inSeconds;
                int duration = _controller.value.duration.inSeconds;
                int number = position - 15;
                if (number < 0) {
                  number = 0;
                }
                progress = number / duration * 100;
                _controller.seekTo(Duration(seconds: number));
                changePlayControl();
              },
            ),
            const SizedBox(
              width: 10,
            ),
            RoundIconButton(
              icon: _controller.value.isPlaying
                  ? FluentIcons.pause
                  : FluentIcons.play_solid,
              title: "",
              size: 28,
              color: Colors.white,
              onSelected: () {},
              onClick: () {
                changePlay();
              },
            ),
            const SizedBox(
              width: 10,
            ),
            //快进
            RoundIconButton(
              icon: FluentIcons.double_chevron_left_med_mirrored,
              title: "",
              size: 28,
              color: Colors.white,
              onSelected: () {
                debugPrint("快进");
              },
              onClick: () {
                int position = _controller.value.position.inSeconds;
                int duration = _controller.value.duration.inSeconds;
                int number = position + 15;
                if (number < 0) {
                  number = 0;
                }
                progress = number / duration * 100;
                _controller.seekTo(Duration(seconds: number));
                changePlayControl();
              },
            ),
            const SizedBox(
              width: 10,
            ),
            isTv
                ? RoundIconButton(
                    icon: FluentIcons.next,
                    title: "",
                    size: 28,
                    color: Colors.white,
                    onSelected: () {
                      debugPrint("下一集");
                    },
                    onClick: () {
                      speedItem++;
                      Storage().setIntData(speedKey, speedItem);
                      initPlayer();
                    },
                  )
                : const SizedBox(),
            const SizedBox(
              width: 10,
            ),
            RoundIconButton(
              icon: FluentIcons.focus_view,
              title: "",
              size: 28,
              color: Colors.white,
              onSelected: () {
                debugPrint("返回");
              },
              onClick: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : SizedBox(
            child: _isVideoLoading
                ? Container(
                    color: Colors.black,
                    child: const Center(
                      child: VideoLoading(),
                    ),
                  )
                : _videoErr
                    ? Container(
                        color: Colors.black,
                        child: Center(
                          child: SizedBox(
                            width: 340,
                            height: 120,
                            child: CustomIconButton(
                              active: true,
                              focusNode: _errFocusNode,
                              icon: FluentIcons.error,
                              title: "视频链接播放错误，点击返回",
                              onSelected: () {
                                debugPrint("返回");
                              },
                              onClick: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.black,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _hidePlayControl = false;
                              changePlayControl();
                            });
                          },
                          child: RawKeyboardListener(
                            focusNode: FocusNode(),
                            onKey: kIsWeb ? null : _onKey,
                            child: Stack(
                              children: [
                                Center(
                                  child: Container(
                                    color: Colors.black,
                                    child: AspectRatio(
                                      aspectRatio:
                                          _controller.value.aspectRatio,
                                      child: VideoPlayer(_controller),
                                    ),
                                  ),
                                ),
                                //顶部标题
                                _hidePlayControl
                                    ? Container()
                                    : Container(
                                        padding: const EdgeInsets.only(
                                            left: 20, top: 20),
                                        child: Row(
                                          children: [
                                            IconButton(
                                                iconButtonMode:
                                                    IconButtonMode.large,
                                                icon: const Icon(
                                                  FluentIcons.back,
                                                  color: Colors.white,
                                                  size: 30.0,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                }),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                                isTv
                                                    ? "第${speedItem + 1}集"
                                                    : widget.content["title"],
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 28.0,
                                                    fontWeight:
                                                        FontWeight.w300)),
                                          ],
                                        ),
                                      ),
                                _hidePlayControl
                                    ? Container()
                                    : Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: 120,
                                          padding: const EdgeInsets.only(
                                              top: 16, left: 8, right: 8),
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              begin:
                                                  FractionalOffset.bottomCenter,
                                              end: FractionalOffset.topCenter,
                                              colors: [
                                                Colors.black,
                                                Colors.transparent
                                              ],
                                              stops: [0.0, 1],
                                            ),
                                          ),
                                          child: _playButtons(),
                                        ),
                                      ),
                                _isVideoBuffering
                                    ? bufferLoading()
                                    : _hidePlayControl
                                        ? Container()
                                        : Center(
                                            child: SizedBox(
                                              height: 100,
                                              width: 100,
                                              child: Row(
                                                children: [
                                                  const Expanded(
                                                      child: SizedBox()),
                                                  RoundIconButton(
                                                    icon: _controller
                                                            .value.isPlaying
                                                        ? FluentIcons
                                                            .circle_pause
                                                        : FluentIcons
                                                            .m_s_n_videos,
                                                    title: "",
                                                    size: 80,
                                                    color: Config.mainColor,
                                                    onSelected: () {},
                                                    onClick: () {
                                                      changePlay();
                                                    },
                                                  ),
                                                  const Expanded(
                                                      child: SizedBox()),
                                                ],
                                              ),
                                            ),
                                          ),
                              ],
                            ),
                          ),
                        ),
                      ),
          );
  }
}
