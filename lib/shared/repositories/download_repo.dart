import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class DownloadRepo {
  // Factory constructor to return the singleton instance
  factory DownloadRepo() {
    return _instance;
  }

  // Private constructor
  DownloadRepo._(){
    setupDownloader();
  }

  // Singleton instance
  static final DownloadRepo _instance = DownloadRepo._();

   // StreamControllers for progress and status
  final StreamController<double> _progressController =
      StreamController<double>.broadcast();
  final StreamController<DownloadTaskStatus> _statusController =
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
      // final id = data[0] as String;
      final mapData = data as Map;
      final status = DownloadTaskStatus.values[mapData[1] as int];
      final progress = mapData[2] as int;

      // Update the progress and status streams
      _progressController.add(progress / 100);
      _statusController.add(status);

      // Close streams if download is complete or failed
      if (status == DownloadTaskStatus.complete ||
          status == DownloadTaskStatus.failed) {
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

  // Get a list of downloaded files in the application directory
  Future<List<FileSystemEntity>> getDownloadedFiles() async {
    final savePath = await _getSavePath;
    final directory = Directory(savePath);
    final isExist = await directory.exists();
    if (isExist) {
      // Get all files in the directory
      return directory.listSync().whereType<File>().toList();
    } else {
      return [];
    }
  }

  // Query a specific downloaded file by its name
  Future<File?> getDownloadedFileByName(String fileName) async {
    final files = await getDownloadedFiles();
    try {
      return files.firstWhere(
        (file) => file.path.contains(fileName),
      ) as File;
    } catch (e) {
      return null; // Return null if file not found
    }
  }

    // Private port for the isolate communication
  final ReceivePort _port = ReceivePort();
}
