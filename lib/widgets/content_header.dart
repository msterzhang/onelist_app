import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:one_list_tv/screens/description_screen.dart';

import '../http/dio_http.dart';
import '../screens/mobile_video_screen.dart';
import '../screens/video_screen.dart';
import 'icon_button.dart';
import 'widgets.dart';

class ContentHeader extends StatelessWidget {
  final dynamic data;
  final Function scrollToTop;

  const ContentHeader({
    Key? key,
    required this.data,
    required this.scrollToTop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: _ContentHeaderMobile(data: data),
      desktop: _ContentHeaderDesktop(
        data: data,
        scrollToTop: scrollToTop,
      ),
      androidTv: _ContentHeaderDesktop(
        data: data,
        scrollToTop: scrollToTop,
      ),
    );
  }
}

class _ContentHeaderMobile extends StatelessWidget {
  final dynamic data;

  const _ContentHeaderMobile({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          child: SizedBox(
            child: CachedNetworkImage(
              imageUrl: "${DioWrapper().getServer()}/t/p/w1920_and_h1080_bestv2${data["backdrop_path"]}",
              placeholder: (context, url) => const ImgLoading(),
              errorWidget: (context, url, error) =>
                  const Icon(FluentIcons.photo_error),
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: FractionalOffset.bottomCenter,
              end: FractionalOffset.topCenter,
              colors: [Colors.black, Colors.transparent],
              stops: [0.0, 0.9],
            ),
          ),
        ),
        Positioned(
          left: 10.0,
          right: 10.0,
          top: 38,
          bottom: 30.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (Responsive.isAndroidTv(context) ||
                  Responsive.isDesktop(context))
                const SizedBox(height: 60.0),
              const Expanded(child: SizedBox()),
              SizedBox(
                width: 400.0,
                child: Text(
                  data["title"]??data["name"],
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(height: 12.0),
              SizedBox(
                width: 600,
                child: Text(
                  data["overview"],
                  softWrap: true, // 允许自动换行
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(2.0, 4.0),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [

                  const SizedBox(width: 16.0),
                  CustomIconButton(
                    active: false,
                    focusNode: FocusNode(),
                    icon: FluentIcons.office_video_logo_inverse,
                    title: '详情',
                    onClick: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryanimation) =>
                                  DrillInPageTransition(
                            animation: animation,
                            child: DescriptionScreen(
                              content: data,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20.0),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContentHeaderDesktop extends StatefulWidget {
  final dynamic data;
  Function? scrollToTop;

  _ContentHeaderDesktop({
    Key? key,
    required this.data,
    this.scrollToTop,
  }) : super(key: key);

  @override
  __ContentHeaderDesktopState createState() => __ContentHeaderDesktopState();
}

class __ContentHeaderDesktopState extends State<_ContentHeaderDesktop> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Positioned(
          top: 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child:
                Image(image: CachedNetworkImageProvider("${DioWrapper().getServer()}/t/p/w1920_and_h1080_bestv2${widget.data["backdrop_path"]}")),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: FractionalOffset.bottomCenter,
              end: FractionalOffset.topCenter,
              colors: [Colors.black, Colors.transparent],
              stops: [0.0, 0.9],
            ),
          ),
        ),
        Positioned(
          left: 30.0,
          right: 30.0,
          top: 38,
          bottom: 30.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (Responsive.isAndroidTv(context) ||
                  Responsive.isDesktop(context))
                const SizedBox(height: 60.0),
              const Expanded(child: SizedBox()),
              SizedBox(
                width: 400.0,
                child: Text(
                  widget.data["name"]??widget.data["title"],
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(height: 12.0),
              SizedBox(
                width: 600,
                child: Text(
                  widget.data["overview"],
                  softWrap: true, // 允许自动换行
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(2.0, 4.0),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  // CustomIconButton(
                  //   active: false,
                  //   icon: FluentIcons.play,
                  //   title: '播放',
                  //   focusNode: FocusNode(),
                  //   onClick: () {
                  //     Navigator.push(
                  //       context,
                  //       PageRouteBuilder(
                  //         pageBuilder:
                  //             (context, animation, secondaryanimation) =>
                  //                 DrillInPageTransition(
                  //           animation: animation,
                  //           child: VideoScreen(
                  //             content: widget.data,
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  //   onSelected: () {
                  //     if (widget.scrollToTop != null) {
                  //       widget.scrollToTop!();
                  //     }
                  //   },
                  // ),
                  const SizedBox(width: 16.0),
                  CustomIconButton(
                    active: false,
                    focusNode: FocusNode(),
                    icon: FluentIcons.office_video_logo_inverse,
                    title: '详情',
                    onSelected: () {
                      if (widget.scrollToTop != null) {
                        widget.scrollToTop!();
                      }
                    },
                    onClick: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryanimation) =>
                                  DrillInPageTransition(
                            animation: animation,
                            child: DescriptionScreen(
                              content: widget.data,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20.0),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
