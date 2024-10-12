import 'dart:async';
import 'package:better_player/better_player.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:stream_app/modules/media_player/media_player.dart';
import 'package:stream_app/theme/app_colors.dart';
import 'package:stream_app/utils/utils.dart';

class MediaPlayerView extends StatefulWidget {
  const MediaPlayerView({super.key});

  @override
  State<MediaPlayerView> createState() => _MediaPlayerViewState();
}

class _MediaPlayerViewState extends State<MediaPlayerView> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();
    final videoUrl = context.read<MediaPlayerCubit>().state.videoUrl;
    initializePlayer(videoUrl); // Call the async function here.
  }

  Future<void> initializePlayer(String url) async {
    final betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      videoFormat: BetterPlayerVideoFormat.hls,
    );
    _betterPlayerController = BetterPlayerController(
      betterPlayerConfiguration,
      betterPlayerDataSource: betterPlayerDataSource,
    );
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MediaPlayerCubit>;

    return BlocListener<MediaPlayerCubit, MediaPlayerState>(
      listenWhen: (previous, current) => previous.local != current.local,
      listener: (context, state) {
        if (state.local) {
          _betterPlayerController.setupDataSource(
            BetterPlayerDataSource(
              BetterPlayerDataSourceType.file,
              state.videoUrl,
              videoFormat: BetterPlayerVideoFormat.hls,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          centerTitle: false,
          title: const Text('Video Player'),
          leading: const Icon(
            Icons.play_arrow,
            size: 30,
          ),
          titleSpacing: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: BetterPlayer(
                controller: _betterPlayerController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sample Title 1',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  BlocSelector<MediaPlayerCubit, MediaPlayerState, bool>(
                    selector: (state) => state.local,
                    builder: (context, local) {
                      return IconButton(
                        onPressed: () {},
                        icon: Icon(
                          local ? Icons.download_done : Icons.download_sharp,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Builder(
              builder: (context) {
                final downloadProgress = context.select(
                  (MediaPlayerCubit cubit) => cubit.state.downloadProgress,
                );
                final downloadTaskStatus = context.select(
                  (MediaPlayerCubit cubit) => cubit.state.downloadTaskStatus,
                );
                return downloadTaskStatus == DownloadTaskStatus.running
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: LinearProgressIndicator(
                              value: downloadProgress, // Show download progress
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryDarkColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Text(
                              'Downloading: ${(downloadProgress * 100).toStringAsFixed(1)}%', // Show percentage
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textGrayColor,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink();
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Description',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: ExpandableText(
                'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.',
                expandText: 'show more',
                collapseText: 'show less',
                maxLines: 5,
                expanded: true,
                animation: true,
                expandOnTextTap: true,
                collapseOnTextTap: true,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textGrayColor,
                ),
                linkColor: AppColors.primaryDarkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
