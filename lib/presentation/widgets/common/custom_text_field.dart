import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      focusNode: focusNode,
      textInputAction: textInputAction,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
            : null,
        suffixIcon: suffix,
      ),
    );
  }
}

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
            : null,
      ),
      items: items,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      dropdownColor: AppColors.surface,
    );
  }
}
