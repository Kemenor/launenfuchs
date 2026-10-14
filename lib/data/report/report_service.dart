import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_file_dialog/flutter_file_dialog.dart';

/// Writes a report through the system save dialog (the Fuchsbau export
/// pattern: a temp file path, never bytes). Returns the saved size, or null
/// when cancelled.
class ReportService {
  Future<int?> saveHtml(String html, String baseName) =>
      _save(utf8.encode(html), '$baseName.html', 'text/html');

  Future<int?> savePdf(Uint8List pdf, String baseName) =>
      _save(pdf, '$baseName.pdf', 'application/pdf');

  Future<int?> _save(List<int> bytes, String name, String mime) async {
    final file = File('${Directory.systemTemp.path}/$name');
    await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);
    try {
      final saved = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          sourceFilePath: file.path,
          fileName: name,
          mimeTypesFilter: [mime],
        ),
      );
      return saved != null ? bytes.length : null;
    } finally {
      if (await file.exists()) await file.delete();
    }
  }
}
