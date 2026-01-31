import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class PrintingService {
  static Future<void> printPdf(Uint8List bytes,
      {String jobName = 'إيصال ELAboudy'}) async {
    try {
      await Printing.info();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: jobName,
        format: PdfPageFormat.a4,
        dynamicLayout: false,
      );
    } catch (_) {}
  }

  static Future<String?> savePdf(Uint8List bytes, {String? filename}) async {
    try {
      final dir = await getTemporaryDirectory();
      final name = filename?.trim().isNotEmpty == true
          ? filename!
          : 'receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final path = p.join(dir.path, name);
      final f = File(path);
      await f.writeAsBytes(bytes, flush: true);
      return path;
    } catch (_) {
      return null;
    }
  }

  static Future<void> openFile(String path) async {
    if (Platform.isWindows) {
      await Process.run('cmd', ['/c', 'start', '', path]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [path]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [path]);
    }
  }

  static Future<void> saveAndOpenPdf(Uint8List bytes,
      {String? filename}) async {
    final path = await savePdf(bytes, filename: filename);
    if (path != null) {
      await openFile(path);
    }
  }
}
