import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:stream_app/theme/app_colors.dart';

const betterPlayerConfiguration = BetterPlayerConfiguration(
  allowedScreenSleep: false,
  controlsConfiguration: _controlsConfiguration,
  aspectRatio: 16 / 9,
  autoPlay: true,
  expandToFill: false,
  fit: BoxFit.contain,
  autoDetectFullscreenAspectRatio: true,
);

const _controlsConfiguration = BetterPlayerControlsConfiguration(
  enableAudioTracks: false,
  enableSubtitles: false,
  enablePip: false,
  progressBarPlayedColor: AppColors.primaryColor,
  showControlsOnInitialize: false,
  loadingColor: AppColors.primaryColor,
);
