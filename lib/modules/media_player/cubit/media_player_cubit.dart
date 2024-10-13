import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:stream_app/shared/repositories/download_repo.dart';
import 'package:stream_app/utils/utils.dart';

part 'media_player_state.dart';

class MediaPlayerCubit extends Cubit<MediaPlayerState> {
  MediaPlayerCubit({
    required DownloadRepo downloadRepo,
    required String videoId,
  })  : _videoId = videoId,
        _downloadRepo = downloadRepo,
        super(MediaPlayerState(videoUrl: videoId.streamUrl)) {
    _netSubscription =
        Connectivity().onConnectivityChanged.listen(internetConnected);
    _loadDownloadedFile();

    _initStreamSubscriptions();
  }

  void _initStreamSubscriptions() {
    _downloadProgressSubsctiption =
        _downloadRepo.progressStream.listen((progress) {
      if (kDebugMode) {
        print('progress cubit: $progress');
      }
      emit(state.copyWith(downloadProgress: progress));
    });

    _downloadStatusSubsctiption = _downloadRepo.statusStream.listen((status) {
      if (kDebugMode) {
        print('status cubit: $status');
      }
      final statusMessage = switch (status) {
        DownloadTaskStatus.enqueued ||
        DownloadTaskStatus.running =>
          'Download Started!',
        DownloadTaskStatus.complete => 'Download Completed!',
        DownloadTaskStatus.canceled => 'Download Cancelled!',
        DownloadTaskStatus.failed => 'Download Failed!',
        _ => null,
      };

      emit(
        state.copyWith(
          statusMsg: statusMessage,
          downloadTaskStatus: status,
        ),
      );
    });
  }

  Future<void> internetConnected(
    List<ConnectivityResult> connectivityResults,
  ) async {
    if (connectivityResults.contains(ConnectivityResult.mobile) ||
        connectivityResults.contains(ConnectivityResult.wifi)) {
      emit(state.copyWith(netConnected: true));
    } else {
      emit(state.copyWith(netConnected: false));
    }
  }

  Future<void> downloadPressed() async {
    if (!state.netConnected) {
      emit(state.copyWith(statusMsg: 'No internet connection'));
      return;
    }
    _taskId = await _downloadRepo.startDownload(
      _videoId.downloadUrl,
      fileName: _videoId,
    );
  }

  Future<void> cancelPressed() async {
    if (_taskId == null) {
      await _downloadRepo.cancelAllDownloads();
    } else {
      await _downloadRepo.cancelDownload(_taskId ?? '');
    }
  }

  Future<void> removePressed() async {
    if (_taskId != null && _taskId!.isNotEmpty) {
      await _downloadRepo.removeTask(_taskId!);
      emit(
        state.copyWith(
          status: MediaPlayerStatus.success,
          statusMsg: 'Video removed successfully',
          videoUrl: _videoId.streamUrl,
          downloadProgress: 0,
          downloadTaskStatus: DownloadTaskStatus.undefined,
          local: false, // Update local status accordingly
        ),
      );
    } else {
      final success = _downloadRepo.removeFileByPath(state.videoUrl);
      emit(
        state.copyWith(
          status:
              success ? MediaPlayerStatus.success : MediaPlayerStatus.failure,
          statusMsg: success
              ? 'Video removed successfully'
              : 'Video not found or could not be removed',
          videoUrl: _videoId.streamUrl,
          downloadProgress: 0,
          downloadTaskStatus: DownloadTaskStatus.undefined,
          local: false, // Update local status accordingly
        ),
      );
    }
  }

  Future<void> _loadDownloadedFile() async {
    try {
      // Try to get the downloaded file by the video ID
      final task = await _downloadRepo.getDownloadedFileByName(
        _videoId,
      );

      // Emit the file path to the state if the file exists
      if (task != null) {
        _taskId = task.taskId;
        final filePath = '${task.savedDir}/${task.filename}';
        emit(
          state.copyWith(
            status: MediaPlayerStatus.success,
            videoUrl: filePath, // Assuming 'file' has a path property
            local: true,
            downloadTaskStatus: task.status,
            downloadProgress: task.progress.toDouble(),
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: MediaPlayerStatus.failure,
            local: false,
            statusMsg: '',
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  final String _videoId;
  String? _taskId;
  final DownloadRepo _downloadRepo;
  StreamSubscription<DownloadTaskStatus>? _downloadStatusSubsctiption;
  StreamSubscription<double>? _downloadProgressSubsctiption;
  StreamSubscription<List<ConnectivityResult>>? _netSubscription;

  @override
  Future<void> close() {
    _netSubscription?.cancel();
    _downloadProgressSubsctiption?.cancel();
    _downloadStatusSubsctiption?.cancel();
    return super.close();
  }
}
