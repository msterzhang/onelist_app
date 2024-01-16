
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';

final List<Color> colors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.purple,
];

Color getRandomColor() {
  Random random = Random();
  int index = random.nextInt(colors.length);
  return colors[index];
}