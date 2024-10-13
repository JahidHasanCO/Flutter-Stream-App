part of 'media_player_cubit.dart';

enum MediaPlayerStatus {
  initial,
  loading,
  success,
  failure;

  bool get isLoading => this == loading;
  bool get isSuccess => this == success;
}

class MediaPlayerState extends Equatable {
  const MediaPlayerState({
    this.status = MediaPlayerStatus.initial,
    this.statusMsg = '',
    this.videoUrl = '',
    this.local = false,
    this.netConnected = true,
    this.downloadProgress = 0,
    this.downloadTaskStatus = DownloadTaskStatus.undefined,
  });

  final MediaPlayerStatus status;
  final String statusMsg;
  final String videoUrl;
  final bool local;
  final bool netConnected;
  final double downloadProgress; // Download progress percentage (0.0 to 1.0)
  final DownloadTaskStatus downloadTaskStatus; // Status of the download task

  // CopyWith method for creating a new instance with updated values
  MediaPlayerState copyWith({
    MediaPlayerStatus? status,
    String? statusMsg,
    String? videoUrl,
    bool? local,
    bool? netConnected,
    double? downloadProgress,
    DownloadTaskStatus? downloadTaskStatus,
  }) {
    return MediaPlayerState(
      status: status ?? this.status,
      statusMsg: statusMsg ?? this.statusMsg,
      videoUrl: videoUrl ?? this.videoUrl,
      local: local ?? this.local,
      netConnected: netConnected ?? this.netConnected,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadTaskStatus: downloadTaskStatus ?? this.downloadTaskStatus,
    );
  }

  @override
  List<Object?> get props => [
        status,
        statusMsg,
        videoUrl,
        local,
        netConnected,
        downloadProgress,
        downloadTaskStatus,
      ];
}
