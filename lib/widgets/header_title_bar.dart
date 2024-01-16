//顶部导航按钮
import 'package:fluent_ui/fluent_ui.dart';
import 'package:one_list_tv/widgets/responsive.dart';

class HeaderTitleBar extends StatelessWidget {
  final String title;

  const HeaderTitleBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.isMobile(context) ? 22 : 28.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Expanded(child: SizedBox()),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: IconButton(
              iconButtonMode: IconButtonMode.large,
              icon: Icon(
                FluentIcons.back,
                color: Colors.white,
                size: Responsive.isMobile(context) ? 22 : 30.0,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        )
      ],
    );
  }
}
