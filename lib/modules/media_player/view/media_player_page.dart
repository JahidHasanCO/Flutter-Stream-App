import 'package:flutter/material.dart';
import 'package:stream_app/modules/media_player/media_player.dart';
import 'package:stream_app/router/router.dart';

class MediaPlayerPage extends StatelessWidget {
  const MediaPlayerPage({required this.videoId, super.key});

  final String videoId;

  static final route = GoRoute(
    path: RouteNames.mediaPlayer.asPath,
    name: RouteNames.mediaPlayer,
    builder: (context, state) {
      return const MediaPlayerPage(
        videoId: '5d22127d-51dd-4420-9276-74d55673ee99',
      );
    },
  );



  @override
  Widget build(BuildContext context) {
    return MediaPlayerView(videoId: videoId);
  }
}
