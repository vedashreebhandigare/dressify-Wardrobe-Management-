import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/wardrobe_providers.dart';
import '../../../../shared/providers/outfit_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(wardrobeStatsProvider);
    final outfits = ref.watch(outfitListProvider);
    final savedOutfits = ref.watch(savedOutfitsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileHeader().animate().fadeIn(duration: 500.ms),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Stats Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _ProfileStatCard(
                        icon: Icons.checkroom_rounded,
                        label: 'Wardrobe Items',
                        value: '${stats.total}',
                        gradient: const [AppTheme.primary, AppTheme.primaryLight],
                      ),
                      _ProfileStatCard(
                        icon: Icons.auto_awesome_rounded,
                        label: 'Outfits Created',
                        value: '${outfits.length}',
                        gradient: [AppTheme.secondary, const Color(0xFFCE93D8)],
                      ),
                      _ProfileStatCard(
                        icon: Icons.bookmark_rounded,
                        label: 'Saved Outfits',
                        value: '${savedOutfits.length}',
                        gradient: [AppTheme.accent, const Color(0xFF26C6DA)],
                      ),
                      _ProfileStatCard(
                        icon: Icons.favorite_rounded,
                        label: 'Favorites',
                        value: '${stats.favorites}',
                        gradient: [AppTheme.secondary, const Color(0xFFF48FB1)],
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 24),

                  // Settings Cards
                  const _SectionTitle('Preferences'),
                  const SizedBox(height: 12),
                  _SettingTile(
                    icon: Icons.notifications_outlined,
                    label: 'Daily Outfit Reminders',
                    subtitle: 'Get your daily outfit suggestion',
                    trailing: Switch(value: true, onChanged: (_) {}),
                  ).animate().fadeIn(delay: 300.ms),
                  _SettingTile(
                    icon: Icons.cloud_sync_outlined,
                    label: 'Cloud Sync',
                    subtitle: 'Backup wardrobe to cloud',
                    trailing: Switch(value: false, onChanged: (_) {}),
                  ).animate().fadeIn(delay: 350.ms),
                  _SettingTile(
                    icon: Icons.palette_outlined,
                    label: 'Theme',
                    subtitle: 'Light mode',
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textHint),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 20),
                  const _SectionTitle('About'),
                  const SizedBox(height: 12),
                  _SettingTile(
                    icon: Icons.info_outline_rounded,
                    label: 'App Version',
                    subtitle: '1.0.0',
                    trailing: const SizedBox(),
                  ).animate().fadeIn(delay: 450.ms),
                  _SettingTile(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    subtitle: 'How we use your data',
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textHint),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        context.go('/onboarding');
                      },
                      icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                      label: const Text('Sign Out', style: TextStyle(color: AppTheme.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.heroGradient,
      ),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(Icons.person_rounded, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 14),
            const Text('Style Enthusiast', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            const Text('Building a sustainable wardrobe 🌿', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;

  const _ProfileStatCard({
    required this.icon, required this.label, required this.value, required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: gradient[0].withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Widget trailing;

  const _SettingTile({
    required this.icon, required this.label, required this.subtitle, required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
