import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent_ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fullscreen_window/fullscreen_window.dart';
import 'package:one_list_tv/widgets/responsive.dart';

import '../screens/search_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/user_data_screen.dart';
import '../utils/assets.dart';
import '../utils/config.dart';
import 'icon_button.dart';

class CustomAppBar extends StatelessWidget {
  final double scrollOffset;

  const CustomAppBar({
    Key? key,
    this.scrollOffset = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: FractionalOffset.bottomCenter,
          end: FractionalOffset.topCenter,
          colors: [Colors.transparent, Colors.black],
          stops: [0.0, 0.9],
        ),
      ),
      padding: Responsive.isMobile(context)
          ? const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 5.0,
            )
          : const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 24.0,
            ),
      child: Responsive(
        mobile: _CustomAppBarMobile(),
        desktop: const _CustomAppBarDesktop(),
        androidTv: const _CustomAppBarDesktop(),
      ),
    );
  }
}

class _CustomAppBarMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          Config.textLogo
              ? const Text(
                  Config.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : SizedBox(
                  width: 40,
                  child: Image.asset(Assets.netflixLogoMin),
                ),
          const Expanded(child: SizedBox()),
          fluent_ui.IconButton(
              iconButtonMode: fluent_ui.IconButtonMode.large,
              icon: const Icon(
                fluent_ui.FluentIcons.search,
                color: Colors.white,
                size: 30.0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryanimation) =>
                        fluent_ui.DrillInPageTransition(
                      animation: animation,
                      child: const SearchScreen(),
                    ),
                  ),
                );
                // debugPrint("搜索");
              }),
          const SizedBox(width: 20.0),
          fluent_ui.IconButton(
              iconButtonMode: fluent_ui.IconButtonMode.large,
              icon: const Icon(
                fluent_ui.FluentIcons.player_settings,
                color: Colors.white,
                size: 30.0,
              ),
              onPressed: () {
                // debugPrint("用户设置");
                // SettingScreen
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryanimation) =>
                        fluent_ui.DrillInPageTransition(
                      animation: animation,
                      child: const SettingScreen(),
                    ),
                  ),
                );
              }),
          const SizedBox(width: 10.0),
        ],
      ),
    );
  }
}

class _CustomAppBarDesktop extends StatefulWidget {
  const _CustomAppBarDesktop({Key? key}) : super(key: key);

  @override
  State<_CustomAppBarDesktop> createState() => _CustomAppBarDesktopState();
}

class _CustomAppBarDesktopState extends State<_CustomAppBarDesktop> {
  bool full = false;

  //是否显示全屏及非全屏按钮
  Widget showFull() {
    return kIsWeb || Platform.isWindows
        ? !full
            ? fluent_ui.IconButton(
                iconButtonMode: fluent_ui.IconButtonMode.large,
                icon: const Icon(
                  fluent_ui.FluentIcons.full_screen,
                  color: Colors.white,
                  size: 30.0,
                ),
                onPressed: () {
                  FullScreenWindow.setFullScreen(true);
                  setState(() {
                    full = true;
                  });
                })
            : fluent_ui.IconButton(
                iconButtonMode: fluent_ui.IconButtonMode.large,
                icon: const Icon(
                  fluent_ui.FluentIcons.back_to_window,
                  color: Colors.white,
                  size: 30.0,
                ),
                onPressed: () {
                  FullScreenWindow.setFullScreen(false);
                  setState(() {
                    full = false;
                  });
                })
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          Config.textLogo
              ? const Text(
                  Config.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Image.asset(Assets.netflixLogoMax),
          const SizedBox(width: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 20.0),
              CustomIconButton(
                active: false,
                title: '已播放',
                focusNode: FocusNode(),
                onSelected: () {
                  debugPrint('Play');
                },
                onClick: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryanimation) =>
                          fluent_ui.DrillInPageTransition(
                        animation: animation,
                        child: const UserDataScreen(
                          userDataType: "played",
                            title: "已播放"
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 20.0),
              CustomIconButton(
                active: false,
                title: '已收藏',
                focusNode: FocusNode(),
                onSelected: () {
                  debugPrint('已收藏');
                },
                onClick: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryanimation) =>
                          fluent_ui.DrillInPageTransition(
                        animation: animation,
                            child: const UserDataScreen(
                              userDataType: "star",
                                title: "已收藏"
                            ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 20.0),
              CustomIconButton(
                active: false,
                title: '最爱',
                focusNode: FocusNode(),
                onSelected: () {
                  debugPrint('最爱');
                },
                onClick: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryanimation) =>
                          fluent_ui.DrillInPageTransition(
                            animation: animation,
                            child: const UserDataScreen(
                              userDataType: "heart",
                                title: "最爱"
                            ),
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              fluent_ui.IconButton(
                  iconButtonMode: fluent_ui.IconButtonMode.large,
                  icon: const Icon(
                    fluent_ui.FluentIcons.search,
                    color: Colors.white,
                    size: 30.0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryanimation) =>
                            fluent_ui.DrillInPageTransition(
                          animation: animation,
                          child: const SearchScreen(),
                        ),
                      ),
                    );
                    // debugPrint("搜索");
                  }),
              const SizedBox(width: 20.0),
              fluent_ui.IconButton(
                  iconButtonMode: fluent_ui.IconButtonMode.large,
                  icon: const Icon(
                    fluent_ui.FluentIcons.player_settings,
                    color: Colors.white,
                    size: 30.0,
                  ),
                  onPressed: () {
                    // debugPrint("用户设置");
                    // SettingScreen
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryanimation) =>
                            fluent_ui.DrillInPageTransition(
                          animation: animation,
                          child: const SettingScreen(),
                        ),
                      ),
                    );
                  }),
              kIsWeb || Platform.isWindows
                  ? const SizedBox(width: 20.0)
                  : Container(),
              showFull()
            ],
          ),
        ],
      ),
    );
  }
}
