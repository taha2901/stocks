import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:management_stock/cubits/backup/cubit.dart';
import 'package:management_stock/cubits/backup/states.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2030),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F48),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'النسخ الاحتياطي 💾',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.backup, color: Colors.white, size: 24),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<BackupCubit, BackupState>(
        listener: (context, state) {
          if (state is BackupSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.filePath),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 5),
              ),
            );
          } else if (state is RestoreSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is BackupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 40),
              BlocBuilder<BackupCubit, BackupState>(
                builder: (context, state) {
                  if (state is BackupLoading || state is RestoreLoading) {
                    return const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('جاري المعالجة...', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      _buildExportButton(context),
                      const SizedBox(height: 20),
                      _buildRestoreButton(context),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F48),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'ℹ️ معلومات',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '• النسخة الاحتياطية تحفظ كل بياناتك',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          Text(
            kIsWeb 
                ? '• سيتم تنزيل الملف في Downloads' 
                : '• يتم حفظ الملف في مجلد Downloads',
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          const Text(
            '• يُنصح بعمل نسخة احتياطية كل أسبوع',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          const Text(
            '⚠️ استعادة البيانات ستستبدل البيانات الحالية',
            style: TextStyle(color: Colors.orange, fontSize: 14, height: 1.5, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.read<BackupCubit>().exportData(),
        icon: const Icon(Icons.download, size: 24),
        label: const Text('تصدير نسخة احتياطية', style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildRestoreButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _handleRestore(context),
        icon: const Icon(Icons.restore, size: 24),
        label: const Text('استعادة من نسخة احتياطية', style: TextStyle(fontSize: 18)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.orange,
          side: const BorderSide(color: Colors.orange, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _handleRestore(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: kIsWeb, // مهم للـ Web
    );

    if (result != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF2C2F48),
          title: const Text('تأكيد الاستعادة', style: TextStyle(color: Colors.white)),
          content: const Text(
            'هل أنت متأكد؟ سيتم استبدال جميع البيانات الحالية.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('نعم، استعادة'),
            ),
          ],
        ),
      );

      if (confirm == true && context.mounted) {
        if (kIsWeb) {
          // 🌐 Web: قراءة من bytes
          final bytes = result.files.single.bytes;
          if (bytes != null) {
            final content = String.fromCharCodes(bytes);
            context.read<BackupCubit>().restoreDataFromString(content);
          }
        } else {
          // 📱💻 Mobile/Desktop: قراءة من file path
          final path = result.files.single.path;
          if (path != null) {
            context.read<BackupCubit>().restoreDataFromFile(path);
          }
        }
      }
    }
  }
}
