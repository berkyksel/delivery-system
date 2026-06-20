import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../data/services/tariff_service.dart';
import '../../../data/models/delivery_model.dart';

class NewDeliveryScreen extends StatefulWidget {
  const NewDeliveryScreen({super.key});

  @override
  State<NewDeliveryScreen> createState() => _NewDeliveryScreenState();
}

class _NewDeliveryScreenState extends State<NewDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _havenCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  PortSide _driverSide = PortSide.rechteroever;
  DeliveryTariff? _calculatedTariff;
  bool _isCalculating = false;
  bool _hasGenset = false;
  bool _isAdr = false;

  @override
  void dispose() {
    _companyCtrl.dispose();
    _contactCtrl.dispose();
    _havenCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _calculateTariff() {
    final havenText = _havenCtrl.text.trim();
    if (havenText.isEmpty) {
      setState(() => _calculatedTariff = null);
      return;
    }

    final havenNumber = int.tryParse(havenText);
    if (havenNumber == null || !TariffService.isValidHaven(havenNumber)) {
      setState(() => _calculatedTariff = null);
      return;
    }

    setState(() {
      _isCalculating = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _calculatedTariff = TariffService.calculate(
            havenNumber: havenNumber,
            driverCurrentSide: _driverSide,
            hasGenset: _hasGenset,
            isAdr: _isAdr,
          );
          _isCalculating = false;
        });
      }
    });
  }

  void _createDelivery() {
    if (!_formKey.currentState!.validate()) return;
    if (_calculatedTariff == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli bir haven numarası girin')),
      );
      return;
    }

    final delivery = DeliveryModel.fromTariff(
      companyName: _companyCtrl.text.trim(),
      havenNumber: int.parse(_havenCtrl.text.trim()),
      driverSide: _driverSide,
      tariff: _calculatedTariff!,
      driverId: 'current_user', // Firebase auth ile alınacak
      contactPerson: _contactCtrl.text.trim().isNotEmpty
          ? _contactCtrl.text.trim()
          : null,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );

    context.push(AppRoutes.deliverySummary, extra: delivery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Yeni Teslimat'),
        backgroundColor: AppColors.bgDark,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Firma Bilgileri
            _buildSection(
              'FİRMA BİLGİLERİ',
              Icons.business_rounded,
              [
                TextFormField(
                  controller: _companyCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Firma Adı *',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                  validator: (v) =>
                      v?.isEmpty == true ? 'Firma adı zorunludur' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contactCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'İletişim Kişisi (Opsiyonel)',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Mevcut Konumum
            _buildSection(
              'MEVCUt KONUMUM',
              Icons.my_location_rounded,
              [
                Row(
                  children: PortSide.values
                      .map((side) => Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _driverSide = side);
                                _calculateTariff();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.only(
                                    right: side == PortSide.rechteroever ? 8 : 0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: _driverSide == side
                                      ? (side == PortSide.rechteroever
                                              ? AppColors.rechteroever
                                              : AppColors.linkeroever)
                                           .withValues(alpha: 0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _driverSide == side
                                        ? (side == PortSide.rechteroever
                                            ? AppColors.rechteroever
                                            : AppColors.linkeroever)
                                        : AppColors.glassBorder,
                                    width: _driverSide == side ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      side == PortSide.rechteroever
                                          ? Icons.arrow_forward_rounded
                                          : Icons.arrow_back_rounded,
                                      size: 16,
                                      color: _driverSide == side
                                          ? (side == PortSide.rechteroever
                                              ? AppColors.rechteroever
                                              : AppColors.linkeroever)
                                          : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          side.dutchName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _driverSide == side
                                                ? AppColors.textPrimary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                        Text(
                                          side.turkishName,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: _driverSide == side
                                                ? AppColors.textSecondary
                                                : AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Haven Seçimi
            _buildSection(
              'HEDEF HAVEN',
              Icons.anchor_rounded,
              [
                TextFormField(
                  controller: _havenCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Haven Numarası (1-2000)',
                    prefixIcon: const Icon(Icons.anchor_rounded),
                    suffixText: _calculatedTariff?.destinationSide.dutchName,
                    suffixStyle: TextStyle(
                      color: _calculatedTariff?.destinationSide ==
                              PortSide.rechteroever
                          ? AppColors.rechteroever
                          : AppColors.linkeroever,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  onChanged: (_) => _calculateTariff(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Haven numarası zorunludur';
                    final num = int.tryParse(v);
                    if (num == null || !TariffService.isValidHaven(num)) {
                      return 'Geçersiz haven (1-2000 arası)';
                    }
                    return null;
                  },
                ),
                if (_isCalculating)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator(),
                  ),
                if (_calculatedTariff != null && !_isCalculating) ...[
                  const SizedBox(height: 16),
                  _TariffPreviewCard(tariff: _calculatedTariff!),
                ],
              ],
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // ─── KONTEYNER ÖZELLİKLERİ (YENİ) ─────────────────────────────
            _buildSection(
              'KONTEYNER ÖZELLİKLERİ',
              Icons.widgets_rounded,
              [
                // Genset Toggle
                _ContainerOptionTile(
                  icon: Icons.electrical_services_rounded,
                  iconColor: const Color(0xFF00BCD4),
                  title: 'Genset',
                  subtitle: 'Motorlu şase / Reefer konteyner',
                  dutchLabel: 'Genset (motor/chassis)',
                  fee: AppConstants.gensetFee,
                  isEnabled: _hasGenset,
                  onToggle: (val) {
                    setState(() => _hasGenset = val);
                    _calculateTariff();
                  },
                ),
                const SizedBox(height: 12),
                Divider(color: AppColors.glassBorder, height: 1),
                const SizedBox(height: 12),
                // ADR Toggle
                _ContainerOptionTile(
                  icon: Icons.warning_amber_rounded,
                  iconColor: const Color(0xFFFF6B35),
                  title: 'ADR',
                  subtitle: 'Tehlikeli madde / Patlayıcı',
                  dutchLabel: 'ADR (gevaarlijke stoffen)',
                  fee: AppConstants.adrFee,
                  isEnabled: _isAdr,
                  onToggle: (val) {
                    setState(() => _isAdr = val);
                    _calculateTariff();
                  },
                ),
              ],
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
            // ────────────────────────────────────────────────────────────────

            const SizedBox(height: 16),

            // Notlar
            _buildSection(
              'NOTLAR',
              Icons.notes_rounded,
              [
                TextFormField(
                  controller: _notesCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Ek notlar (Opsiyonel)',
                    prefixIcon: Icon(Icons.notes_rounded),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _createDelivery,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Teslimat Oluştur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

// ─── Konteyner Seçenek Kartı ─────────────────────────────────────────────────
class _ContainerOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String dutchLabel;
  final double fee;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const _ContainerOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.dutchLabel,
    required this.fee,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isEnabled
            ? iconColor.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled
              ? iconColor.withValues(alpha: 0.4)
              : AppColors.glassBorder,
          width: isEnabled ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // İkon
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEnabled
                  ? iconColor.withValues(alpha: 0.15)
                  : AppColors.bgCardLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isEnabled ? iconColor : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          // Metin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isEnabled
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? iconColor.withValues(alpha: 0.15)
                            : AppColors.bgCardLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fee > 0
                            ? '+${fee.toStringAsFixed(2)} €'
                            : 'Fiyat TBD',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isEnabled ? iconColor : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  dutchLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          // Toggle
          Switch(
            value: isEnabled,
            onChanged: onToggle,
            activeThumbColor: iconColor,
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return iconColor.withValues(alpha: 0.3);
              }
              return AppColors.bgCardLight;
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Tarife Önizleme Kartı ───────────────────────────────────────────────────
class _TariffPreviewCard extends StatelessWidget {
  final DeliveryTariff tariff;
  const _TariffPreviewCard({required this.tariff});

  @override
  Widget build(BuildContext context) {
    final sideColor = tariff.destinationSide == PortSide.rechteroever
        ? AppColors.rechteroever
        : AppColors.linkeroever;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
             sideColor.withValues(alpha: 0.1),
            AppColors.bgCardLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sideColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.anchor_rounded, size: 14, color: sideColor),
                  const SizedBox(width: 6),
                  Text(
                    'Haven ${tariff.havenNumber} — ${tariff.destinationSide.dutchName}',
                    style: TextStyle(
                      color: sideColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (tariff.estimatedMinutes != null)
                Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '~${tariff.estimatedMinutes} dk',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.bgCardLight),
          const SizedBox(height: 8),
          _FeeRow(
            label: 'Haven Ücreti',
            value: tariff.formattedHavenFee,
            color: AppColors.textPrimary,
          ),
          if (tariff.needsTunnel) ...[
            const SizedBox(height: 6),
            _FeeRow(
              label: 'Tünel Ücreti (Kennedy)',
              value: tariff.formattedTunnelFee,
              color: AppColors.tunnel,
              icon: Icons.alt_route,
            ),
          ],
          if (tariff.hasGenset) ...[
            const SizedBox(height: 6),
            _FeeRow(
              label: 'Genset Ücreti',
              value: tariff.gensetFee > 0
                  ? tariff.formattedGensetFee
                  : 'TBD',
              color: const Color(0xFF00BCD4),
              icon: Icons.electrical_services_rounded,
            ),
          ],
          if (tariff.isAdr) ...[
            const SizedBox(height: 6),
            _FeeRow(
              label: 'ADR Ücreti',
              value: tariff.adrFee > 0
                  ? tariff.formattedAdrFee
                  : 'TBD',
              color: const Color(0xFFFF6B35),
              icon: Icons.warning_amber_rounded,
            ),
          ],
          const Divider(color: AppColors.bgCardLight, height: 20),
          _FeeRow(
            label: 'TOPLAM',
            value: tariff.formattedTotal,
            color: AppColors.success,
            isBold: true,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;
  final IconData? icon;

  const _FeeRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: isBold ? 13 : 12,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
