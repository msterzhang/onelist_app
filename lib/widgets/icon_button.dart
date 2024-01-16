import 'package:fluent_ui/fluent_ui.dart';

import '../utils/config.dart';
import 'responsive.dart';

class CustomIconButton extends StatelessWidget {
  final Function? onSelected;
  final IconData? icon;
  final String title;
  final Function onClick;
  final FocusNode focusNode;
  final bool active;

  const CustomIconButton(
      {super.key,
      this.onSelected,
      required this.active,
      this.icon,
      required this.focusNode,
      required this.title,
      required this.onClick});

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      focusEnabled: true,
      focusNode: focusNode,
      onFocusChange: ((focus) {
        if (focus) {
          if (onSelected != null) {
            onSelected!();
          }
        }
      }),
      onPressed: () {
        onClick();
      },
      builder: (BuildContext, Set<ButtonStates> state) {
        return FocusBorder(
          focused: state.isFocused,
          renderOutside: true,
          child: Container(
            decoration: const BoxDecoration(
              // color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            padding: !Responsive.isDesktop(context)
                ? const EdgeInsets.fromLTRB(15.0, 5.0, 20.0, 5.0)
                : const EdgeInsets.fromLTRB(25.0, 10.0, 30.0, 10.0),
            child: Row(
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    size: 30.0,
                    color: active ? Config.activeColor : Config.fontColor,
                  ),
                const SizedBox(
                  width: 6,
                ),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: active ? Config.activeColor : Config.fontColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CustomColorIconButton extends StatelessWidget {
  final Function? onSelected;
  final IconData? icon;
  final String title;
  final Function onClick;
  final FocusNode focusNode;
  final bool active;

  const CustomColorIconButton(
      {super.key,
      this.onSelected,
      required this.active,
      this.icon,
      required this.focusNode,
      required this.title,
      required this.onClick});

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      focusEnabled: true,
      focusNode: focusNode,
      onFocusChange: ((focus) {
        if (focus) {
          if (onSelected != null) {
            onSelected!();
          }
        }
      }),
      onPressed: () {
        onClick();
      },
      builder: (BuildContext, Set<ButtonStates> state) {
        return FocusBorder(
          focused: state.isFocused,
          renderOutside: true,
          style: const FocusThemeData(
            glowFactor: 0.0,
            primaryBorder: BorderSide(
              width: 3,
              color: Config.fontColor,
            ),
          ),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Config.mainColor,
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            padding: !Responsive.isDesktop(context)
                ? const EdgeInsets.fromLTRB(15.0, 5.0, 20.0, 5.0)
                : const EdgeInsets.fromLTRB(25.0, 10.0, 30.0, 10.0),
            child: Center(
              child: icon != null
                  ? Row(children: [
                      Icon(
                        icon,
                        size: 30.0,
                        color: active ? Config.activeColor : Config.fontColor,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            color:
                                active ? Config.activeColor : Config.fontColor),
                      )
                    ])
                  : Text(
                      title,
                      style: TextStyle(
                          fontSize: 26.0,
                          fontWeight: FontWeight.w600,
                          color:
                              active ? Config.activeColor : Config.fontColor),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class RoundIconButton extends StatelessWidget {
  final Function? onSelected;
  final IconData? icon;
  final String title;
  final Function onClick;
  final double size;
  final Color color;

  const RoundIconButton(
      {super.key,
      this.onSelected,
      this.icon,
      required this.title,
      required this.color,
      required this.size,
      required this.onClick});

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      focusEnabled: true,
      onFocusChange: ((focus) {
        if (focus) {
          if (onSelected != null) {
            onSelected!();
          }
        }
      }),
      onPressed: () {
        onClick();
      },
      builder: (BuildContext, Set<ButtonStates> state) {
        return FocusBorder(
          focused: state.isFocused,
          renderOutside: true,
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),
            padding: !Responsive.isDesktop(context)
                ? const EdgeInsets.all(5)
                : const EdgeInsets.all(8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: size,
                  color: color,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
