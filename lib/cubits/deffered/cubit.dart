import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/services/deffered_account_services.dart';
import 'package:management_stock/cubits/deffered/states.dart';
import 'package:management_stock/models/deffered/defferred_account_model.dart';
import 'package:uuid/uuid.dart';

class DeferredAccountCubit extends Cubit<DeferredAccountState> {
  final DeferredAccountServices _services;

  DeferredAccountCubit(this._services) : super(DeferredAccountInitial());

  List<DeferredAccountModel> _allAccounts = [];

  Future<void> fetchDeferredAccounts() async {
    emit(DeferredAccountLoading());
    try {
      final accounts = await _services.getDeferredAccounts();
      _allAccounts = accounts;
      emit(DeferredAccountLoaded(accounts: accounts));
    } catch (e) {
      emit(DeferredAccountError('فشل في تحميل الحسابات: $e'));
    }
  }

  void listenToDeferredAccounts() {
    _services.deferredAccountsStream().listen(
      (accounts) {
        _allAccounts = accounts;
        if (state is DeferredAccountLoaded) {
          final currentState = state as DeferredAccountLoaded;
          _applySearch(currentState.searchQuery);
        } else {
          emit(DeferredAccountLoaded(accounts: accounts));
        }
      },
      onError: (error) {
        emit(DeferredAccountError('خطأ في الاستماع للحسابات: $error'));
      },
    );
  }

  void searchAccounts(String query) {
    _applySearch(query);
  }

  void _applySearch(String query) {
    if (query.isEmpty) {
      emit(DeferredAccountLoaded(
        accounts: _allAccounts,
        searchQuery: '',
      ));
    } else {
      final filtered = _allAccounts
          .where((account) =>
              account.customerName.toLowerCase().contains(query.toLowerCase()))
          .toList();
      emit(DeferredAccountLoaded(
        accounts: _allAccounts,
        filteredAccounts: filtered,
        searchQuery: query,
      ));
    }
  }

  Future<void> addPayment({
    required String customerId,
    required String invoiceId,
    required double amount,
    String paymentMethod = 'كاش',
    String? notes,
  }) async {
    emit(PaymentAddLoading());
    try {
      final payment = PaymentRecord(
        id: const Uuid().v4(),
        paymentDate: DateTime.now(),
        amount: amount,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      await _services.addPaymentToInvoice(
        customerId: customerId,
        invoiceId: invoiceId,
        payment: payment,
      );

      emit(PaymentAddSuccess('✅ تم إضافة الدفعة بنجاح'));
      await fetchDeferredAccounts();
    } catch (e) {
      emit(PaymentAddError('❌ فشل في إضافة الدفعة: $e'));
    }
  }

  Future<DeferredAccountModel?> getCustomerAccount(String customerId) async {
    try {
      return await _services.getCustomerDeferredAccount(customerId);
    } catch (e) {
      emit(DeferredAccountError('❌ فشل في تحميل حساب العميل: $e'));
      return null;
    }
  }
}
