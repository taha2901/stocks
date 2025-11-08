import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/services/backup/backup_services.dart';
import 'package:management_stock/cubits/backup/states.dart';

class BackupCubit extends Cubit<BackupState> {
  final BackupService _backupService = BackupService();

  BackupCubit() : super(BackupInitial());

  // 📥 تصدير البيانات
  Future<void> exportData() async {
    try {
      emit(BackupLoading());

      final data = await _backupService.exportAllData();
      final result = await _backupService.saveBackupToFile(data);

      emit(BackupSuccess(result));
    } catch (e) {
      emit(BackupError(e.toString()));
    }
  }

  // 📤 استعادة البيانات (من String للـ Web)
  Future<void> restoreDataFromString(String content) async {
    try {
      emit(RestoreLoading());

      final data = _backupService.loadBackupFromString(content);
      await _backupService.restoreData(data);

      emit(RestoreSuccess('تم استعادة البيانات بنجاح!'));
    } catch (e) {
      emit(BackupError('فشل في استعادة البيانات: $e'));
    }
  }

  // 📤 استعادة البيانات (من File للـ Mobile/Desktop)
  Future<void> restoreDataFromFile(String filePath) async {
    try {
      emit(RestoreLoading());

      final data = await _backupService.loadBackupFromFile(filePath);
      await _backupService.restoreData(data);

      emit(RestoreSuccess('تم استعادة البيانات بنجاح!'));
    } catch (e) {
      emit(BackupError('فشل في استعادة البيانات: $e'));
    }
  }
}
