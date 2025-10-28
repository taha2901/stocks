import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool isPassword;
  final bool isNumber;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final List<String>? items; // ✅ لو عايز Dropdown أو List
  final String? selectedValue;
  final Function(String?)? onItemSelected;
  final Function(String)? onChanged;
  final Function()? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showBottomSheet; // ✅ لو true يفتح قائمة كبيرة تحت بدل من Dropdown
  final String? Function(String?)? validator;
  final TextInputType? keyboardType; // ✅ أضفناها هنا

  const CustomInputField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.isPassword = false,
    this.isNumber = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.items,
    this.selectedValue,
    this.onItemSelected,
    this.onChanged,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.showBottomSheet = false,
    this.validator,
    this.keyboardType, // ✅ أضفناها هنا
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ لو فيه قائمة اختيارات نحول الحقل لـ Dropdown
    if (widget.items != null && widget.items!.isNotEmpty) {
      return widget.showBottomSheet
          ? _buildBottomSheetSelector(context)
          : _buildDropdownField(context);
    }

    // ✅ TextField عادي
    return _buildTextField(context);
  }

  Widget _buildTextField(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      enabled: widget.enabled,
      readOnly: widget.readOnly,

      keyboardType:
          widget.keyboardType ??
          (widget.isNumber ? TextInputType.number : TextInputType.text),

      maxLines: widget.isPassword ? 1 : widget.maxLines,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      validator: widget.validator,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(context).copyWith(
        border: InputBorder.none,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : widget.suffixIcon,
      ),
    );
  }

  Widget _buildDropdownField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F48),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonFormField<String>(
        value: widget.selectedValue,
        dropdownColor: const Color(0xFF2C2F48),
        decoration: _decoration(context).copyWith(border: InputBorder.none),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
        items: widget.items!
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: const TextStyle(color: Colors.white)),
              ),
            )
            .toList(),
        onChanged: widget.onItemSelected,
        validator: widget.validator,
      ),
    );
  }

  Widget _buildBottomSheetSelector(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final selected = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: const Color(0xFF2C2F48),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                "اختر من القائمة",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ...widget.items!.map(
                (e) => ListTile(
                  title: Text(e, style: const TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(ctx, e),
                ),
              ),
            ],
          ),
        );

        if (selected != null && widget.onItemSelected != null) {
          widget.onItemSelected!(selected);
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          controller: TextEditingController(text: widget.selectedValue ?? ''),
          decoration: _decoration(context).copyWith(
            suffixIcon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(BuildContext context) {
    return InputDecoration(
      labelText: widget.label,
      labelStyle: const TextStyle(color: Colors.white70),
      hintText: widget.hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF2C2F48),
      prefixIcon: widget.prefixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
