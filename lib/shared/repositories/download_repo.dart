import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class DownloadRepo {
  DownloadRepo() {
    setupDownloader();
  }

  // StreamControllers for progress and status
  StreamController<double> _progressController =
      StreamController<double>.broadcast();
  StreamController<DownloadTaskStatus> _statusController =
      StreamController<DownloadTaskStatus>.broadcast();

  Stream<double> get progressStream => _progressController.stream;
  Stream<DownloadTaskStatus> get statusStream => _statusController.stream;

  // Get the path where files will be saved
  Future<String> get _getSavePath async =>
      getApplicationDocumentsDirectory().then((dir) => dir.path);

// Start download method with progress and status updates
  Future<String?> startDownload(
    String url, {
    String? fileName,
    String? savePath,
  }) async {
    final path = await _getSavePath;
    return FlutterDownloader.enqueue(
      url: url,
      fileName: fileName,
      savedDir: savePath ?? path,
      openFileFromNotification: false,
    );
  }

  // Set up downloader callback to receive updates
  Future<void> setupDownloader() async {
    // Register the port for the isolate communication
    IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );

    // Listen for updates from the isolate
    _port.listen((dynamic data) {
      if (kDebugMode) {
        print('Data received in port: $data');
      } // Debug print
      // final id = data[0] as String;
    
      final status = DownloadTaskStatus.values[data[1] as int];
      final progress = data[2] as int;

      // Update the progress and status streams only if they're still open
      if (_progressController.isClosed) {
        _progressController = StreamController<double>.broadcast();
      }
      if (_statusController.isClosed) {
        _statusController = StreamController<DownloadTaskStatus>.broadcast();
      }

      // Update the progress and status streams
      _progressController.add(progress / 100);
      _statusController.add(status);

      // Close streams if download is complete or failed
      if (status == DownloadTaskStatus.complete ||
          status == DownloadTaskStatus.failed ||
          status == DownloadTaskStatus.canceled) {
        if (kDebugMode) {
          print('updated status: $status');
        }
        _progressController.close();
        _statusController.close();
      }
    });

    // Register the callback for FlutterDownloader
    await FlutterDownloader.registerCallback(downloadCallback);
  }

  // Callback for the downloader
  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  // Cancel a download task by taskId
  Future<void> cancelDownload(String taskId) async {
    await FlutterDownloader.cancel(taskId: taskId);
  }

  // Cancel all active download tasks
  Future<void> cancelAllDownloads() async {
    await FlutterDownloader.cancelAll();
  }

  // Pause a download task by taskId
  Future<void> pauseDownload(String taskId) async {
    await FlutterDownloader.pause(taskId: taskId);
  }

  // Resume a paused download task, returns a new taskId
  Future<String?> resumeDownload(String taskId) async {
    return FlutterDownloader.resume(taskId: taskId);
  }

  // Retry a failed download task, returns a new taskId
  Future<String?> retryDownload(String taskId) async {
    return FlutterDownloader.retry(taskId: taskId);
  }

  // Remove a download task without deleting the content
  Future<void> removeTask(
    String taskId, {
    bool shouldDeleteContent = false,
  }) async {
    await FlutterDownloader.remove(
      taskId: taskId,
      shouldDeleteContent: shouldDeleteContent,
    );
  }

  // Dispose method to clean up streams
  void dispose() {
    _progressController.close();
    _statusController.close();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  // Query all completed download tasks
  Future<List<DownloadTask>?> getCompletedDownloads() async {
    final tasks = await FlutterDownloader.loadTasks();
    return tasks
        ?.where((task) => task.status == DownloadTaskStatus.complete)
        .toList();
  }

  // Query a specific downloaded file by its name
  Future<DownloadTask?> getDownloadedFileByName(
    String fileName,
  ) async {
    final tasks = await getCompletedDownloads();
    if (tasks == null) return null;

    for (final task in tasks) {
      if (task.filename == fileName) {
        return task;
      }
    }

    return null;
  }

  bool removeFileByPath(String path) {
    try {
      final file = File(path);

      // Check if the file exists
      if (file.existsSync()) {
        file.deleteSync();
        _progressController.close();
        _statusController.close();
        return true; // Return true if the file was successfully deleted
      } else {
        return false; // Return false if the file doesn't exist
      }
    } catch (e) {
      return false; // Return false in case of an error
    }
  }

  // Private port for the isolate communication
  final ReceivePort _port = ReceivePort();
}
