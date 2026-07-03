import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

// ─── Admin Ayarlar State ──────────────────────────────────────────────────────
class _AdminSettingsState {
  final double tunnelFee;
  final double gensetFee;
  final double adrFee;
  final double defaultDiesel;

  const _AdminSettingsState({
    required this.tunnelFee,
    required this.gensetFee,
    required this.adrFee,
    required this.defaultDiesel,
  });

  _AdminSettingsState copyWith({
    double? tunnelFee,
    double? gensetFee,
    double? adrFee,
    double? defaultDiesel,
  }) {
    return _AdminSettingsState(
      tunnelFee: tunnelFee ?? this.tunnelFee,
      gensetFee: gensetFee ?? this.gensetFee,
      adrFee: adrFee ?? this.adrFee,
      defaultDiesel: defaultDiesel ?? this.defaultDiesel,
    );
  }
}

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  late _AdminSettingsState _settings;
  bool _saved = false;

  late TextEditingController _tunnelCtrl;
  late TextEditingController _gensetCtrl;
  late TextEditingController _adrCtrl;
  late TextEditingController _dieselCtrl;

  @override
  void initState() {
    super.initState();
    _settings = const _AdminSettingsState(
      tunnelFee: AppConstants.tunnelFee,
      gensetFee: AppConstants.gensetFee,
      adrFee: AppConstants.adrFee,
      defaultDiesel: AppConstants.defaultDieselSurchargePercent,
    );
    _tunnelCtrl =
        TextEditingController(text: _settings.tunnelFee.toStringAsFixed(2));
    _gensetCtrl =
        TextEditingController(text: _settings.gensetFee.toStringAsFixed(2));
    _adrCtrl =
        TextEditingController(text: _settings.adrFee.toStringAsFixed(2));
    _dieselCtrl =
        TextEditingController(text: _settings.defaultDiesel.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _tunnelCtrl.dispose();
    _gensetCtrl.dispose();
    _adrCtrl.dispose();
    _dieselCtrl.dispose();
    super.dispose();
  }

  void _save() {
    setState(() {
      _settings = _settings.copyWith(
        tunnelFee: double.tryParse(_tunnelCtrl.text) ?? _settings.tunnelFee,
        gensetFee: double.tryParse(_gensetCtrl.text) ?? _settings.gensetFee,
        adrFee: double.tryParse(_adrCtrl.text) ?? _settings.adrFee,
        defaultDiesel:
            double.tryParse(_dieselCtrl.text) ?? _settings.defaultDiesel,
      );
      _saved = true;
    });
    Future.delayed(const Duration(seconds: 2),
        () => mounted ? setState(() => _saved = false) : null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme, isDark),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Ücret Ayarları ────────────────────────────────────────
                _buildFeeSection(theme, isDark)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1),
                const SizedBox(height: 16),
                // ── Haven Bölge Bilgisi ───────────────────────────────────
                _buildZoneInfoCard(theme, isDark)
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.1),
                const SizedBox(height: 16),
                // ── Uygulama Bilgileri ────────────────────────────────────
                _buildAppInfoCard(theme, isDark)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.1),
                const SizedBox(height: 24),
                // ── Kaydet Butonu ─────────────────────────────────────────
                _buildSaveButton(theme)
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [Color(0xFF2D1B4E), Color(0xFF0A0E1A)]
                  : const [Color(0xFF6B21A8), Color(0xFF9333EA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sistem Ayarları',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Ücret ve tarife yapılandırması',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeeSection(ThemeData theme, bool isDark) {
    final cardBg = theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.euro_rounded, size: 14, color: Color(0xFF8B5CF6)),
              const SizedBox(width: 8),
              Text(
                'ÜCRET YÖNETİMİ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FeeField(
            label: 'Tünel Geçiş Ücreti (€)',
            controller: _tunnelCtrl,
            icon: Icons.subway_rounded,
            color: const Color(0xFFEF4444),
            hint: '17.60',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _FeeField(
            label: 'Genset Ücreti (€)',
            controller: _gensetCtrl,
            icon: Icons.electrical_services_rounded,
            color: const Color(0xFFF59E0B),
            hint: '0.00',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _FeeField(
            label: 'ADR Ücreti (€)',
            controller: _adrCtrl,
            icon: Icons.warning_rounded,
            color: const Color(0xFFEF4444),
            hint: '0.00',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _FeeField(
            label: 'Varsayılan Dizel Toeslag (%)',
            controller: _dieselCtrl,
            icon: Icons.local_gas_station_rounded,
            color: const Color(0xFF3B82F6),
            hint: '0.0',
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildZoneInfoCard(ThemeData theme, bool isDark) {
    final cardBg = theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_rounded, size: 14, color: Color(0xFF3B82F6)),
              const SizedBox(width: 8),
              Text(
                'HAVEN BÖLGELERİ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ZoneRow(
            label: 'Rechteroever (Sağ Kıyı)',
            range:
                '${AppConstants.rechteroeverMin} – ${AppConstants.rechteroeverMax}',
            color: AppColors.rechteroever,
            theme: theme,
          ),
          const SizedBox(height: 8),
          _ZoneRow(
            label: 'Linkeroever (Sol Kıyı)',
            range:
                '${AppConstants.linkeroeverMin} – ${AppConstants.linkeroeverMax}',
            color: AppColors.linkeroever,
            theme: theme,
          ),
          const SizedBox(height: 8),
          _ZoneRow(
            label: 'Haven 1700 (Speciaal)',
            range: '14,00 €',
            color: AppColors.accent,
            theme: theme,
          ),
          _ZoneRow(
            label: 'Haven 869-913 (Speciaal)',
            range: '20,00 €',
            color: AppColors.accent,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard(ThemeData theme, bool isDark) {
    final cardBg = theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_rounded, size: 14, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text(
                'UYGULAMA BİLGİLERİ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Uygulama', value: 'Anvers Liman', theme: theme),
          _InfoRow(
              label: 'Versiyon', value: '1.0.0 (mock)', theme: theme),
          _InfoRow(
              label: 'Vade Süresi',
              value: '${AppConstants.invoiceDueDays} gün',
              theme: theme),
          _InfoRow(
              label: 'Para Birimi',
              value: AppConstants.currencyCode,
              theme: theme),
          _InfoRow(
              label: 'Dizel Fiyatı',
              value:
                  '${AppConstants.dieselPricePerLiter} €/L',
              theme: theme),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _saved ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: _saved
                ? const Color(0xFF10B981)
                : const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: Icon(
            _saved ? Icons.check_rounded : Icons.save_rounded,
            size: 20,
          ),
          label: Text(
            _saved ? '✓ Ayarlar Kaydedildi' : 'Ayarları Kaydet',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
    );
  }
}

// ─── Field Widget ─────────────────────────────────────────────────────────────
class _FeeField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final Color color;
  final String hint;
  final ThemeData theme;

  const _FeeField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.color,
    required this.hint,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}')),
                ],
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ZoneRow extends StatelessWidget {
  final String label;
  final String range;
  final Color color;
  final ThemeData theme;

  const _ZoneRow({
    required this.label,
    required this.range,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                  color: theme.colorScheme.onSurface, fontSize: 13),
            ),
          ),
          Text(
            range,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _InfoRow(
      {required this.label, required this.value, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
