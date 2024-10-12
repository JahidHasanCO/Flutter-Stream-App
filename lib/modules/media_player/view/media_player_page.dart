import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_app/modules/media_player/media_player.dart';
import 'package:stream_app/router/router.dart';
import 'package:stream_app/shared/repositories/download_repo.dart';

class MediaPlayerPage extends StatelessWidget {
  const MediaPlayerPage({super.key});

  static final route = GoRoute(
    path: RouteNames.mediaPlayer.asPath,
    name: RouteNames.mediaPlayer,
    builder: (context, state) {
      return BlocProvider(
        create: (context) => MediaPlayerCubit(
          downloadRepo: context.read<DownloadRepo>(),
          videoId: '5d22127d-51dd-4420-9276-74d55673ee99',
        ),
        child: const MediaPlayerPage(),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return const MediaPlayerView();
  }
}
