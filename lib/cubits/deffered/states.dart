import 'package:management_stock/models/deffered/defferred_account_model.dart';

abstract class DeferredAccountState {}

class DeferredAccountInitial extends DeferredAccountState {}

class DeferredAccountLoading extends DeferredAccountState {}

class DeferredAccountLoaded extends DeferredAccountState {
  final List<DeferredAccountModel> accounts;
  final List<DeferredAccountModel> filteredAccounts;
  final String searchQuery;

  DeferredAccountLoaded({
    required this.accounts,
    List<DeferredAccountModel>? filteredAccounts,
    this.searchQuery = '',
  }) : filteredAccounts = filteredAccounts ?? accounts;
}

class DeferredAccountError extends DeferredAccountState {
  final String message;
  DeferredAccountError(this.message);
}

class PaymentAddSuccess extends DeferredAccountState {
  final String message;
  PaymentAddSuccess(this.message);
}

class PaymentAddLoading extends DeferredAccountState {}

class PaymentAddError extends DeferredAccountState {
  final String message;
  PaymentAddError(this.message);
}