import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme.dart';
import '../utils/auth_errors.dart';

/// S3
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _nameError, _emailError, _passwordError, _confirmError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _nameError = _name.text.trim().isEmpty ? 'Enter your name.' : null;
      _emailError = isValidEmail(_email.text) ? null : 'Enter a valid email.';
      _passwordError =
          _password.text.length < 6 ? 'Use at least 6 characters.' : null;
      _confirmError =
          _confirm.text != _password.text ? "Passwords don't match." : null;
    });
    if ([_nameError, _emailError, _passwordError, _confirmError]
        .any((e) => e != null)) {
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthService.instance
          .signUp(_name.text, _email.text, _password.text);
      if (mounted) {
        // Remove this screen; AuthGate now shows the timer.
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.code) {
          case 'email-already-in-use':
            _emailError = 'This email already has an account.';
            break;
          case 'invalid-email':
            _emailError = 'Enter a valid email.';
            break;
          case 'weak-password':
            _passwordError = 'Password is too weak.';
            break;
          case 'network-request-failed':
            _emailError = 'No connection. Try again.';
            break;
          default:
            _emailError = 'Could not create the account.';
        }
      });
    } catch (_) {
      if (mounted) setState(() => _emailError = 'Could not create the account.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create an account',
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800, color: kInk)),
              const SizedBox(height: 6),
              const Text('Your tasks, settings and study history are saved to it.',
                  style: TextStyle(color: kMuted)),
              const SizedBox(height: 22),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration:
                    InputDecoration(labelText: 'Name', errorText: _nameError),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    InputDecoration(labelText: 'Email', errorText: _emailError),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  helperText: 'At least 6 characters',
                  errorText: _passwordError,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _confirm,
                obscureText: true,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                    labelText: 'Confirm password', errorText: _confirmError),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Create account'),
              ),
              const SizedBox(height: 16),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Already have an account? ',
                        style: TextStyle(color: kMuted)),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Log in'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
