import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Row of single-digit boxes. Typing advances, Backspace on an empty box
/// goes back, and pasting the whole code fills every box.
class OtpBoxes extends StatelessWidget {
  const OtpBoxes({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    this.enabled = true,
    this.hasError = false,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final VoidCallback onChanged;
  final bool enabled;
  final bool hasError;

  int get _length => controllers.length;

  void _handleInput(int index, String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');

    // Typing into a box that already has a digit: keep the new one.
    if (digits.length == 2) digits = digits.substring(1);

    if (digits.length > 1) {
      // Paste (or fast typing): spread across boxes from this one.
      var i = index;
      for (final ch in digits.split('')) {
        if (i >= _length) break;
        controllers[i].text = ch;
        i++;
      }
      focusNodes[i < _length ? i : _length - 1].requestFocus();
      onChanged();
      return;
    }

    controllers[index].value = TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
    if (digits.isNotEmpty && index < _length - 1) {
      focusNodes[index + 1].requestFocus();
    }
    onChanged();
  }

  KeyEventResult _handleKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        controllers[index].text.isEmpty &&
        index > 0) {
      controllers[index - 1].clear();
      focusNodes[index - 1].requestFocus();
      onChanged();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError ? AppColors.danger : AppColors.borderStrong;
    return Semantics(
      label: 'Verification code',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < _length; i++)
            Padding(
              padding: EdgeInsets.only(right: i == _length - 1 ? 0 : 12),
              child: SizedBox(
                width: 76,
                height: 68,
                child: Focus(
                  canRequestFocus: false,
                  skipTraversal: true,
                  onKeyEvent: (_, e) => _handleKey(i, e),
                  child: TextField(
                    controller: controllers[i],
                    focusNode: focusNodes[i],
                    enabled: enabled,
                    autofocus: i == 0,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    textInputAction:
                        i == _length - 1
                            ? TextInputAction.done
                            : TextInputAction.next,
                    autofillHints:
                        i == 0 ? const [AutofillHints.oneTimeCode] : null,
                    // No maxLength: a paste must reach _handleInput whole.
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: borderColor),
                      ),
                    ),
                    onChanged: (v) => _handleInput(i, v),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
