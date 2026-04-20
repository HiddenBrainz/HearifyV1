import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/auth_design_system.dart';

/// Label + dark-rounded-rectangle text input. Placeholder can be tinted
/// with the brand-blue (as in the email field of the mock) by passing
/// [placeholderStyle].
class HearifyTextField extends StatelessWidget {
  const HearifyTextField({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.placeholderStyle,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onSubmitted,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final TextStyle? placeholderStyle;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;
  final bool autocorrect;
  final bool enableSuggestions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.inputLabel),
        const SizedBox(height: AppSpacing.m),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppRadii.input),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            onSubmitted: onSubmitted,
            autocorrect: autocorrect,
            enableSuggestions: enableSuggestions,
            cursorColor: AppColors.linkBlue,
            style: AppTextStyles.inputText,
            decoration: InputDecoration(
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: 18,
              ),
              hintText: placeholder,
              hintStyle: placeholderStyle ?? AppTextStyles.placeholder,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
            ),
          ),
        ),
      ],
    );
  }
}
