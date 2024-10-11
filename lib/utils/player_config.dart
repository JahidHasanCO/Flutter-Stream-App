import 'package:better_player/better_player.dart';

const betterPlayerConfiguration = BetterPlayerConfiguration(
  allowedScreenSleep: false,
  controlsConfiguration: _controlsConfiguration,
  autoDispose: false,
  aspectRatio: 16 / 9,
  autoPlay: true,
);

const _controlsConfiguration = BetterPlayerControlsConfiguration(
  enableAudioTracks: false,
  enableSubtitles: false,
  enablePip: false,
);
