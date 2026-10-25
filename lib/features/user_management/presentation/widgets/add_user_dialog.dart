import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/phone_util.dart';
import '../../../../models/user_directory.dart';
import '../../domen/controllers/user_management_controller.dart';

Future<void> showAddUserDialog(UserManagementController controller) {
  return Get.dialog<void>(
    _AddUserDialog(controller: controller),
    barrierDismissible: false,
  );
}

class _AddUserDialog extends StatefulWidget {
  const _AddUserDialog({required this.controller});
  final UserManagementController controller;

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  int? _professionId;
  String? _role;
  bool _saving = false;
  String? _error;

  static const _fallbackRoles = <String, String>{
    'farmer': 'Farmer',
    'officer': 'Officer',
    'expert': 'Expert',
    'admin': 'Admin',
  };

  Map<String, String> get _roles {
    final m = widget.controller.rbac.data.value;
    if (m == null || m.roles.isEmpty) return _fallbackRoles;
    return {for (final r in m.roles) r.key: r.label};
  }

  List<ProfessionCount> get _professions => widget.controller.professions;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await widget.controller.createUser(
      CreateUserRequest(
        name: _name.text.trim(),
        phone: PhoneUtil.normalize(_phone.text)!,
        professionId: _professionId!,
        role: _role!,
        location: _location.text.trim(),
      ),
    );
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
  }

  InputDecoration _decoration(String label, {String? hint}) =>
      InputDecoration(labelText: label, hintText: hint);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add new user'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'They’ll sign in to the Agvisely app with this mobile number and an OTP.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _name,
                  autofocus: true,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.words,
                  decoration: _decoration('Full name'),
                  validator:
                      (v) =>
                          (v == null || v.trim().length < 2)
                              ? 'Enter their full name.'
                              : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phone,
                  enabled: !_saving,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                    LengthLimitingTextInputFormatter(16),
                  ],
                  decoration: _decoration('Mobile number', hint: '01XXXXXXXXX'),
                  validator: PhoneUtil.validate,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  // `initialValue` only exists from Flutter 3.35; keep `value`
                  // so older SDKs (the mobile app's ^3.7) still build.
                  // ignore: deprecated_member_use
                  value: _professionId,
                  decoration: _decoration('Profession'),
                  items: [
                    for (final p in _professions)
                      DropdownMenuItem(value: p.id, child: Text(p.name)),
                  ],
                  onChanged:
                      _saving ? null : (v) => setState(() => _professionId = v),
                  validator: (v) => v == null ? 'Choose a profession.' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  // `initialValue` only exists from Flutter 3.35; keep `value`
                  // so older SDKs (the mobile app's ^3.7) still build.
                  // ignore: deprecated_member_use
                  value: _role,
                  decoration: _decoration('Role'),
                  items: [
                    for (final e in _roles.entries)
                      DropdownMenuItem(value: e.key, child: Text(e.value)),
                  ],
                  onChanged: _saving ? null : (v) => setState(() => _role = v),
                  validator: (v) => v == null ? 'Choose a role.' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _location,
                  enabled: !_saving,
                  textInputAction: TextInputAction.done,
                  decoration: _decoration(
                    'Location',
                    hint: 'Upazila, District',
                  ),
                  validator:
                      (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Enter their upazila and district.'
                              : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child:
              _saving
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text('Add user'),
        ),
      ],
    );
  }
}
