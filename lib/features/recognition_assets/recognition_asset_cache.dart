import 'dart:io';

import 'package:path_provider/path_provider.dart';

class RecognitionAssetCache {
  Future<File?> getLocalIfPresent({
    required String monumentId,
    required String version,
  }) async {
    final dir = await _versionDir(monumentId: monumentId, version: version);
    if (!await dir.exists()) {
      return null;
    }

    final files = dir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.isNotEmpty)
        .toList();
    if (files.isEmpty) {
      return null;
    }

    return files.first;
  }

  Future<File> getOrDownload({
    required String monumentId,
    required Uri remoteUrl,
    required String version,
  }) async {
    final existing = await getLocalIfPresent(
      monumentId: monumentId,
      version: version,
    );
    if (existing != null) {
      return existing;
    }

    final versionDir = await _versionDir(monumentId: monumentId, version: version);
    await versionDir.create(recursive: true);

    final fileName = remoteUrl.pathSegments.isEmpty
        ? 'asset.bin'
        : remoteUrl.pathSegments.last;
    final targetFile = File('${versionDir.path}/$fileName');

    final client = HttpClient();
    try {
      final request = await client.getUrl(remoteUrl);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Failed to download recognition asset (${response.statusCode})',
          uri: remoteUrl,
        );
      }

      final sink = targetFile.openWrite();
      await response.pipe(sink);
      await sink.close();
      return targetFile;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> clearOldVersions({
    required String monumentId,
    required String keepVersion,
  }) async {
    final monumentRoot = await _monumentRootDir(monumentId);
    if (!await monumentRoot.exists()) {
      return;
    }

    await for (final entity in monumentRoot.list()) {
      if (entity is Directory && _basename(entity.path) != keepVersion) {
        await entity.delete(recursive: true);
      }
    }
  }

  Future<Directory> _versionDir({
    required String monumentId,
    required String version,
  }) async {
    final root = await _recognitionRootDir();
    return Directory('${root.path}/$monumentId/$version');
  }

  Future<Directory> _monumentRootDir(String monumentId) async {
    final root = await _recognitionRootDir();
    return Directory('${root.path}/$monumentId');
  }

  Future<Directory> _recognitionRootDir() async {
    final supportDir = await getApplicationSupportDirectory();
    return Directory('${supportDir.path}/recognition');
  }

  String _basename(String path) {
    final sanitized = path.replaceAll('\\', '/');
    final segments = sanitized.split('/');
    return segments.isEmpty ? path : segments.last;
  }
}
