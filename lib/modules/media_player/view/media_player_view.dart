import 'dart:async';
import 'package:better_player/better_player.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:stream_app/modules/media_player/media_player.dart';
import 'package:stream_app/shared/widgets/alert_dialog.dart';
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
    if (mounted) {
      _betterPlayerController.dispose();
    }
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
        body: BlocListener<MediaPlayerCubit, MediaPlayerState>(
          listenWhen: (previous, current) =>
              previous.statusMsg != current.statusMsg,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.statusMsg)));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: BetterPlayer(
                  controller: _betterPlayerController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sample Title 1',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Builder(
                      builder: (context) {
                        final downloadProgress = context.select(
                          (MediaPlayerCubit cubit) =>
                              cubit.state.downloadProgress,
                        );
                        final downloadTaskStatus = context.select(
                          (MediaPlayerCubit cubit) =>
                              cubit.state.downloadTaskStatus,
                        );
                        final local = context.select(
                          (MediaPlayerCubit cubit) => cubit.state.local,
                        );

                        return IconButton(
                          onPressed: () {
                            if (local) {
                              AppAlertDialog(
                                onYes: () {
                                  cubit().removePressed();
                                },
                                title:
                                    'Do you want to remove downloaded video?',
                              );
                            } else {
                              if (downloadTaskStatus ==
                                      DownloadTaskStatus.running ||
                                  downloadTaskStatus ==
                                      DownloadTaskStatus.enqueued) {
                                AppAlertDialog(
                                  onYes: () {
                                    cubit().cancelPressed();
                                  },
                                  title: 'Do you want to calcel downloading?',
                                );
                              } else {
                                AppAlertDialog(
                                  onYes: () {
                                    cubit().downloadPressed();
                                  },
                                  title: 'Do you want to download this video?',
                                );
                              }
                            }
                          },
                          icon: local
                              ? const Icon(
                                  Icons.download_done,
                                ) // Downloaded icon
                              : downloadTaskStatus == DownloadTaskStatus.running
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Stack(
                                        children: [
                                          const Icon(
                                            Icons.stop,
                                          ),
                                          CircularProgressIndicator(
                                            strokeWidth: 2,
                                            value: downloadProgress,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                    Color>(
                                              AppColors.primaryDarkColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const Icon(
                                      Icons.download_sharp,
                                    ),
                        );
                      },
                    ),
                  ],
                ),
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
      ),
    );
  }
}
