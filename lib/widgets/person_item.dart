import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:one_list_tv/widgets/responsive.dart';

import '../http/dio_http.dart';
import '../utils/assets.dart';

class PersonItemWidget extends StatefulWidget {
  const PersonItemWidget({
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
  State<PersonItemWidget> createState() => _PersonItemWidgetState();
}

class _PersonItemWidgetState extends State<PersonItemWidget> {
  bool isFocused = false;
  bool onHover = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(isFocused ? 0 : 5),
      duration: const Duration(milliseconds: 350),
      child: MouseRegion(
        onEnter: (event) {
          setState(() {
            isFocused = true;
          });
        },
        onExit: (event) {
          setState(() {
            isFocused = false;
          });
        },
        child: HoverButton(
          onPressed: () {
            widget.onItemPressed();
          },
          focusEnabled: true,
          onFocusChange: ((focus) {
            setState(() {
              isFocused = focus;
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
                    image: widget.content["profile_path"].length!=0
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(
                                "${DioWrapper().getServer()}/t/p/w220_and_h330_face${widget.content["profile_path"]}"),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image: AssetImage(Assets.noPerson),
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
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
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
                            ],
                          ),
                        ),
                        Expanded(child: Container()),
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(2.0),
                          child: Text(widget.content["name"],
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
