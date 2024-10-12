import 'dart:async';

import 'package:bloc/bloc.dart';
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
    _loadDownloadedFile();

    _initStreamSubscriptions();
  }

  void _initStreamSubscriptions() {
    _downloadProgressSubsctiption =
        _downloadRepo.progressStream.listen((progress) {
      emit(state.copyWith(downloadProgress: progress));
    });

    _downloadStatusSubsctiption = _downloadRepo.statusStream.listen((status) {
      if (status == DownloadTaskStatus.complete) {
        _loadDownloadedFile();
      }
      emit(state.copyWith(downloadTaskStatus: status));
    });
  }

  Future<void> downloadPressed() async {
    _taskId = await _downloadRepo.startDownload(
      _videoId.downloadUrl,
      fileName: _videoId,
    );
    emit(
      state.copyWith(
        statusMsg: 'Download Started!',
        downloadProgress: 0,
        downloadTaskStatus: DownloadTaskStatus.enqueued,
      ),
    );
  }

  Future<void> cancelPressed() async {
    if (_taskId == null) {
      await _downloadRepo.cancelAllDownloads();
    } else {
      await _downloadRepo.cancelDownload(_taskId ?? '');
    }
    emit(
      state.copyWith(
        statusMsg: 'Download Cancelled!',
        downloadProgress: 0,
        downloadTaskStatus: DownloadTaskStatus.canceled,
      ),
    );
  }

  Future<void> removePressed() async {
    final success = _downloadRepo.removeFileByPath(state.videoUrl);
    if (success) {
      // Emit a success state if the file was removed successfully
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
      // Emit a failure state if the file was not found
      emit(
        state.copyWith(
          status: MediaPlayerStatus.failure,
          local: false,
          downloadProgress: 0,
          downloadTaskStatus: DownloadTaskStatus.undefined,
          videoUrl: _videoId.streamUrl,
          statusMsg: 'Video not found or could not be removed',
        ),
      );
    }
  }

  Future<void> _loadDownloadedFile() async {
    try {
      // Try to get the downloaded file by the video ID
      final task = await _downloadRepo.getDownloadedFileByName(_videoId);

      // Emit the file path to the state if the file exists
      if (task != null) {
        _taskId = task.taskId;
        emit(
          state.copyWith(
            status: MediaPlayerStatus.success,
            statusMsg: 'File loaded successfully',
            videoUrl: task.savedDir, // Assuming 'file' has a path property
            local: true,
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

  @override
  Future<void> close() {
    _downloadProgressSubsctiption?.cancel();
    _downloadStatusSubsctiption?.cancel();
    return super.close();
  }
}
