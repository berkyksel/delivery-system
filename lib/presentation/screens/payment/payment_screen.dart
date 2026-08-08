import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../data/repositories/user_repository.dart';

// ── Seçili plan provider ──────────────────────────────────────────────────────
final _selectedPlanProvider = StateProvider<int>((ref) => 1); // 0=Aylık, 1=Yıllık

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen>
    with TickerProviderStateMixin {
  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isPaid = false;
  bool _obscureCvv = true;
  late AnimationController _successController;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardNameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _successController.dispose();
    super.dispose();
  }

  // Kart numarası formatla: XXXX XXXX XXXX XXXX
  String _formatCardNumber(String value) {
    value = value.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(value[i]);
    }
    return buffer.toString();
  }

  // Son kullanma tarihi formatla: MM/YY
  String _formatExpiry(String value) {
    value = value.replaceAll('/', '');
    if (value.length >= 2) {
      return '${value.substring(0, 2)}/${value.substring(2)}';
    }
    return value;
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simüle ödeme işlemi (2 saniye gecikme)
      await Future.delayed(const Duration(seconds: 2));

      // Firebase'de ödeme durumunu güncelle
      final user = ref.read(currentFirebaseUserProvider);
      if (user != null) {
        await UserRepository().completePayment(user.uid);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPaid = true;
        });
        _successController.forward();

        // 2.5 saniye sonra ana sayfaya yönlendir
        await Future.delayed(const Duration(milliseconds: 2500));
        if (mounted) {
          context.go(AppRoutes.home);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ödeme işlemi başarısız: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _skipPayment() async {
    // Router redirect mantığı isPaid != true olan kullanıcıyı
    // tekrar ödeme sayfasına gönderir. Bunu engellemek için
    // Firebase'de isPaid = true yapıp sonra home'a geçiyoruz.
    try {
      final user = ref.read(currentFirebaseUserProvider);
      if (user != null) {
        await UserRepository().completePayment(user.uid);
      }
    } catch (_) {
      // Hata olsa bile home'a yönlendir
    }
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isPaid) {
      return _buildSuccessScreen(isDark);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF0A0E1A), Color(0xFF0D1B2A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      _buildPlanSelector(isDark)
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 20),
                      _buildPaymentForm(isDark)
                          .animate()
                          .fadeIn(delay: 150.ms, duration: 500.ms)
                          .slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 20),
                      _buildPayButton(isDark)
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 500.ms),
                      const SizedBox(height: 12),
                      _buildSecurityBadge(isDark)
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 500.ms),
                      const SizedBox(height: 16),
                      _buildSkipButton(isDark)
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 500.ms),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final titleColor = isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? AppColors.textSecondary : const Color(0xFF475569);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.anchor_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anvers Liman',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    'Premium Abonelik',
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Güvenli',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium_rounded,
                    color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sınırsız Erişim Aktifleştir',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tüm teslimat ve raporlara tam erişim',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSelector(bool isDark) {
    return Consumer(
      builder: (context, ref, _) {
        final selected = ref.watch(_selectedPlanProvider);
        final plans = [
          {
            'title': 'Aylık',
            'price': '€19.99',
            'period': '/ay',
            'badge': null,
            'savings': null,
          },
          {
            'title': 'Yıllık',
            'price': '€9.99',
            'period': '/ay',
            'badge': '🔥 En Popüler',
            'savings': '%50 Tasarruf',
          },
        ];

        final cardBg = isDark ? AppColors.bgCard : Colors.white;
        final borderColor = isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.07);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PLAN SEÇ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textSecondary
                      : const Color(0xFF64748B),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: plans.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final plan = entry.value;
                  final isSelected = selected == idx;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => ref
                          .read(_selectedPlanProvider.notifier)
                          .state = idx,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.only(right: idx == 0 ? 8 : 0),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : const Color(0xFFE2E8F0)),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (plan['badge'] != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  plan['badge']!,
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  plan['title']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                            ? AppColors.textSecondary
                                            : const Color(0xFF64748B)),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle_rounded,
                                      color: AppColors.primary, size: 16),
                              ],
                            ),
                            const SizedBox(height: 6),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: plan['price']!,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? AppColors.primary
                                          : (isDark
                                              ? AppColors.textPrimary
                                              : const Color(0xFF0F172A)),
                                    ),
                                  ),
                                  TextSpan(
                                    text: plan['period']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.textSecondary
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (plan['savings'] != null) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  plan['savings']!,
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              // Özellikler
              _buildFeatureRow(isDark, Icons.check_rounded, AppColors.success,
                  'Sınırsız teslimat oluşturma'),
              const SizedBox(height: 6),
              _buildFeatureRow(isDark, Icons.check_rounded, AppColors.success,
                  'Gerçek zamanlı tarife hesaplama'),
              const SizedBox(height: 6),
              _buildFeatureRow(isDark, Icons.check_rounded, AppColors.success,
                  'Tüm geçmiş raporlar'),
              const SizedBox(height: 6),
              _buildFeatureRow(isDark, Icons.check_rounded, AppColors.success,
                  'Öncelikli müşteri desteği'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureRow(
      bool isDark, IconData icon, Color color, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 12),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentForm(bool isDark) {
    final cardBg = isDark ? AppColors.bgCard : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.07);
    final textColor =
        isDark ? AppColors.textPrimary : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? AppColors.textSecondary : const Color(0xFF475569);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.credit_card_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'KART BİLGİLERİ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: subtitleColor,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                // Kart logoları
                Row(
                  children: ['💳', '🏦'].map((e) => Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(e, style: const TextStyle(fontSize: 18)),
                  )).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Kart üzerindeki görsel
            _buildCardVisual(isDark),
            const SizedBox(height: 20),
            // Kart Numarası
            TextFormField(
              controller: _cardNumberCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textColor, letterSpacing: 2),
              maxLength: 19,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final text = _formatCardNumber(newValue.text);
                  return TextEditingValue(
                    text: text,
                    selection: TextSelection.collapsed(offset: text.length),
                  );
                }),
              ],
              decoration: InputDecoration(
                labelText: 'Kart Numarası',
                prefixIcon: const Icon(Icons.credit_card_rounded),
                counterText: '',
                hintText: '0000 0000 0000 0000',
                hintStyle: TextStyle(color: subtitleColor.withValues(alpha: 0.5)),
              ),
              validator: (v) {
                if (v == null || v.replaceAll(' ', '').length < 16) {
                  return 'Geçerli bir kart numarası girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            // Kart Sahibi
            TextFormField(
              controller: _cardNameCtrl,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: textColor),
              decoration: const InputDecoration(
                labelText: 'Kart Sahibinin Adı',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ad Soyad zorunludur';
                return null;
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                // Son Kullanma
                Expanded(
                  child: TextFormField(
                    controller: _expiryCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: textColor),
                    maxLength: 5,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        final text = _formatExpiry(newValue.text);
                        return TextEditingValue(
                          text: text,
                          selection:
                              TextSelection.collapsed(offset: text.length),
                        );
                      }),
                    ],
                    decoration: InputDecoration(
                      labelText: 'AA/YY',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                      counterText: '',
                      hintText: 'AA/YY',
                      hintStyle:
                          TextStyle(color: subtitleColor.withValues(alpha: 0.5)),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 5) {
                        return 'Geçersiz tarih';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // CVV
                Expanded(
                  child: TextFormField(
                    controller: _cvvCtrl,
                    keyboardType: TextInputType.number,
                    obscureText: _obscureCvv,
                    style: TextStyle(color: textColor),
                    maxLength: 3,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      counterText: '',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCvv
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                          color: subtitleColor,
                        ),
                        onPressed: () =>
                            setState(() => _obscureCvv = !_obscureCvv),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 3) {
                        return 'Geçersiz CVV';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardVisual(bool isDark) {
    return AnimatedBuilder(
      animation: _cardNumberCtrl,
      builder: (context, _) {
        final rawNumber = _cardNumberCtrl.text.replaceAll(' ', '');
        final displayNumber = rawNumber.isEmpty
            ? '•••• •••• •••• ••••'
            : _formatCardNumber(rawNumber.padRight(16, '•'));
        final name = _cardNameCtrl.text.isEmpty
            ? 'AD SOYAD'
            : _cardNameCtrl.text.toUpperCase();
        final expiry = _expiryCtrl.text.isEmpty ? 'AA/YY' : _expiryCtrl.text;

        return Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF0288D1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Dekoratif daireler
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: 60,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              // İçerik
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.anchor_rounded,
                            color: Colors.white, size: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'VISA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              expiry,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPayButton(bool isDark) {
    return Consumer(
      builder: (context, ref, _) {
        final selectedPlan = ref.watch(_selectedPlanProvider);
        final price = selectedPlan == 0 ? '€19.99' : '€9.99';
        final period = selectedPlan == 0 ? '/ay' : '/ay (yıllık)';

        return SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Ödeme İşleniyor...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_rounded, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'Güvenli Öde — $price$period',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSecurityBadge(bool isDark) {
    final subtitleColor =
        isDark ? AppColors.textSecondary : const Color(0xFF94A3B8);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_rounded, color: AppColors.success, size: 14),
            const SizedBox(width: 5),
            Text(
              '256-bit SSL şifreleme ile korunmaktadır',
              style: TextStyle(color: subtitleColor, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'İstediğiniz zaman iptal edebilirsiniz',
          style: TextStyle(color: subtitleColor, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildSkipButton(bool isDark) {
    final subtitleColor =
        isDark ? AppColors.textSecondary : const Color(0xFF94A3B8);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: dividerColor, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'veya',
                style: TextStyle(color: subtitleColor, fontSize: 11),
              ),
            ),
            Expanded(child: Divider(color: dividerColor, thickness: 1)),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _skipPayment,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_forward_rounded,
                size: 15,
                color: subtitleColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Ödemeden Geç',
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessScreen(bool isDark) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF0A0E1A), Color(0xFF0D1B2A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Başarı ikonu
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 60,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 24),
              const Text(
                'Ödeme Başarılı! 🎉',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
              const SizedBox(height: 8),
              Text(
                'Anvers Liman\'a hoş geldiniz!\nHesabınız aktifleştirildi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? AppColors.textSecondary
                      : const Color(0xFF475569),
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark
                          ? AppColors.textSecondary
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Ana sayfaya yönlendiriliyorsunuz...',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondary
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 800.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
