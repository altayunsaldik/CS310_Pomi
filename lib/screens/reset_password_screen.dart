import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme.dart';
import '../utils/auth_errors.dart';

/// S4
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.initialEmail = ''});
  final String initialEmail;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final TextEditingController _email =
      TextEditingController(text: widget.initialEmail);
  bool _busy = false;
  String? _error;
  String? _sentTo;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!isValidEmail(_email.text)) {
      setState(() => _error = 'Enter a valid email.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AuthService.instance.sendPasswordReset(_email.text);
      if (mounted) setState(() => _sentTo = _email.text.trim());
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _error = e.code == 'network-request-failed'
            ? 'No connection. Try again.'
            : 'Could not send the link. Check the email.');
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not send the link.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  "Enter the email you signed up with. We'll send you a link to set a new password.",
                  style: TextStyle(color: kMuted)),
              const SizedBox(height: 18),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    InputDecoration(labelText: 'Email', errorText: _error),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _busy ? null : _send,
                child: const Text('Send reset link'),
              ),
              if (_sentTo != null) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: kPanel, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.mail_outline, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(TextSpan(children: [
                          TextSpan(
                              text: 'Link sent to $_sentTo\n',
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          const TextSpan(
                              text: 'It can take a few minutes. Check your spam folder too.'),
                        ])),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to log in'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
