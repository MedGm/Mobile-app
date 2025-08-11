import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarl_mobile_app/features/auth/controllers/auth_controller.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  final String username;
  const ChangePasswordScreen({super.key, required this.username});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  bool _showNew = false;
  bool _showConfirm = false;
  String _message = '';
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _newPassword,
                  obscureText: !_showNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    suffixIcon: IconButton(
                      icon: Icon(_showNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _showNew = !_showNew),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPassword,
                  obscureText: !_showConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(_showConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _showConfirm = !_showConfirm),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_message.isNotEmpty)
                  Text(_message, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving
                        ? null
                        : () async {
                            final newPass = _newPassword.text;
                            final confirm = _confirmPassword.text;
                            if (newPass.length < 8) {
                              setState(() => _message = 'Password must be at least 8 characters.');
                              return;
                            }
                            if (newPass != confirm) {
                              setState(() => _message = 'Passwords do not match.');
                              return;
                            }
                            setState(() => _saving = true);
                            final ok = await ref
                                .read(authControllerProvider.notifier)
                                .changePassword(widget.username, newPass);
                            if (!mounted) return;
                            setState(() => _saving = false);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;
                              final nav = Navigator.of(context);
                              if (ok) {
                                nav.pushReplacementNamed('/home');
                              } else {
                                setState(() => _message = 'Failed to update password.');
                              }
                            });
                          },
                    child: _saving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Update Password'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
