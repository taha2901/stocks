// 🌐 للـ Web فقط
import 'dart:convert';
import 'dart:html' as html;

String saveBackupWeb(String jsonString, String fileName) {
  try {
    final bytes = utf8.encode(jsonString);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);

    return 'تم تنزيل الملف: $fileName';
  } catch (e) {
    throw Exception('فشل في تنزيل الملف: $e');
  }
}


