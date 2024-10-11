import 'package:flutter/material.dart';
import 'package:stream_app/modules/media_player/media_player.dart';
import 'package:stream_app/router/router.dart';

class MediaPlayerPage extends StatelessWidget {
  const MediaPlayerPage({super.key});


  static final route = GoRoute(
    path: RouteNames.mediaPlayer.asPath,
    name: RouteNames.mediaPlayer,
    builder: (context, state) {
  
      return const MediaPlayerPage();
    },
  );

  @override
  Widget build(BuildContext context) {
  

    return const MediaPlayerView();
  }
}
