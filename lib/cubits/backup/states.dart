abstract class BackupState {}

class BackupInitial extends BackupState {}

class BackupLoading extends BackupState {}

class BackupSuccess extends BackupState {
  final String filePath;
  BackupSuccess(this.filePath);
}

class BackupError extends BackupState {
  final String message;
  BackupError(this.message);
}

class RestoreLoading extends BackupState {}

class RestoreSuccess extends BackupState {
  final String message;
  RestoreSuccess(this.message);
}
