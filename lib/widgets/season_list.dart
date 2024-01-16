

import 'package:fluent_ui/fluent_ui.dart';
import 'package:one_list_tv/widgets/responsive.dart';
import 'package:one_list_tv/widgets/season_item.dart';

import '../screens/season_screen.dart';
import '../utils/config.dart';

class SeasonList extends StatelessWidget {
  final String title;
  final int count;
  final bool more;
  final dynamic contentList;
  final dynamic data;
  final bool isOriginals;
  Function? onItemFoccused;

  SeasonList({
    Key? key,
    required this.title,
    required this.count,
    required this.more,
    required this.contentList,
    required this.data,
    this.isOriginals = false,
    this.onItemFoccused,
  }) : super(key: key);

  final ScrollController _scrollController = ScrollController();

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
            const SizedBox(
              width: 2,
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.isMobile(context) ? 18 : 22.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(child: Container()),
          ],
        ),
        SizedBox(
          height: Config().getHeight(context, isOriginals, count) - 30,
          child: ListView.separated(
            controller: _scrollController,
            padding: Responsive.isMobile(context)
                ? const EdgeInsets.only(right: 10,top: 10,bottom: 10,left: 5)
                : const EdgeInsets.only(right: 30,top: 30,bottom: 5,left: 5),
            scrollDirection: Axis.horizontal,
            itemCount: contentList.length,
            itemBuilder: (BuildContext context, int index) {
              final dynamic content = contentList[index];
              return SeasonItemWidget(
                height: Config().getHeight(context, isOriginals, count) - 30,
                content: content,
                isOriginals: isOriginals,
                onItemSelected: () {
                  if (onItemFoccused != null) {
                    onItemFoccused!();
                  }
                  if (index == 0) {
                    _scrollController.animateTo(0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.linear);
                  }
                },
                onItemPressed: () {
                  print("跳转到季");
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation,
                          secondaryanimation) =>
                          DrillInPageTransition(
                            animation: animation,
                            child: SeasonScreen(
                              content: data,
                                seasonId:content["id"],
                                seasonName:content["name"]
                            ),
                          ),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(
                width: 10,
              );
            },
          ),
        ),
      ],
    );
  }
}

