import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../presentation/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.driver;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).register(
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
            firstName: _firstNameCtrl.text,
            lastName: _lastNameCtrl.text,
            vehiclePlate: _plateCtrl.text.isEmpty ? null : _plateCtrl.text,
            role: _selectedRole,
          );
      // Router redirect otomatik olarak role göre yönlendirir
    } catch (e) {
      if (mounted) {
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildPersonalInfo()
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: -0.1, end: 0),
                        const SizedBox(height: 16),
                        _buildAccountInfo()
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 400.ms)
                            .slideX(begin: -0.1, end: 0),
                        const SizedBox(height: 16),
                        _buildVehicleInfo()
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 400.ms)
                            .slideX(begin: -0.1, end: 0),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Hesap Oluştur'),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 400.ms),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () => context.go(AppRoutes.login),
          ),
          const Expanded(
            child: Text(
              'Kayıt Ol',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return _buildSectionCard(
      title: 'KİŞİSEL BİLGİLER',
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Ad'),
                validator: (v) => v?.isEmpty == true ? 'Zorunlu' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _lastNameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Soyad'),
                validator: (v) => v?.isEmpty == true ? 'Zorunlu' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: UserRole.values
              .map((role) => Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = role),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(
                            right: role == UserRole.driver ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedRole == role
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedRole == role
                                ? AppColors.primary
                                : AppColors.glassBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              role == UserRole.driver
                                  ? Icons.drive_eta_rounded
                                  : Icons.manage_accounts_rounded,
                              color: _selectedRole == role
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              role.label,
                              style: TextStyle(
                                fontSize: 12,
                                color: _selectedRole == role
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAccountInfo() {
    return _buildSectionCard(
      title: 'HESAP BİLGİLERİ',
      children: [
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'E-posta',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'E-posta zorunludur';
            if (!v.contains('@')) return 'Geçersiz e-posta';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Şifre',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Şifre zorunludur';
            if (v.length < 6) return 'En az 6 karakter';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildVehicleInfo() {
    return _buildSectionCard(
      title: 'ARAÇ BİLGİLERİ (OPSİYONEL)',
      children: [
        TextFormField(
          controller: _plateCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Plaka',
            prefixIcon: Icon(Icons.directions_car_rounded),
            hintText: '1-ABC-123',
          ),
        ),
      ],
    );
  }
}
