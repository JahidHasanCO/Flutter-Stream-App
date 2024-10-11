import 'package:better_player/better_player.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:stream_app/theme/app_colors.dart';
import 'package:stream_app/utils/utils.dart';

class MediaPlayerView extends StatefulWidget {
  const MediaPlayerView({required this.videoId, super.key});

  final String videoId;

  @override
  State<MediaPlayerView> createState() => _MediaPlayerViewState();
}

class _MediaPlayerViewState extends State<MediaPlayerView> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();
    final betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoId.streamUrl,
      notificationConfiguration:
          const BetterPlayerNotificationConfiguration(showNotification: true),
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Video Player'),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                IconButton.outlined(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
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
    );
  }
}
