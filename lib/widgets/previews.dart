import 'package:fluent_ui/fluent_ui.dart';
import 'package:one_list_tv/widgets/responsive.dart';

import '../utils/config.dart';
import 'preview_item.dart';

class Previews extends StatelessWidget {
  final String title;
  final int count;
  final dynamic contentList;
  final Function onClick;

  const Previews({
    Key? key,
    required this.title,
    required this.count,
    required this.contentList,
    required this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              FluentIcons.docs_logo_inverse,
              color: Colors.red,
              size: Responsive.isMobile(context) ? 18 : 24.0,
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.isMobile(context) ? 18 : 22.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Expanded(child: SizedBox()),
            IconButton(
                iconButtonMode: IconButtonMode.large,
                icon: Icon(
                  FluentIcons.branch_compare,
                  color: Colors.white,
                  size: Responsive.isMobile(context) ? 22 : 28.0,
                ),
                onPressed: () {
                  onClick();
                }),
          ],
        ),
        SizedBox(
          height: Config().getHeight(context, false, count) * 0.8,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 8.0,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: contentList.length,
            itemBuilder: (BuildContext context, int index) {
              final dynamic content = contentList[index];
              return PreviewItem(content: content, count: count);
            },
          ),
        ),
      ],
    );
  }
}
