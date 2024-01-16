import 'dart:io';
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:one_list_tv/screens/register_screen.dart';
import 'package:provider/provider.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';
import 'package:window_manager/window_manager.dart';

import '../utils/config.dart';
import 'theme.dart';

/// Checks if the current environment is a desktop environment.
bool get isDesktop {
  if (kIsWeb) return true;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
    //TargetPlatform.android,
  ].contains(defaultTargetPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemTheme.accentColor.load();
  if (!kIsWeb) {
    if (isDesktop) {
      await flutter_acrylic.Window.initialize();
      await WindowManager.instance.ensureInitialized();
      windowManager.waitUntilReadyToShow().then((_) async {
        await windowManager.setTitleBarStyle(
          TitleBarStyle.normal,
          windowButtonVisibility: true,
        );
        await windowManager.setSize(const Size(1100, 800));
        await windowManager.setMinimumSize(const Size(1100, 800));
        await windowManager.center();
        await windowManager.show();
        await windowManager.setPreventClose(false);
        await windowManager.setSkipTaskbar(false);
        await windowManager.setTitle(Config.title);
      });
    }
    if (Platform.isWindows && !kIsWeb) {
      initVideoPlayerMediaKitIfNeeded(
          androidUseMediaKit: true, logLevel: MPVLogLevel.warn);
      // FullScreenWindow.setFullScreen(true);
    }
  }
  runApp(const MyApp());
}

//支持电脑及web鼠标滑动
class MyCustomScrollBehavior extends material.MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => AppTheme(),
        builder: (context, _) {
          return kIsWeb
              ? FluentApp(
                  title: Config.title,
                  scrollBehavior: MyCustomScrollBehavior(),
                  debugShowCheckedModeBanner: false,
                  darkTheme: FluentThemeData(
                    brightness: Brightness.dark,
                    accentColor: Colors.green,
                    visualDensity: VisualDensity.standard,
                    focusTheme: const FocusThemeData(
                      glowFactor: 0.0,
                      primaryBorder: BorderSide(
                        width: 3,
                        color: Config.mainColor,
                      ),
                    ),
                  ),
                  theme: FluentThemeData(
                    brightness: Brightness.dark,
                    accentColor: Colors.green,
                    visualDensity: VisualDensity.standard,
                    focusTheme: const FocusThemeData(
                      glowFactor: 0.0,
                      primaryBorder: BorderSide(
                        width: 3,
                        color: Config.mainColor,
                      ),
                    ),
                  ),
                  home: const RegisterScreen(),
                )
              : Shortcuts(
                  shortcuts: <LogicalKeySet, Intent>{
                      LogicalKeySet(LogicalKeyboardKey.select):
                          const ActivateIntent()
                    },
                  child: FluentApp(
                    title: Config.title,
                    scrollBehavior: MyCustomScrollBehavior(),
                    debugShowCheckedModeBanner: false,
                    darkTheme: FluentThemeData(
                      brightness: Brightness.dark,
                      accentColor: Colors.green,
                      visualDensity: VisualDensity.standard,
                      focusTheme: const FocusThemeData(
                        glowFactor: 0.0,
                        primaryBorder: BorderSide(
                          width: 3,
                          color: Config.mainColor,
                        ),
                      ),
                    ),
                    theme: FluentThemeData(
                      brightness: Brightness.dark,
                      accentColor: Colors.green,
                      visualDensity: VisualDensity.standard,
                      focusTheme: const FocusThemeData(
                        glowFactor: 0.0,
                        primaryBorder: BorderSide(
                          width: 3,
                          color: Config.mainColor,
                        ),
                      ),
                    ),
                    home: const RegisterScreen(),
                  ));
        });
  }
}
