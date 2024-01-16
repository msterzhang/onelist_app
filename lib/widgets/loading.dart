import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../utils/config.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return const SpinKitFadingFour(
      color: Colors.white,
      size: 60.0,
    );
  }
}

class ImgLoading extends StatefulWidget {
  const ImgLoading({Key? key}) : super(key: key);

  @override
  State<ImgLoading> createState() => _ImgLoadingState();
}

class _ImgLoadingState extends State<ImgLoading> {
  @override
  Widget build(BuildContext context) {
    return const SpinKitWave(
      color: Colors.white,
      size: 20.0,
    );
  }
}

class VideoLoading extends StatefulWidget {
  const VideoLoading({Key? key}) : super(key: key);

  @override
  State<VideoLoading> createState() => _VideoLoadingState();
}

class _VideoLoadingState extends State<VideoLoading> {
  @override
  Widget build(BuildContext context) {
    return const SpinKitSpinningLines(
      color: Config.mainColor,
      size: 70.0,
    );
  }
}


