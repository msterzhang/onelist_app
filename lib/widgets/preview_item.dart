import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:one_list_tv/widgets/responsive.dart';
import '../http/dio_http.dart';
import '../screens/description_screen.dart';
import 'package:one_list_tv/utils/utils.dart';

class PreviewItem extends StatefulWidget {
  const PreviewItem({
    Key? key,
    required this.content,
    required this.count,
  }) : super(key: key);

  final dynamic content;
  final int count;

  @override
  State<PreviewItem> createState() => _PreviewItemState();
}

class _PreviewItemState extends State<PreviewItem> {
  bool isfocused = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(isfocused ? 0 : 5),
      duration: const Duration(milliseconds: 300),
      child: HoverButton(onFocusChange: ((focus) {
        setState(() {
          isfocused = focus;
        });
      }), onPressed: () {
        // debugPrint(widget.content["title"]);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryanimation) =>
                DrillInPageTransition(
              animation: animation,
              child: DescriptionScreen(
                content: widget.content,
              ),
            ),
          ),
        );
      }, builder: (context, states) {
        return FocusBorder(
          focused: states.isFocused,
          renderOutside: true,
          child: RepaintBoundary(
            child: AnimatedContainer(
              duration: FluentTheme.of(context).fasterAnimationDuration,
              decoration: BoxDecoration(
                color: ButtonThemeData.uncheckedInputColor(
                  FluentTheme.of(context),
                  states,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              padding: const EdgeInsets.all(6.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        height:
                            Config().getHeight(context, false, widget.count) *
                                0.4,
                        width:
                            Config().getHeight(context, false, widget.count) *
                                0.4,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider("${DioWrapper().getServer()}/t/p/w220_and_h330_face${widget.content["poster_path"]}"),
                            fit: BoxFit.cover,
                          ),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: getRandomColor(), width: 4.0),
                        ),
                      ),
                      Container(
                        height:
                            Config().getHeight(context, false, widget.count) *
                                0.4,
                        width:
                            Config().getHeight(context, false, widget.count) *
                                0.4,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.black,
                              Colors.transparent,
                            ],
                            stops: [0, 1],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: getRandomColor(), width: 4.0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(widget.content["name"] ?? widget.content["title"],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.isMobile(context) ? 14 : 18.0,
                        fontWeight: FontWeight.w500,
                        shadows: const [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(2.0, 4.0),
                            blurRadius: 6.0,
                          ),
                        ],
                      )
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
