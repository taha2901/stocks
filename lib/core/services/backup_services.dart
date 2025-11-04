import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:management_stock/core/services/backup_web.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

// 🔥 Conditional Import

class BackupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 📥 تصدير كل البيانات
  Future<Map<String, dynamic>> exportAllData() async {
    try {
      final products = await _exportCollection('products');
      final customers = await _exportCollection('customers');
      final suppliers = await _exportCollection('suppliers');
      final purchaseInvoices = await _exportCollection('purchaseInvoices');
      final salesInvoices = await _exportCollection('salesInvoices');
      final payments = await _exportCollection('payments');

      return {
        'exportDate': DateTime.now().toIso8601String(),
        'products': products,
        'customers': customers,
        'suppliers': suppliers,
        'purchaseInvoices': purchaseInvoices,
        'salesInvoices': salesInvoices,
        'payments': payments,
      };
    } catch (e) {
      throw Exception('فشل في تصدير البيانات: $e');
    }
  }

  // 📥 تصدير collection معين
  // Future<List<Map<String, dynamic>>> _exportCollection(String collectionName) async {
  //   final snapshot = await _firestore.collection(collectionName).get();
  //   return snapshot.docs.map((doc) => doc.data()).toList();
  // }

  // 📥 تصدير collection معين (مع تحويل Timestamp)
  Future<List<Map<String, dynamic>>> _exportCollection(
    String collectionName,
  ) async {
    final snapshot = await _firestore.collection(collectionName).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      // تحويل كل Timestamp إلى String
      return _convertTimestamps(data);
    }).toList();
  }

  // 🔄 تحويل Timestamp إلى String
  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> data) {
    final result = <String, dynamic>{};

    data.forEach((key, value) {
      if (value is Timestamp) {
        // تحويل Timestamp إلى ISO 8601 String
        result[key] = value.toDate().toIso8601String();
      } else if (value is Map) {
        // إذا كان Map، نعمل recursive conversion
        result[key] = _convertTimestamps(Map<String, dynamic>.from(value));
      } else if (value is List) {
        // إذا كان List، نحول كل عنصر
        result[key] = value.map((item) {
          if (item is Map) {
            return _convertTimestamps(Map<String, dynamic>.from(item));
          } else if (item is Timestamp) {
            return item.toDate().toIso8601String();
          }
          return item;
        }).toList();
      } else {
        result[key] = value;
      }
    });

    return result;
  }

  // 💾 حفظ البيانات (يدعم Web, Mobile, Desktop)
  Future<String> saveBackupToFile(Map<String, dynamic> data) async {
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final fileName = 'backup_$timestamp.json';
    final jsonString = jsonEncode(data);

    if (kIsWeb) {
      // 🌐 Web: استخدام الدالة المستوردة
      return saveBackupWeb(jsonString, fileName);
    } else {
      // 📱💻 Mobile & Desktop
      return _saveBackupNative(jsonString, fileName);
    }
  }

  // 📱💻 حفظ للـ Mobile & Desktop
  Future<String> _saveBackupNative(String jsonString, String fileName) async {
    try {
      // طلب الإذن للأندرويد فقط
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('يجب السماح بالوصول للتخزين');
        }
      }

      // تحديد المسار حسب المنصة
      Directory directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else if (Platform.isWindows) {
        final docDir = await getApplicationDocumentsDirectory();
        directory = Directory('${docDir.parent.path}\\Downloads');
      } else if (Platform.isMacOS) {
        final homeDir = Platform.environment['HOME'] ?? '';
        directory = Directory('$homeDir/Downloads');
      } else if (Platform.isLinux) {
        final homeDir = Platform.environment['HOME'] ?? '';
        directory = Directory('$homeDir/Downloads');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // إنشاء المجلد إذا لم يكن موجود
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // كتابة الملف
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      throw Exception('فشل في حفظ الملف: $e');
    }
  }

  // 📤 قراءة ملف Backup (من String للـ Web)
  Map<String, dynamic> loadBackupFromString(String content) {
    try {
      return jsonDecode(content);
    } catch (e) {
      throw Exception('فشل في قراءة البيانات: $e');
    }
  }

  // 📤 قراءة ملف Backup (من File للـ Mobile/Desktop)
  Future<Map<String, dynamic>> loadBackupFromFile(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      return jsonDecode(content);
    } catch (e) {
      throw Exception('فشل في قراءة الملف: $e');
    }
  }

  // 📤 استعادة البيانات إلى Firebase
  Future<void> restoreData(Map<String, dynamic> data) async {
    try {
      if (data.containsKey('products')) {
        await _restoreCollection('products', data['products']);
      }
      if (data.containsKey('customers')) {
        await _restoreCollection('customers', data['customers']);
      }
      if (data.containsKey('suppliers')) {
        await _restoreCollection('suppliers', data['suppliers']);
      }
      if (data.containsKey('purchaseInvoices')) {
        await _restoreCollection('purchaseInvoices', data['purchaseInvoices']);
      }
      if (data.containsKey('salesInvoices')) {
        await _restoreCollection('salesInvoices', data['salesInvoices']);
      }
      if (data.containsKey('payments')) {
        await _restoreCollection('payments', data['payments']);
      }
    } catch (e) {
      throw Exception('فشل في استعادة البيانات: $e');
    }
  }

  // 📤 استعادة collection معين
  // Future<void> _restoreCollection(
  //   String collectionName,
  //   List<dynamic> items,
  // ) async {
  //   final batch = _firestore.batch();

  //   for (final item in items) {
  //     if (item is Map<String, dynamic> && item.containsKey('id')) {
  //       final docRef = _firestore.collection(collectionName).doc(item['id']);
  //       batch.set(docRef, item);
  //     }
  //   }

  //   await batch.commit();
  // }

  // 📤 استعادة collection معين (مع تحويل String إلى Timestamp)
Future<void> _restoreCollection(String collectionName, List<dynamic> items) async {
  final batch = _firestore.batch();

  for (final item in items) {
    if (item is Map<String, dynamic> && item.containsKey('id')) {
      // تحويل التواريخ من String إلى Timestamp
      final data = _convertStringsToTimestamps(item);
      
      final docRef = _firestore.collection(collectionName).doc(item['id']);
      batch.set(docRef, data);
    }
  }

  await batch.commit();
}

// 🔄 تحويل String إلى Timestamp
Map<String, dynamic> _convertStringsToTimestamps(Map<String, dynamic> data) {
  final result = <String, dynamic>{};
  
  data.forEach((key, value) {
    // قائمة بأسماء الحقول اللي فيها تاريخ
    final dateFields = [
      'invoiceDate',
      'createdAt',
      'updatedAt',
      'paymentDate',
      'dueDate',
    ];
    
    if (value is String && dateFields.contains(key)) {
      // تحويل String إلى Timestamp
      try {
        final dateTime = DateTime.parse(value);
        result[key] = Timestamp.fromDate(dateTime);
      } catch (e) {
        result[key] = value;
      }
    } else if (value is Map) {
      result[key] = _convertStringsToTimestamps(Map<String, dynamic>.from(value));
    } else if (value is List) {
      result[key] = value.map((item) {
        if (item is Map) {
          return _convertStringsToTimestamps(Map<String, dynamic>.from(item));
        }
        return item;
      }).toList();
    } else {
      result[key] = value;
    }
  });
  
  return result;
}

}
