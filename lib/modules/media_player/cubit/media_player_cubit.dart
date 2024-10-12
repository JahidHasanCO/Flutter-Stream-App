import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
    await _downloadRepo.startDownload(
      _videoId.downloadUrl,
      fileName: _videoId,
    );
  }

  Future<void> _loadDownloadedFile() async {
    try {
      // Try to get the downloaded file by the video ID
      final file = await _downloadRepo.getDownloadedFileByName(_videoId);

      // Emit the file path to the state if the file exists
      if (file != null) {
        emit(
          state.copyWith(
            status: MediaPlayerStatus.success,
            statusMsg: 'File loaded successfully',
            videoUrl: file.path, // Assuming 'file' has a path property
            local: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: MediaPlayerStatus.failure,
            statusMsg: 'File not found',
          ),
        );
      }
    } catch (e) {
      // Handle and emit any error that might occur
      emit(
        state.copyWith(
          status: MediaPlayerStatus.failure,
          statusMsg: 'Error loading file: $e',
        ),
      );
    }
  }

  final String _videoId;
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
