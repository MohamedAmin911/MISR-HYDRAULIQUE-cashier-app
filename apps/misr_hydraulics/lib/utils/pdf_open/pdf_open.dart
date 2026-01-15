import 'dart:typed_data';
import 'package:core/core.dart';

dynamic preOpenNewTab() => null;

Future<void> openPdf(Uint8List bytes, String filename,
    {dynamic preOpened}) async {
  await PrintingService.saveAndOpenPdf(bytes, filename: filename);
}
