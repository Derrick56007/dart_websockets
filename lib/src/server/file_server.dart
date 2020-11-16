import 'dart:io';

import 'package:http_server/http_server.dart';

import 'base_server.dart';
import 'server_websocket.dart';

class FileServer extends BaseServer {
  static const basePath = 'data/';

  static const defaultFilesDirectory = 'website/build/';
  static const defaultDefaultPagePath = 'website/build/index.html';

  final VirtualDirectory _staticFiles;
  final File _defaultPage;

  FileServer(String address, int port,
      {String filesDirectory = defaultFilesDirectory, String defaultPagePath = defaultDefaultPagePath})
      : _staticFiles = VirtualDirectory(filesDirectory),
        _defaultPage = File(defaultPagePath),
        super('file', address, port) {
    _staticFiles
      ..jailRoot = false
      ..allowDirectoryListing = true
      ..directoryHandler = (dir, request) async {
        final indexUri = Uri.file(dir.path).resolve('index.html');

        var file = File(indexUri.toFilePath());

        if (!(await file.exists())) {
          file = _defaultPage;
        }
        _staticFiles.serveFile(file, request);
      };
  }

  @override
  Future<bool> onRequestPre(HttpRequest req) async {
    req.response.headers.set('cache-control', 'no-cache');
    return false;
  }

  @override
  Future<void> onRequestPost(HttpRequest req) async {
    await _staticFiles.serveRequest(req);
  }

  @override
  void handleSocketDone(HttpRequest req, ServerWebSocket socket) {}

  @override
  void handleSocketStart(HttpRequest req, ServerWebSocket socket) {}
}
