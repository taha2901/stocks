import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/cubits/deffered/cubit.dart';
import 'package:management_stock/models/deffered/defferred_account_model.dart';
import 'package:management_stock/screens/deffered/payment_reciept_print.dart';

class CustomerDetailsDialog extends StatelessWidget {
  final DeferredAccountModel account;

  const CustomerDetailsDialog({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    // 🔥 فلتر الفواتير: اعرض فقط اللي عليها فلوس
    final unpaidInvoices = account.invoices
        .where((invoice) => invoice.remainingAmount > 0)
        .toList();

    return Dialog(
      backgroundColor: const Color(0xFF2C2F48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
                Text(
                  "تفاصيل حساب: ${account.customerName}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            _buildSummaryCard(account),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${unpaidInvoices.length} فاتورة",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Text(
                  "الفواتير المستحقة:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 🔥 عرض الفواتير غير المدفوعة فقط
            if (unpaidInvoices.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    "✅ لا توجد فواتير مستحقة",
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: unpaidInvoices.length,
                  itemBuilder: (context, index) {
                    final invoice = unpaidInvoices[index];
                    return _buildInvoiceCard(context, account, invoice);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(DeferredAccountModel account) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF353855),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow("عدد الفواتير المستحقة", "${account.invoices.where((i) => i.remainingAmount > 0).length}"),
          _buildSummaryRow(
            "الإجمالي",
            "${account.totalAmount.toStringAsFixed(2)} جنيه",
          ),
          _buildSummaryRow(
            "المدفوع",
            "${account.paid.toStringAsFixed(2)} جنيه",
            color: Colors.green,
          ),
          _buildSummaryRow(
            "المتبقي",
            "${account.remaining.toStringAsFixed(2)} جنيه",
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(
    BuildContext context,
    DeferredAccountModel account,
    DeferredInvoice invoice,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF353855),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddPaymentDialog(
                      context,
                      account,
                      invoice,
                    );
                  },
                  icon: const Icon(Icons.payment, size: 16),
                  label: const Text("إضافة دفعة"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                  ),
                ),
                Text(
                  "فاتورة ${invoice.invoiceDate.day}/${invoice.invoiceDate.month}/${invoice.invoiceDate.year}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInvoiceRow(
              "الإجمالي",
              "${invoice.totalAmount.toStringAsFixed(2)} جنيه",
            ),
            _buildInvoiceRow(
              "المدفوع",
              "${invoice.paidAmount.toStringAsFixed(2)} جنيه",
              color: Colors.green,
            ),
            _buildInvoiceRow(
              "المتبقي",
              "${invoice.remainingAmount.toStringAsFixed(2)} جنيه",
              color: Colors.red,
            ),
            _buildInvoiceRow(
              "نسبة الفائدة",
              "${invoice.interestRate.toStringAsFixed(1)}%",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(color: color ?? Colors.white70, fontSize: 14),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  void _showAddPaymentDialog(
    BuildContext context,
    DeferredAccountModel account,
    DeferredInvoice invoice,
  ) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2C2F48),
        title: const Text(
          "إضافة دفعة جديدة",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.right,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "المتبقي: ${invoice.remainingAmount.toStringAsFixed(2)} جنيه",
              style: const TextStyle(color: Colors.orange, fontSize: 16),
            ),
            const SizedBox(height: 16),
            CustomInputField(
              controller: amountController,
              label: "المبلغ",
              hint: "أدخل المبلغ",
              isNumber: true,
              prefixIcon: const Icon(Icons.attach_money, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            CustomInputField(
              controller: notesController,
              label: "ملاحظات (اختياري)",
              hint: "أدخل ملاحظات",
              prefixIcon: const Icon(Icons.note, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("يرجى إدخال مبلغ صحيح"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (amount > invoice.remainingAmount) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "المبلغ أكبر من المتبقي (${invoice.remainingAmount.toStringAsFixed(2)} جنيه)",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // حفظ الدفعة
              await context.read<DeferredAccountCubit>().addPayment(
                    customerId: account.customerId,
                    invoiceId: invoice.invoiceId,
                    amount: amount,
                    notes: notesController.text.isNotEmpty
                        ? notesController.text
                        : null,
                  );

              Navigator.pop(dialogContext);

              // 🔥 عرض إيصال الدفعة
              _showPaymentReceiptDialog(
                context,
                account.customerName,
                invoice,
                amount,
                notesController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
            ),
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  void _showPaymentReceiptDialog(
    BuildContext context,
    String customerName,
    DeferredInvoice invoice,
    double paidAmount,
    String notes,
  ) {
    final newRemaining = invoice.remainingAmount - paidAmount;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2F48),
        title: const Text(
          'تم إضافة الدفعة بنجاح ✅',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildReceiptRow("العميل:", customerName),
            _buildReceiptRow("المبلغ المدفوع:", "${paidAmount.toStringAsFixed(2)} جنيه"),
            _buildReceiptRow(
              "المتبقي:",
              "${newRemaining.toStringAsFixed(2)} جنيه",
              valueColor: newRemaining > 0 ? Colors.orange : Colors.green,
            ),
            if (notes.isNotEmpty) _buildReceiptRow("ملاحظات:", notes),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentReceiptPrintWidget(
                    customerName: customerName,
                    invoiceDate: invoice.invoiceDate,
                    totalAmount: invoice.totalAmount,
                    // previousPaid: invoice.paidAmount - paidAmount,
                    previousPaid: invoice.paidAmount,
                    currentPayment: paidAmount,
                    newRemaining: newRemaining,
                    notes: notes.isNotEmpty ? notes : null,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('طباعة الإيصال'),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
