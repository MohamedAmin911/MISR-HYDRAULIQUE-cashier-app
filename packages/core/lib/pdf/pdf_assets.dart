import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

class PdfAssets {
  static const fr = 'packages/core/assets/fonts/Tajawal-Regular.ttf';
  static const fb = 'packages/core/assets/fonts/Tajawal-Bold.ttf';
  // static const lg = 'packages/core/assets/images/company_logo.png';
  static const header = 'packages/core/assets/images/strip.jpg';

  static pw.Font? _regular;
  static pw.Font? _bold;
  // static pw.MemoryImage? _logo;
  static pw.MemoryImage? _headerStrip;
  static Future<void> preload() async {
    _regular ??= pw.Font.ttf(await rootBundle.load(fr));
    _bold ??= pw.Font.ttf(await rootBundle.load(fb));
    // _logo ??= pw.MemoryImage((await rootBundle.load(lg)).buffer.asUint8List());
    _headerStrip ??=
        pw.MemoryImage((await rootBundle.load(header)).buffer.asUint8List());
  }

  static Future<void> ensureLoaded() => preload();

  static pw.Font get regular => _regular!;
  static pw.Font get bold => _bold!;
  // static pw.MemoryImage? get logo => _logo;
  static pw.MemoryImage? get headerStrip => _headerStrip;
}
