import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

     Navigator.pushReplacementNamed(
  context,
  '/home',
);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Login failed'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    if (!value.contains('@')) {
      return 'Enter a valid email';
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 40),

              Icon(
                Icons.pets,
                size: 90,
                color: Theme.of(context).primaryColor,
              ),

              const SizedBox(height: 20),

              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 10),

              Text(
                'Login to continue using UTM Paws-itive',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 40),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: _emailValidator,
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: _passwordValidator,
              ),

              const SizedBox(height: 28),

              ElevatedButton.icon(
                onPressed: _loading ? null : _login,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: Text(_loading ? 'Logging in...' : 'Login'),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: _loading
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/register');
                      },
                child: const Text('Create Account'),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Sprint 4 Demo Access',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 16),

              // --- Demo-only role shortcuts -----------------------------
              // These buttons bypass real authentication and route
              // straight to each dashboard for presentation purposes.
              // No RBAC is implemented behind them (by design).
              OutlinedButton.icon(
                onPressed: _loading
                    ? null
                    : () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/admin-dashboard',
                          (route) => false,
                        ),
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Login as Admin'),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _loading
                    ? null
                    : () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/volunteer-dashboard',
                          (route) => false,
                        ),
                icon: const Icon(Icons.volunteer_activism),
                label: const Text('Login as Volunteer'),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _loading
                    ? null
                    : () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/user-dashboard',
                          (route) => false,
                        ),
                icon: const Icon(Icons.person),
                label: const Text('Login as User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}