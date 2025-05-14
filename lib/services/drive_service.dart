import 'dart:io';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

/// A small HTTP client that injects Google OAuth headers.
class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();
  GoogleHttpClient(this._headers);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest req) =>
      _inner.send(req..headers.addAll(_headers));
}

class DriveService {
  final _googleSignIn = GoogleSignIn.standard(
    scopes: [drive.DriveApi.driveFileScope],
  );

  Future<drive.DriveApi> _driveApi() async {
    final acct = await _googleSignIn.signInSilently();
    if (acct == null) throw Exception('Not signed in to Google Drive');
    final headers = await acct.authHeaders;
    return drive.DriveApi(GoogleHttpClient(headers));
  }

  /// Finds (or creates) a folder by [name] under [parentId] (root if null).
  Future<String> _getOrCreateFolder(String name,
      {String? parentId}) async {
    final api = await _driveApi();
    final parent = parentId ?? 'root';
    final q = "'$parent' in parents and "
        "name='$name' and "
        "mimeType='application/vnd.google-apps.folder' and trashed=false";
    final resp = await api.files.list(q: q, $fields: 'files(id)', pageSize: 1);
    if (resp.files != null && resp.files!.isNotEmpty) {
      return resp.files!.first.id!;
    }
    // not found → create
    final folder = drive.File()
      ..name = name
      ..mimeType = 'application/vnd.google-apps.folder'
      ..parents = parentId != null ? [parentId] : null;
    final created =
    await api.files.create(folder, $fields: 'id');
    return created.id!;
  }

  /// Uploads [filePath] into VaultGuard/Backups and enforces [retainCount].
  Future<void> uploadBackupFile(String filePath,
      {int retainCount = 3}) async {
    final api = await _driveApi();

    // 1) Ensure root folders exist
    final vaultId   = await _getOrCreateFolder('VaultGuard');
    final backupsId = await _getOrCreateFolder('Backups', parentId: vaultId);

    // 2) Upload
    final media = drive.Media(
      File(filePath).openRead(),
      File(filePath).lengthSync(),
    );
    final file = drive.File()
      ..name = basename(filePath)
      ..parents = [backupsId];
    await api.files.create(file,
        uploadMedia: media, $fields: 'id');

    // 3) Retention: delete oldest if > retainCount
    final list = await api.files.list(
      q: "'$backupsId' in parents and trashed=false",
      orderBy: 'createdTime',
      $fields: 'files(id,createdTime)',
    );
    final files = list.files ?? [];
    if (files.length > retainCount) {
      final toDelete = files.take(files.length - retainCount);
      for (var f in toDelete) {
        await api.files.delete(f.id!);
      }
    }
  }
}
