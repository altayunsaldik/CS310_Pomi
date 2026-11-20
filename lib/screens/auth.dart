import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🍅', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 8),
            const Text('Pomi', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text('Study timer and task list'),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ]),
        ),
      );
}

String _msg(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return 'Wrong email or password.';
    case 'invalid-email':
      return 'Enter a valid email.';
    case 'email-already-in-use':
      return 'An account with this email already exists.';
    case 'weak-password':
      return 'Password is too weak.';
    case 'network-request-failed':
      return 'No connection.';
    default:
      return e.message ?? 'Something went wrong.';
  }
}

Widget _field(TextEditingController c, String label, {bool obscure = false, TextInputType? type, String? error, Widget? suffix}) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(labelText: label, errorText: error, suffixIcon: suffix, border: const OutlineInputBorder()),
      ),
    );

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final email = TextEditingController(), pass = TextEditingController();
  bool hide = true, busy = false;
  String? err;

  Future<void> login() async {
    setState(() { busy = true; err = null; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text.trim(), password: pass.text);
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => err = _msg(e));
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.all(24), children: [
            const SizedBox(height: 24),
            const Text('🍅', style: TextStyle(fontSize: 48)),
            const Text('Log in', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const Padding(padding: EdgeInsets.only(top: 4, bottom: 20), child: Text('Use the email and password you signed up with.')),
            _field(email, 'Email', type: TextInputType.emailAddress),
            _field(pass, 'Password', obscure: hide, error: err, suffix: IconButton(icon: Icon(hide ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => hide = !hide))),
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResetScreen(email.text))), child: const Text('Forgot password?'))),
            FilledButton(onPressed: busy ? null : login, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)), child: busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Log in')),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('New here?'),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())), child: const Text('Create an account')),
            ]),
          ]),
        ),
      );
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  final name = TextEditingController(), email = TextEditingController(), pass = TextEditingController(), pass2 = TextEditingController();
  String? nameE, emailE, passE, pass2E;
  bool busy = false;

  Future<void> create() async {
    setState(() {
      nameE = name.text.trim().isEmpty ? 'Enter your name.' : null;
      emailE = email.text.contains('@') ? null : 'Enter a valid email.';
      passE = pass.text.length < 6 ? 'At least 6 characters.' : null;
      pass2E = pass.text != pass2.text ? "Passwords don't match." : null;
    });
    if ([nameE, emailE, passE, pass2E].any((e) => e != null)) return;
    setState(() => busy = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text.trim(), password: pass.text);
      await cred.user?.updateDisplayName(name.text.trim());
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({'name': name.text.trim(), 'email': email.text.trim()}, SetOptions(merge: true));
      if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() { busy = false; if (e.code == 'weak-password') { passE = _msg(e); } else { emailE = _msg(e); } });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          const Text('Create an account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const Padding(padding: EdgeInsets.only(top: 4, bottom: 20), child: Text('Your tasks, settings and study history are saved to it.')),
          _field(name, 'Name', error: nameE),
          _field(email, 'Email', type: TextInputType.emailAddress, error: emailE),
          _field(pass, 'Password', obscure: true, error: passE),
          _field(pass2, 'Confirm password', obscure: true, error: pass2E),
          FilledButton(onPressed: busy ? null : create, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)), child: const Text('Create account')),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Already have an account?'),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Log in')),
          ]),
        ]),
      );
}

class ResetScreen extends StatefulWidget {
  final String initial;
  const ResetScreen(this.initial, {super.key});
  @override
  State<ResetScreen> createState() => _ResetState();
}

class _ResetState extends State<ResetScreen> {
  late final email = TextEditingController(text: widget.initial);
  bool sent = false;
  String? err;

  Future<void> send() async {
    setState(() => err = null);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
      if (mounted) setState(() => sent = true);
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => err = _msg(e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Reset password')),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          const Padding(padding: EdgeInsets.only(bottom: 16), child: Text("Enter the email you signed up with. We'll send you a link to set a new password.")),
          _field(email, 'Email', type: TextInputType.emailAddress, error: err),
          FilledButton(onPressed: send, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)), child: const Text('Send reset link')),
          if (sent)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
              child: Text('Link sent to ${email.text.trim()}. It can take a few minutes. Check your spam folder too.'),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back to log in')),
        ]),
      );
}
