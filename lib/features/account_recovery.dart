import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/services.dart';
import '../core/workflows.dart';
import 'workflow_pages.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});
  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _busy = false;
  Future<void> _check() async {
    setState(() => _busy = true);
    await runAction(context, () async {
      await FirebaseAuth.instance.currentUser!.reload();
      await FirebaseAuth.instance.currentUser!.getIdToken(true);
      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        throw StateError('Verification is not complete yet.');
      }
    }, success: 'Email verified.');
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Verify your email')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Open the verification link sent to ${FirebaseAuth.instance.currentUser?.email}.',
          ),
          FilledButton(
            onPressed: _busy ? null : _check,
            child: const Text('I have verified my email'),
          ),
          TextButton(
            onPressed: _busy
                ? null
                : () => runAction(
                    context,
                    () => FirebaseAuth.instance.currentUser!
                        .sendEmailVerification(),
                    success: 'Verification email sent.',
                  ),
            child: const Text('Resend email'),
          ),
          TextButton(
            onPressed: () => AuthService.instance.signOut(),
            child: const Text('Sign out'),
          ),
        ],
      ),
    ),
  );
}

class RecoverProfilePage extends StatefulWidget {
  const RecoverProfilePage({super.key});
  @override
  State<RecoverProfilePage> createState() => _RecoverProfilePageState();
}

class _RecoverProfilePageState extends State<RecoverProfilePage> {
  final _name = TextEditingController();
  bool _busy = false;
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Complete your profile')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Your sign-in exists, but profile setup did not finish. You can safely retry here.',
          ),
          TextField(
            controller: _name,
            maxLength: 100,
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          FilledButton(
            onPressed: _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    await runAction(context, () async {
                      await Workflows.instance.call('recoverProfile', {
                        'fullName': _name.text.trim(),
                      });
                    });
                    if (mounted) setState(() => _busy = false);
                  },
            child: const Text('Complete setup'),
          ),
          TextButton(
            onPressed: () => AuthService.instance.signOut(),
            child: const Text('Sign out'),
          ),
        ],
      ),
    ),
  );
}
