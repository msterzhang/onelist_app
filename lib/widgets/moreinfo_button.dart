// import 'package:fluent_ui/fluent_ui.dart';

// import 'responsive.dart';

// class MoreInfoButton extends StatelessWidget {
//   final Function onSelected;
//   const MoreInfoButton({
//     super.key,
//     required this.onSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Button(
//       focusable: true,
//       onPressed: () {
//         onSelected();
//         print('More Info');
//       },
//       child: Container(
//         decoration: const BoxDecoration(
//           //   color: Colors.white,
//           borderRadius: BorderRadius.all(Radius.circular(7)),
//         ),
//         padding: !Responsive.isDesktop(context)
//             ? const EdgeInsets.fromLTRB(15.0, 5.0, 20.0, 5.0)
//             : const EdgeInsets.fromLTRB(25.0, 10.0, 30.0, 10.0),
//         child: Row(
//           children: [
//             Row(
//               children: const [
//                 Icon(
//                   FluentIcons.info,
//                   size: 30.0,
//                   color: Colors.white,
//                 ),
//                 SizedBox(
//                   width: 6,
//                 ),
//                 Text(
//                   'More Info',
//                   style: TextStyle(
//                       fontSize: 16.0,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
