import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets.dart';
import '../../viewmodels/profile_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passFormKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _currPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _saving = false;
  bool _savingPass = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ProfileViewModel>();
      vm.loadProfile().then((_) {
        if (!mounted) return;
        _nameCtrl.text = vm.profile?['name'] ?? '';
        _emailCtrl.text = vm.profile?['email'] ?? '';
      });
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _currPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    return AppScaffold(
      title: 'Profil Saya',
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : AppPage(
              children: [
                HeroBanner(
                  title: vm.profile?['name'] ?? '',
                  subtitle: vm.profile?['email'] ?? '',
                  icon: Icons.person_rounded,
                  gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1E40AF)]),
                ),
                const SizedBox(height: 22),
                AppCard(
                  child: Form(
                    key: _formKey,
                    child: Column(children: [
                      Text('Informasi Akun',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 16),
                      TInputField(
                        controller: _nameCtrl,
                        hintText: 'Nama lengkap',
                        icon: Icons.person_rounded,
                        validator: (v) => v!.trim().isEmpty ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 14),
                      TInputField(
                        controller: _emailCtrl,
                        hintText: 'Email',
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.trim().isEmpty || !v.contains('@') ? 'Email tidak valid' : null,
                      ),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        label: 'Simpan Perubahan',
                        isLoading: _saving,
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => _saving = true);
                          final ok = await vm.updateProfile(_nameCtrl.text.trim(), _emailCtrl.text.trim());
                          if (!mounted) return;
                          setState(() => _saving = false);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(ok ? 'Profil diperbarui' : 'Gagal memperbarui'),
                            backgroundColor: ok ? Colors.green : Colors.red,
                          ));
                        },
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),
                AppCard(
                  child: Form(
                    key: _passFormKey,
                    child: Column(children: [
                      Text('Ubah Password',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 16),
                      TInputField(
                        controller: _currPassCtrl,
                        hintText: 'Password saat ini',
                        icon: Icons.lock_rounded,
                        obscureText: true,
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 14),
                      TInputField(
                        controller: _newPassCtrl,
                        hintText: 'Password baru',
                        icon: Icons.lock_outline_rounded,
                        obscureText: true,
                        validator: (v) => v!.length < 6 ? 'Minimal 6 karakter' : null,
                      ),
                      const SizedBox(height: 14),
                      TInputField(
                        controller: _confirmPassCtrl,
                        hintText: 'Konfirmasi password baru',
                        icon: Icons.verified_user_rounded,
                        obscureText: true,
                        validator: (v) => v != _newPassCtrl.text ? 'Password tidak cocok' : null,
                      ),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        label: 'Update Password',
                        isLoading: _savingPass,
                        onPressed: () async {
                          if (!_passFormKey.currentState!.validate()) return;
                          setState(() => _savingPass = true);
                          final ok = await vm.updatePassword(
                            _currPassCtrl.text,
                            _newPassCtrl.text,
                            _confirmPassCtrl.text,
                          );
                          if (!mounted) return;
                          setState(() => _savingPass = false);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(ok ? 'Password diperbarui' : 'Gagal memperbarui password'),
                            backgroundColor: ok ? Colors.green : Colors.red,
                          ));
                          if (ok) {
                            _currPassCtrl.clear();
                            _newPassCtrl.clear();
                            _confirmPassCtrl.clear();
                          }
                        },
                      ),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}