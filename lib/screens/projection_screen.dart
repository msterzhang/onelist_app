import 'dart:async';

import 'package:dlna_dart/dlna.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../utils/config.dart';

class ProjectionScreen extends StatefulWidget {
  const ProjectionScreen({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  _ProjectionScreenState createState() => _ProjectionScreenState();
}

class _ProjectionScreenState extends State<ProjectionScreen> {
  bool load = true;
  bool search = false;
  bool ok = false;
  late DLNAManager dlnaManager;
  late Map<String, DLNADevice> _devices;
  late DLNADevice _dlnaDevice;
  late Set<String> names;
  String msg = "读取设备中";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  showMsg(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          '成功信息！',
          style: TextStyle(color: Config.fontColor),
        ),
        content: Text(
          msg,
          style: const TextStyle(color: Config.fontColor),
        ),
        actions: <Widget>[
          FilledButton(
            child: const Text(
              "确定",
              style: TextStyle(color: Config.fontColor),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> loadData() async {
    setState(() {
      msg = "检测设备中";
      load = true;
    });
    dlnaManager = DLNAManager();
    final m = await dlnaManager.start();
    m.devices.stream.listen((deviceList) {
      if (deviceList.isNotEmpty) {
        ok = true;
        _devices = deviceList;
        names = deviceList.keys.toSet();
        // deviceList.forEach((key, value) async {
        //   if (value.info.friendlyName.contains('Wireless')) return;
        dlnaManager.stop();
        setState(() {
          msg = "已检测到设备!";
          load = false;
        });
      }
    });

    // close the server,the closed server can be start by call searcher.start()
    Timer(const Duration(seconds: 60), () {
      dlnaManager.stop();
      if (!ok) {
        setState(() {
          msg = "未检测到设备!";
          load = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          msg,
          style: const TextStyle(color: Config.fontColor),
        ),
      ),
      body: load
          ? Container(
              alignment: Alignment.topCenter,
              child: const SpinKitRipple(color: Colors.white, size: 150.0),
            )
          : ok
              ? RefreshIndicator(
                  onRefresh: loadData,
                  child: Container(
                    alignment: Alignment.center,
                    child: ListView.builder(
                        itemCount: _devices.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: const Padding(
                              padding: EdgeInsets.only(top:8),
                              child: Icon(
                                Icons.airplay,
                                color: Config.fontColor,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              index < 9
                                  ? "投屏设备0${index + 1}"
                                  : "投屏设备${index + 1}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                                _devices[names.toList()[index]]!.info.friendlyName,
                                style: const TextStyle(color: Colors.white)
                            ),
                            trailing: const Icon(
                              Icons.keyboard_arrow_right,
                              color: Config.fontColor,
                              size: 24,
                            ),
                            onTap: () async {
                              _dlnaDevice = _devices[names.toList()[index]]!;
                              await _dlnaDevice.setUrl(widget.url);
                            },
                          );
                        }),
                  ),
                )
              : const Center(
                  child: Text("未找到设备!"),
                ),
    );
  }
}
