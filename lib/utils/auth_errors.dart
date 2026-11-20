import 'package:firebase_auth/firebase_auth.dart';

String loginError(Object e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'network-request-failed':
        return 'No connection. Check your internet and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Wrong email or password.';
    }
  }
  return 'Something went wrong. Try again.';
}

final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
bool isValidEmail(String s) => _emailRe.hasMatch(s.trim());
