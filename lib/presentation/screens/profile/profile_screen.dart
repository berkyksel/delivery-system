import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/services/tariff_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          _buildProfileHeader(),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildCurrentSideCard()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1),
                const SizedBox(height: 14),
                _buildPersonalInfoCard()
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.1),
                const SizedBox(height: 14),
                _buildVehicleCard()
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.1),
                const SizedBox(height: 14),
                _buildPreferencesCard()
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .slideY(begin: 0.1),
                const SizedBox(height: 14),
                _buildLogoutButton()
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

  Widget _buildProfileHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.bgDark,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF0A0E1A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                // Avatar
                Stack(
                  children: [
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
                      child: Center(
                        child: Text(
                          '${_profile.firstName[0]}${_profile.lastName[0]}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.bgDark, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 13, color: Colors.white),
                      ),
                    ),
                  ],
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

  Widget _buildCurrentSideCard() {
    final isRight = _profile.currentSide == 'rechteroever';
    final currentSide =
        isRight ? PortSide.rechteroever : PortSide.linkeroever;
    final sideColor =
        isRight ? AppColors.rechteroever : AppColors.linkeroever;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [sideColor.withValues(alpha: 0.12), AppColors.bgCard],
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
              const Text(
                'MEVCUt KONUMUM',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
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
                      color:
                          isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? color : AppColors.glassBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          side == PortSide.rechteroever
                              ? Icons.chevron_right_rounded
                              : Icons.chevron_left_rounded,
                          color: isSelected ? color : AppColors.textMuted,
                        ),
                        Text(
                          side.dutchName,
                          style: TextStyle(
                            color: isSelected ? color : AppColors.textMuted,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          side.turkishName,
                          style: const TextStyle(
                            color: AppColors.textMuted,
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

  Widget _buildPersonalInfoCard() {
    return _buildSection(
      title: 'KİŞİSEL BİLGİLER',
      icon: Icons.person_rounded,
      children: [
        _InfoTile(
          icon: Icons.badge_rounded,
          label: 'Ad Soyad',
          value: _profile.fullName,
        ),
        _InfoTile(
          icon: Icons.email_outlined,
          label: 'E-posta',
          value: _profile.email,
        ),
        if (_profile.phone != null)
          _InfoTile(
            icon: Icons.phone_outlined,
            label: 'Telefon',
            value: _profile.phone!,
          ),
      ],
    );
  }

  Widget _buildVehicleCard() {
    return _buildSection(
      title: 'ARAÇ BİLGİLERİ',
      icon: Icons.directions_car_rounded,
      children: [
        if (_profile.vehiclePlate != null)
          _InfoTile(
            icon: Icons.confirmation_number_outlined,
            label: 'Plaka',
            value: _profile.vehiclePlate!,
          ),
        if (_profile.vehicleType != null)
          _InfoTile(
            icon: Icons.local_shipping_rounded,
            label: 'Araç Tipi',
            value: _profile.vehicleType!,
          ),
      ],
    );
  }

  Widget _buildPreferencesCard() {
    return _buildSection(
      title: 'TERCİHLER',
      icon: Icons.settings_rounded,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Bildirimler',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
          subtitle: const Text(
            'Teslimat hatırlatmaları',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          value: _profile.notificationsEnabled,
          activeThumbColor: AppColors.accent,
          onChanged: (v) => setState(
              () => _profile = _profile.copyWith(notificationsEnabled: v)),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
              Icon(icon, size: 14, color: AppColors.accent),
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
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.bgCard,
            title: const Text('Çıkış Yap',
                style: TextStyle(color: AppColors.textPrimary)),
            content: const Text('Hesabınızdan çıkmak istediğinizden emin misiniz?',
                style: TextStyle(color: AppColors.textSecondary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('İptal',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Firebase signOut()
                },
                child: const Text('Çıkış Yap',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.logout_rounded, color: AppColors.error),
      label: const Text('Çıkış Yap',
          style: TextStyle(color: AppColors.error)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
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
