import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_list_tv/cubits/app_bar/app_bar_cubit.dart';
import 'package:one_list_tv/screens/search_screen.dart';
import 'package:one_list_tv/screens/settings_screen.dart';

import 'package:one_list_tv/screens/user_data_screen.dart';
import 'package:one_list_tv/widgets/responsive.dart';

import 'home_screen.dart';

class NavScreen extends StatefulWidget {
  @override
  _NavScreenState createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  final List<Widget> _screens = [
    const HomeScreen(key: PageStorageKey('homeScreen')),
    const UserDataScreen(key: PageStorageKey('playerScreen'),userDataType: "star",title: "收藏"),
    const UserDataScreen(key: PageStorageKey('playerScreen'),userDataType: "played",title:"已播放"),
    const SearchScreen(key: PageStorageKey('searchScreen')),
    const SettingScreen(key: PageStorageKey('settingScreen')),
  ];

  final Map<String, IconData> _icons = const {
    '主页': Icons.home,
    '收藏': Icons.star,
    '已播放': Icons.add_box_rounded,
    '搜索': Icons.search,
    '设置': Icons.settings,
  };

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: BlocProvider<AppBarCubit>(
        create: (_) => AppBarCubit(),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: !Responsive.isDesktop(context)
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.black,
              items: _icons
                  .map((title, icon) => MapEntry(
                      title,
                      BottomNavigationBarItem(
                        icon: Icon(icon, size: 30.0),
                        label: title,
                      )))
                  .values
                  .toList(),
              currentIndex: _currentIndex,
              selectedItemColor: Colors.white,
              selectedFontSize: 11.0,
              unselectedItemColor: Colors.grey,
              unselectedFontSize: 11.0,
              onTap: (index) => setState(() => _currentIndex = index),
            )
          : null,
    );
  }
}
