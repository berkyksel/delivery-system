import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isAdmin = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Firebase Auth eklenince
    if (mounted) {
      setState(() => _isLoading = false);
      context.go(_isAdmin ? AppRoutes.admin : AppRoutes.home);
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
          // Admin / Şoför Toggle
          _buildRoleToggle(theme, isDark)
              .animate()
              .fadeIn(delay: 300.ms, duration: 600.ms),
          const SizedBox(height: 12),
          // Register Link
          _buildRegisterLink(theme)
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms),
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
          ],
        ),
      ),
    );
  }

  Widget _buildRoleToggle(ThemeData theme, bool isDark) {
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isAdmin = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isAdmin
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: !_isAdmin
                      ? Border.all(color: AppColors.primary.withValues(alpha: 0.5))
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_shipping_rounded,
                      size: 16,
                      color: !_isAdmin
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.textSecondary
                              : const Color(0xFF94A3B8)),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Şoför',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: !_isAdmin
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: !_isAdmin
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.textSecondary
                                : const Color(0xFF94A3B8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isAdmin = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isAdmin
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: _isAdmin
                      ? Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.5))
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      size: 16,
                      color: _isAdmin
                          ? const Color(0xFF10B981)
                          : (isDark
                              ? AppColors.textSecondary
                              : const Color(0xFF94A3B8)),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Yönetici',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _isAdmin
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: _isAdmin
                            ? const Color(0xFF10B981)
                            : (isDark
                                ? AppColors.textSecondary
                                : const Color(0xFF94A3B8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
          onPressed: () => context.push(AppRoutes.register),
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
