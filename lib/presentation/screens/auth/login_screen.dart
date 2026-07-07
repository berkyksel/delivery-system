import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authNotifierProvider.notifier).signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );
      // Router redirect otomatik olarak rol kontrolü yapacak
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget body = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // Logo & Brand
          _buildBrand(theme, isDark)
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.2, end: 0),
          const SizedBox(height: 48),
          // Form Card
          _buildFormCard(theme, isDark)
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 24),
          // Register Link
          _buildRegisterLink(theme)
              .animate()
              .fadeIn(delay: 300.ms, duration: 600.ms),
          const SizedBox(height: 8),
          // Admin Access
          _buildAdminAccess(isDark)
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms),
          const SizedBox(height: 24),
        ],
      ),
    );

    return Scaffold(
      body: isDark
          ? Container(
              decoration: const BoxDecoration(gradient: AppColors.darkGradient),
              child: SafeArea(child: body),
            )
          : SafeArea(child: body),
    );
  }

  Widget _buildBrand(ThemeData theme, bool isDark) {
    final titleColor = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subtitleColor = isDark ? AppColors.textSecondary : const Color(0xFF475569);
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.anchor_rounded,
            color: Colors.white,
            size: 44,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Anvers Liman',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: titleColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Teslimat Yönetim Sistemi',
          style: TextStyle(
            fontSize: 14,
            color: subtitleColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(ThemeData theme, bool isDark) {
    final cardBg = isDark ? AppColors.bgCard : Colors.white;
    final borderColor = isDark
        ? AppColors.glassBorder
        : Colors.black.withValues(alpha: 0.08);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.08);
    final titleColor = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subtitleColor = isDark ? AppColors.textSecondary : const Color(0xFF475569);
    final textColor = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Giriş Yap',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hesabınıza giriş yapın',
              style: TextStyle(color: subtitleColor, fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: textColor),
              decoration: const InputDecoration(
                labelText: 'E-posta',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'E-posta zorunludur';
                if (!value.contains('@')) return 'Geçersiz e-posta';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Şifre',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: subtitleColor,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Şifre zorunludur';
                if (value.length < 6) return 'Şifre en az 6 karakter olmalı';
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Şifremi Unuttum',
                  style: TextStyle(color: AppColors.accent),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Giriş Yap'),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  Widget _buildAdminAccess(bool isDark) {
    final textColor = isDark ? AppColors.textMuted : const Color(0xFF94A3B8);
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => _AdminLoginDialog(),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings_outlined, size: 14, color: textColor),
            const SizedBox(width: 4),
            Text(
              'Yönetici Girişi',
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                decoration: TextDecoration.underline,
                decorationColor: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textSecondary : const Color(0xFF475569);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hesabınız yok mu?',
          style: TextStyle(color: textColor),
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.register),
          child: const Text(
            'Kayıt Ol',
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Yönetici Giriş Dialog'u ───────────────────────────────────────────────────
class _AdminLoginDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends ConsumerState<_AdminLoginDialog> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _adminLogin() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() => _error = 'E-posta ve şifre zorunludur');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authNotifierProvider.notifier).signIn(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.bgCard : Colors.white;
    final textColor = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subtitleColor = isDark ? AppColors.textSecondary : const Color(0xFF475569);

    return Dialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Yönetici Girişi',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textColor)),
                      Text('Sadece yöneticiler için',
                          style: TextStyle(fontSize: 12, color: subtitleColor)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: subtitleColor, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: textColor),
              decoration: const InputDecoration(
                labelText: 'Yönetici E-posta',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Şifre',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(_obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                      color: subtitleColor),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _adminLogin,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Yönetici Olarak Giriş Yap'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

