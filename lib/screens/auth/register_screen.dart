import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets.dart';           // IconBox, TInputField, PrimaryButton
import '../../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();

    final success = await authVM.register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
      _confirmCtrl.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      // Tampilkan snackbar sebelum navigasi (agar context masih valid)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan masuk dengan akun baru Anda.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVM.errorMessage ?? 'Registrasi gagal. Periksa data Anda.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconBox(
                  icon: Icons.person_add_alt_1_rounded,
                  color: theme.colorScheme.primary,
                  size: 92,
                  iconSize: 46,
                ),
                const SizedBox(height: 28),

                Text(
                  'Buat Akun Baru',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Mulai catat pemasukan, pengeluaran, dan tabungan Anda',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TInputField(
                        controller: _nameCtrl,
                        hintText: 'Nama lengkap',
                        icon: Icons.person_rounded,
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            (v?.trim().length ?? 0) < 3 ? 'Nama minimal 3 karakter' : null,
                      ),
                      const SizedBox(height: 16),

                      TInputField(
                        controller: _emailCtrl,
                        hintText: 'Email',
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                          if (!v.contains('@')) return 'Format email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TInputField(
                        controller: _passCtrl,
                        hintText: 'Password',
                        icon: Icons.lock_rounded,
                        obscureText: _obscurePass,
                        textInputAction: TextInputAction.next,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          ),
                          onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        ),
                        validator: (v) => (v?.length ?? 0) < 6
                            ? 'Password minimal 6 karakter'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TInputField(
                        controller: _confirmCtrl,
                        hintText: 'Konfirmasi password',
                        icon: Icons.verified_user_rounded,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          ),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        validator: (v) =>
                            v != _passCtrl.text ? 'Konfirmasi password tidak cocok' : null,
                      ),

                      const SizedBox(height: 24),

                      PrimaryButton(
                        label: 'Daftar',
                        isLoading: authVM.isLoading,
                        onPressed: _register,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      child: const Text('Masuk'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}