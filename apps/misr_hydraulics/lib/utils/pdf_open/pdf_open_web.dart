import 'dart:convert';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

html.WindowBase? preOpenNewTab() {
// Open a new tab synchronously (user gesture)
  final w = html.window.open('about:blank', '_blank');
  final win = w is html.Window ? w : null;
  if (win != null) {
// Prepare an HTML page that waits for a message, embeds the PDF, and auto-prints
    final htmlDoc = '''

<!doctype html><html lang="ar" dir="rtl"> <head> <meta charset="utf-8"> <title>إيصال</title> <style> body { font-family: system-ui, sans-serif; margin: 0; } .msg { padding: 24px; } a { color: #2563EB; } </style> </head> <body> <div class="msg">جاري تجهيز الإيصال...</div> <script> function safePrintFrame(frame) { try { frame.contentWindow && frame.contentWindow.focus(); frame.contentWindow && frame.contentWindow.print(); } catch (err) { console.error(err); } }

window.addEventListener('message', function (e) {
  try {
    const dataUrl = e && e.data && e.data.dataUrl;
    if (!dataUrl) return;

    const msg = document.querySelector('.msg');
    if (msg) msg.textContent = 'جارٍ الطباعة...';

    const iframe = document.createElement('iframe');
    iframe.style.position = 'fixed';
    iframe.style.right = '0';
    iframe.style.bottom = '0';
    iframe.style.width = '0';
    iframe.style.height = '0';
    iframe.style.border = '0';
    iframe.src = dataUrl;
    document.body.appendChild(iframe);

    iframe.onload = function () {
      setTimeout(function () {
        safePrintFrame(iframe);
        // Try auto-close after print in browsers that support it
        try { window.onafterprint = function() { window.close(); }; } catch (err) {}
      }, 100);
    };
  } catch (err) {
    console.error(err);
    document.body.innerHTML =
      '<div class="msg">تعذر الطباعة تلقائيًا. <a href="#" id="dl">انقر هنا لفتح الملف</a></div>';
    const link = document.getElementById('dl');
    link && link.addEventListener('click', function () {
      // The opener will send the URL again if needed; this is just a fallback link
      window.open(dataUrl, '_blank');
    });
  }
}, { once: true });
</script></body> </html> ''';

// Load the prepared page using a data URL (no document.write needed)
    final docUrl =
        'data:text/html;base64,${base64Encode(utf8.encode(htmlDoc))}';
    win.location.href = docUrl;
  }
  return w;
}

Future<void> openPdf(Uint8List bytes, String filename,
    {html.WindowBase? preOpened}) async {
// Send the PDF as a base64 data URL for reliable cross-window loading/printing
  final dataUrl = 'data:application/pdf;base64,${base64Encode(bytes)}';

  if (preOpened != null) {
    preOpened.postMessage({'dataUrl': dataUrl}, '*');
  } else {
// Fallback if the pre-opened tab was blocked: just open the PDF tab
    html.window.open(dataUrl, '_blank');
  }
}
