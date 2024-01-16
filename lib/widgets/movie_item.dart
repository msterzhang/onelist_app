import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:one_list_tv/utils/config.dart';
import 'package:one_list_tv/widgets/responsive.dart';
import 'package:flutter/material.dart' as material;
import '../http/dio_http.dart';

class MovieItemWidget extends StatefulWidget {
  const MovieItemWidget({
    Key? key,
    required this.content,
    required this.height,
    required this.isOriginals,
    required this.onItemSelected,
    required this.onItemPressed,
  }) : super(key: key);

  final double height;
  final dynamic content;
  final bool isOriginals;
  final Function onItemSelected;
  final Function onItemPressed;

  @override
  State<MovieItemWidget> createState() => _MovieItemWidgetState();
}

class _MovieItemWidgetState extends State<MovieItemWidget> {
  bool isfocused = false;
  bool onhover = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(isfocused ? 0 : 5),
      duration: const Duration(milliseconds: 350),
      child: MouseRegion(
        onEnter: (event) {
          setState(() {
            isfocused = true;
          });
        },
        onExit: (event) {
          setState(() {
            isfocused = false;
          });
        },
        child: HoverButton(
          onPressed: () {
            widget.onItemPressed();
          },
          focusEnabled: true,
          onFocusChange: ((focus) {
            setState(() {
              isfocused = focus;
              if (focus) {
                // debugPrint('On ITEM SELECTED is $focus ');
                widget.onItemSelected();
              }
            });
          }),
          builder: (context, states) {
            return FocusBorder(
              focused: states.isFocused,
              renderOutside: true,
              child: RepaintBoundary(
                child: AnimatedContainer(
                  curve: Curves.bounceOut,
                  duration: FluentTheme.of(context).fasterAnimationDuration,
                  decoration: BoxDecoration(
                    color: ButtonThemeData.uncheckedInputColor(
                      FluentTheme.of(context),
                      states,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    image: DecorationImage(
                      image:
                          CachedNetworkImageProvider("${DioWrapper().getServer()}/t/p/w220_and_h330_face${widget.content["poster_path"]}"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  height: widget.height,
                  width: widget.height * 9 / 16,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        begin: FractionalOffset.bottomCenter,
                        end: FractionalOffset.topCenter,
                        colors: [Colors.black, Colors.transparent],
                        stops: [0.0, 0.9],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.all(2.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  alignment: Alignment.topLeft,
                                  child: widget.content["played"]?Container(
                                    width: Responsive.isMobile(context)
                                        ? 16
                                        : 20.0,
                                    height: Responsive.isMobile(context)
                                        ? 16
                                        : 20.0,
                                    decoration: const BoxDecoration(
                                      color: Config.mainColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Responsive.isMobile(context)?const Icon(
                                      material.Icons.done,
                                      size: 12,
                                    ):const Icon(
                                      material.Icons.done,
                                      size: 16,
                                    ),
                                  ):Text(
                                   "",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: Responsive.isMobile(context)
                                          ? 14
                                          : 18.0,
                                      fontWeight: FontWeight.w500,
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black,
                                          offset: Offset(2.0, 4.0),
                                          blurRadius: 6.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.topRight,
                                  child: Text("${widget.content["vote_average"].toStringAsFixed(1)}分",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: Responsive.isMobile(context)
                                            ? 14
                                            : 18.0,
                                        fontWeight: FontWeight.w500,
                                        shadows: const [
                                          Shadow(
                                            color: Colors.black,
                                            offset: Offset(2.0, 4.0),
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                      )),
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(child: Container()),
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(2.0),
                          child: Text(widget.content["name"] ?? widget.content["title"],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    Responsive.isMobile(context) ? 14 : 18.0,
                                fontWeight: FontWeight.w500,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(2.0, 4.0),
                                    blurRadius: 6.0,
                                  ),
                                ],
                              )),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
