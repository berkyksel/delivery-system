import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/locale_provider.dart';
import '../../../data/models/delivery_model.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/services/tariff_service.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Mock profile - Firebase ile değiştirilecek
  UserProfile _profile = const UserProfile(
    uid: 'user_1',
    email: 'sofor@anvers.com',
    firstName: 'Mehmet',
    lastName: 'Yılmaz',
    phone: '+32 470 123 456',
    vehiclePlate: '1-ABC-123',
    vehicleType: 'Kamyon',
    role: UserRole.driver,
    currentSide: 'rechteroever',
  );

  File? _localPhotoFile;
  bool _isUploadingPhoto = false;

  // ── Düzenleme State'i ────────────────────────────────────────────────────────
  bool _editingPersonal = false;
  bool _editingVehicle = false;

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _plateCtrl;
  late final TextEditingController _vehicleTypeCtrl;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: _profile.firstName);
    _lastNameCtrl  = TextEditingController(text: _profile.lastName);
    _phoneCtrl     = TextEditingController(text: _profile.phone ?? '');
    _plateCtrl     = TextEditingController(text: _profile.vehiclePlate ?? '');
    _vehicleTypeCtrl = TextEditingController(text: _profile.vehicleType ?? '');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _plateCtrl.dispose();
    _vehicleTypeCtrl.dispose();
    super.dispose();
  }

  // ── Fotoğraf Seç & Yükle ────────────────────────────────────────────────────
  Future<void> _pickAndUploadPhoto() async {
    // Kaynak seçtir
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 800,
    );
    if (picked == null) return;

    setState(() {
      _localPhotoFile = File(picked.path);
      _isUploadingPhoto = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? _profile.uid;
      final ref = FirebaseStorage.instance
          .ref()
          .child('users/$uid/profile.jpg');

      await ref.putFile(_localPhotoFile!);
      final downloadUrl = await ref.getDownloadURL();

      // Firestore güncelle
      await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'photoUrl': downloadUrl});

      setState(() {
        _profile = _profile.copyWith(photoUrl: downloadUrl);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil fotoğrafı güncellendi ✓'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf yüklenemedi: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1A2236) : Colors.white;
        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Fotoğraf Seç',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Kamera',
                      color: AppColors.primary,
                      onTap: () => Navigator.pop(ctx, ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SourceOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Galeri',
                      color: AppColors.accent,
                      onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'İptal',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          _buildProfileHeader(theme, isDark),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildCurrentSideCard(theme, isDark)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1),
                const SizedBox(height: 14),
                _buildPersonalInfoCard(theme, isDark)
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.1),
                const SizedBox(height: 14),
                _buildVehicleCard(theme, isDark)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.1),
                const SizedBox(height: 14),
                _buildPreferencesCard(theme, isDark)
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .slideY(begin: 0.1),
                const SizedBox(height: 14),
                _buildLogoutButton(theme, isDark)
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, bool isDark) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [Color(0xFF0D47A1), Color(0xFF0A0E1A)]
                  : const [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                // Avatar — tıklanabilir
                GestureDetector(
                  onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                  child: Stack(
                    children: [
                      // Fotoğraf veya baş harfler
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _buildAvatarContent(),
                        ),
                      ),
                      // Kamera ikonu
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: _isUploadingPhoto
                                ? Colors.grey
                                : AppColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                          child: _isUploadingPhoto
                              ? const Padding(
                                  padding: EdgeInsets.all(5),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.camera_alt_rounded,
                                  size: 13, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _profile.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _profile.role.label,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  /// Yerel dosya varsa → dosyadan, url varsa → ağdan, yoksa → baş harfler
  Widget _buildAvatarContent() {
    if (_localPhotoFile != null) {
      return Image.file(_localPhotoFile!, fit: BoxFit.cover,
          width: 80, height: 80);
    }
    if (_profile.photoUrl != null && _profile.photoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _profile.photoUrl!,
        fit: BoxFit.cover,
        width: 80,
        height: 80,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
        errorWidget: (_, __, ___) => _buildInitials(),
      );
    }
    return _buildInitials();
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        '${_profile.firstName[0]}${_profile.lastName[0]}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildCurrentSideCard(ThemeData theme, bool isDark) {
    final isRight = _profile.currentSide == 'rechteroever';
    final currentSide =
        isRight ? PortSide.rechteroever : PortSide.linkeroever;
    final sideColor =
        isRight ? AppColors.rechteroever : AppColors.linkeroever;
    final l10n = ref.watch(appL10nProvider);

    final cardBg = theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [sideColor.withValues(alpha: 0.12), cardBg],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: sideColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.my_location_rounded, size: 14, color: sideColor),
              const SizedBox(width: 8),
              Text(
                l10n.profileCurrentLocation,
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
          Row(
            children: PortSide.values.map((side) {
              final isSelected = currentSide == side;
              final color = side == PortSide.rechteroever
                  ? AppColors.rechteroever
                  : AppColors.linkeroever;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _profile = _profile.copyWith(
                        currentSide: side.name);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                        right: side == PortSide.rechteroever ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? color : borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          side == PortSide.rechteroever
                              ? Icons.chevron_right_rounded
                              : Icons.chevron_left_rounded,
                          color: isSelected
                              ? color
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        Text(
                          side.dutchName,
                          style: TextStyle(
                            color: isSelected
                                ? color
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          side.turkishName,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(ThemeData theme, bool isDark) {
    final l10n = ref.watch(appL10nProvider);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return _buildEditableSection(
      title: l10n.profilePersonalInfo,
      icon: Icons.person_rounded,
      theme: theme,
      isDark: isDark,
      isEditing: _editingPersonal,
      onEditToggle: () => setState(() {
        if (_editingPersonal) {
          // Kaydet
          _profile = _profile.copyWith(
            firstName: _firstNameCtrl.text.trim().isNotEmpty
                ? _firstNameCtrl.text.trim()
                : _profile.firstName,
            lastName: _lastNameCtrl.text.trim().isNotEmpty
                ? _lastNameCtrl.text.trim()
                : _profile.lastName,
            phone: _phoneCtrl.text.trim().isNotEmpty
                ? _phoneCtrl.text.trim()
                : null,
          );
        } else {
          // Düzenlemeye başla — mevcut değerleri yükle
          _firstNameCtrl.text = _profile.firstName;
          _lastNameCtrl.text  = _profile.lastName;
          _phoneCtrl.text     = _profile.phone ?? '';
        }
        _editingPersonal = !_editingPersonal;
      }),
      children: _editingPersonal
          ? [
              _EditField(
                controller: _firstNameCtrl,
                icon: Icons.badge_rounded,
                label: l10n.profileFullName.split(' ').first,
                hint: 'Ad',
                theme: theme,
                isDark: isDark,
                borderColor: borderColor,
              ),
              const SizedBox(height: 10),
              _EditField(
                controller: _lastNameCtrl,
                icon: Icons.badge_outlined,
                label: 'Soyad',
                hint: 'Soyad',
                theme: theme,
                isDark: isDark,
                borderColor: borderColor,
              ),
              const SizedBox(height: 10),
              _EditField(
                controller: _phoneCtrl,
                icon: Icons.phone_outlined,
                label: l10n.profilePhone,
                hint: '+32 470 000 000',
                keyboardType: TextInputType.phone,
                theme: theme,
                isDark: isDark,
                borderColor: borderColor,
              ),
              _InfoTile(
                icon: Icons.email_outlined,
                label: l10n.profileEmail,
                value: _profile.email,
                theme: theme,
              ),
            ]
          : [
              _InfoTile(
                icon: Icons.badge_rounded,
                label: l10n.profileFullName,
                value: _profile.fullName,
                theme: theme,
              ),
              _InfoTile(
                icon: Icons.email_outlined,
                label: l10n.profileEmail,
                value: _profile.email,
                theme: theme,
              ),
              if (_profile.phone != null)
                _InfoTile(
                  icon: Icons.phone_outlined,
                  label: l10n.profilePhone,
                  value: _profile.phone!,
                  theme: theme,
                ),
            ],
    );
  }

  Widget _buildVehicleCard(ThemeData theme, bool isDark) {
    final l10n = ref.watch(appL10nProvider);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return _buildEditableSection(
      title: l10n.profileVehicleInfo,
      icon: Icons.directions_car_rounded,
      theme: theme,
      isDark: isDark,
      isEditing: _editingVehicle,
      onEditToggle: () => setState(() {
        if (_editingVehicle) {
          // Kaydet
          _profile = _profile.copyWith(
            vehiclePlate: _plateCtrl.text.trim().isNotEmpty
                ? _plateCtrl.text.trim()
                : _profile.vehiclePlate,
            vehicleType: _vehicleTypeCtrl.text.trim().isNotEmpty
                ? _vehicleTypeCtrl.text.trim()
                : _profile.vehicleType,
          );
        } else {
          _plateCtrl.text = _profile.vehiclePlate ?? '';
          _vehicleTypeCtrl.text = _profile.vehicleType ?? '';
        }
        _editingVehicle = !_editingVehicle;
      }),
      children: _editingVehicle
          ? [
              _EditField(
                controller: _plateCtrl,
                icon: Icons.confirmation_number_outlined,
                label: l10n.profilePlate,
                hint: '1-ABC-123',
                theme: theme,
                isDark: isDark,
                borderColor: borderColor,
              ),
              const SizedBox(height: 10),
              _EditField(
                controller: _vehicleTypeCtrl,
                icon: Icons.local_shipping_rounded,
                label: l10n.profileVehicleType,
                hint: 'Kamyon / Tır / Van',
                theme: theme,
                isDark: isDark,
                borderColor: borderColor,
              ),
            ]
          : [
              if (_profile.vehiclePlate != null)
                _InfoTile(
                  icon: Icons.confirmation_number_outlined,
                  label: l10n.profilePlate,
                  value: _profile.vehiclePlate!,
                  theme: theme,
                ),
              if (_profile.vehicleType != null)
                _InfoTile(
                  icon: Icons.local_shipping_rounded,
                  label: l10n.profileVehicleType,
                  value: _profile.vehicleType!,
                  theme: theme,
                ),
            ],
    );
  }

  Widget _buildPreferencesCard(ThemeData theme, bool isDark) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    final selectedLang = ref.watch(quoteLanguageProvider);
    final l10n = ref.watch(appL10nProvider);

    return _buildSection(
      title: l10n.profilePreferences,
      icon: Icons.settings_rounded,
      theme: theme,
      isDark: isDark,
      children: [
        // ── Bildirimler ───────────────────────────────────────────────────
        Material(
          color: Colors.transparent,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              l10n.profileNotifications,
              style: TextStyle(
                  color: theme.colorScheme.onSurface, fontSize: 14),
            ),
            subtitle: Text(
              l10n.profileNotificationsSubtitle,
              style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
            ),
            value: _profile.notificationsEnabled,
            activeThumbColor: AppColors.accent,
            onChanged: (v) => setState(
                () => _profile = _profile.copyWith(notificationsEnabled: v)),
          ),
        ),
        const SizedBox(height: 8),
        // ── Tema Seçici ───────────────────────────────────────────────────
        _buildThemeSelector(isDarkMode, theme, l10n),
        const SizedBox(height: 16),
        // ── Uygulama Dili Seçici ─────────────────────────────────────────
        _buildAppLanguageSelector(selectedLang, theme, isDark, l10n),
      ],
    );
  }

  Widget _buildThemeSelector(bool isDarkMode, ThemeData theme, dynamic l10n) {
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            l10n.profileAppTheme,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            // Koyu Tema butonu
            Expanded(
              child: GestureDetector(
                onTap: () => ref.read(themeProvider.notifier).setDark(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode
                          ? AppColors.primary
                          : borderColor,
                      width: isDarkMode ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.dark_mode_rounded,
                        size: 22,
                        color: isDarkMode
                            ? AppColors.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.profileDark,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isDarkMode
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isDarkMode
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Açık Tema butonu
            Expanded(
              child: GestureDetector(
                onTap: () => ref.read(themeProvider.notifier).setLight(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: !isDarkMode
                        ? AppColors.accent.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: !isDarkMode
                          ? AppColors.accent
                          : borderColor,
                      width: !isDarkMode ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.light_mode_rounded,
                        size: 22,
                        color: !isDarkMode
                            ? AppColors.accent
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.profileLight,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: !isDarkMode
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: !isDarkMode
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppLanguageSelector(
    QuoteLanguage selected,
    ThemeData theme,
    bool isDark,
    dynamic l10n,
  ) {
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            l10n.profileAppLanguage,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            l10n.profileAppLanguageSubtitle,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: QuoteLanguage.values.map((lang) {
            final isSelected = selected == lang;
            return GestureDetector(
              onTap: () =>
                  ref.read(quoteLanguageProvider.notifier).setLanguage(lang),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : borderColor,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lang.flag,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      lang.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 13,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required ThemeData theme,
    required bool isDark,
  }) {
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
              Icon(icon, size: 14, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                title,
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
          ...children,
        ],
      ),
    );
  }

  // ── Düzenlenebilir Bölüm (Kalem / Kaydet butonu başlıkta) ──────────────────
  Widget _buildEditableSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required ThemeData theme,
    required bool isDark,
    required bool isEditing,
    required VoidCallback onEditToggle,
  }) {
    final cardBg = theme.colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEditing
              ? AppColors.accent.withValues(alpha: 0.5)
              : borderColor,
          width: isEditing ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              // Düzenle / Kaydet butonu
              GestureDetector(
                onTap: onEditToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEditing
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isEditing
                          ? AppColors.success.withValues(alpha: 0.4)
                          : AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isEditing ? Icons.check_rounded : Icons.edit_rounded,
                        size: 12,
                        color: isEditing ? AppColors.success : AppColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isEditing ? 'Kaydet' : 'Düzenle',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isEditing ? AppColors.success : AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme, bool isDark) {
    final l10n = ref.watch(appL10nProvider);
    return OutlinedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text(l10n.profileLogout,
                style: TextStyle(color: theme.colorScheme.onSurface)),
            content: Text(
                l10n.profileLogoutConfirm,
                style:
                    TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.profileLogoutCancel,
                    style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant)),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  // Gerçek çıkış — GoRouter redirect otomatik /login'e yönlendirir
                  await ref
                      .read(authNotifierProvider.notifier)
                      .signOut();
                },
                child: Text(l10n.profileLogout,
                    style: const TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.logout_rounded, color: AppColors.error),
      label: Text(l10n.profileLogout,
          style: const TextStyle(color: AppColors.error)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ── Yardımcı Widget: Kaynak Seçenek Butonu ────────────────────────────────────
class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bilgi Satırı ─────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Düzenleme Alanı Widget'ı ──────────────────────────────────────────────────
class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final ThemeData theme;
  final bool isDark;
  final Color borderColor;

  const _EditField({
    required this.controller,
    required this.icon,
    required this.label,
    required this.hint,
    required this.theme,
    required this.isDark,
    required this.borderColor,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: theme.colorScheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          fontSize: 13,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
    );
  }
}
