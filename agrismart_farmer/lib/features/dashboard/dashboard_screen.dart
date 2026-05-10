import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/summary_card.dart';
import '../../shared/widgets/action_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_service.dart';
import '../../shared/widgets/glass_card.dart';
import 'dashboard_provider.dart';
import 'dashboard_models.dart';
import '../learning/learning_models.dart';
import '../learning/widgets/blackboard_thumbnail.dart';
import 'widgets/field_map_widget.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final dashboardState = ref.watch(dashboardProvider);
    final firstName = user?.firstName ?? user?.name?.split(' ').first ?? 'Agriculteur';
    final today = DateFormat('EEEE, d MMMM', 'fr_FR').format(DateTime.now());

    final featuredCourse = Course(
      id: '1',
      title: 'Masterclass Irrigation',
      description: 'Apprenez à installer et entretenir des systèmes d\'irrigation goutte-à-goutte efficaces.',
      category: 'Irrigation',
      thumbnailUrl: 'blackboard_1',
      duration: '15 mins',
      type: 'Vidéo',
      progress: 0.75,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Aesthetic Decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, ref, firstName, today, user?.profilePictureUrl),
                    const SizedBox(height: 32),
                    _buildPremiumStats(dashboardState.stats, dashboardState.isLoading),
                    const SizedBox(height: 32),
                    _buildSectionTitle('ACTIONS RAPIDES'),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        ActionTile(
                          icon: Icons.camera_alt_rounded,
                          title: 'Scanner Plante',
                          backgroundColor: AppColors.primary,
                          contentColor: Colors.white,
                          onTap: () => context.go('/scan'),
                        ),
                        ActionTile(
                          icon: Icons.shopping_bag_rounded,
                          title: 'Marché',
                          onTap: () => context.go('/marketplace'),
                        ),
                        ActionTile(
                          icon: Icons.menu_book_rounded,
                          title: 'Formation',
                          onTap: () => context.go('/learning'),
                        ),
                        ActionTile(
                          icon: Icons.wb_sunny_rounded,
                          title: 'Météo',
                          onTap: () => context.push('/weather'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildAIAskCard(context),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('CONTINUER LA FORMATION'),
                        GestureDetector(
                          onTap: () => context.go('/learning'),
                          child: const Text('Voir tout',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFeaturedCard(context, featuredCourse),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('CARTE DE L\'EXPLOITATION'),
                        TextButton.icon(
                          onPressed: () {
                            ref.invalidate(dashboardProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Actualisation de la carte...'),
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Actualiser', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const FieldMapWidget(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStats(DashboardStats stats, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('ÉTAT DES CHAMPS EN TEMPS RÉEL'),
        const SizedBox(height: 16),
        SizedBox(
          height: 130, // Increased height
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _buildStatCard(
                'Parcelles',
                '${stats.healthyPlots}/${stats.totalPlots}',
                'Opérationnel',
                Icons.eco_rounded,
                AppColors.gradientPrimary,
                isLoading,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Alertes',
                stats.activeAlerts.toString(),
                stats.activeAlerts > 0 ? 'Action requise' : 'Aucune',
                Icons.warning_amber_rounded,
                stats.activeAlerts > 0 ? [const Color(0xFFD32F2F), const Color(0xFFEF5350)] : AppColors.gradientGold,
                isLoading,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Ventes',
                stats.pendingOrders.toString(),
                'À expédier',
                Icons.shopping_cart_checkout_rounded,
                AppColors.gradientBlue,
                isLoading,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String subLabel, IconData icon, List<Color> gradient, bool isLoading) {
    return Container(
      width: 145, // Slightly narrower to prevent horizontal crowding
      margin: const EdgeInsets.only(bottom: 4), // Add tiny margin for shadows
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Fit content
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                  ),
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28, // Slightly smaller to fit
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              subLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAskCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(2),
      borderRadius: 24,
      borderColor: AppColors.primary.withOpacity(0.3),
      child: GestureDetector(
        onTap: () => context.push('/chatbot'),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.8),
                AppColors.primaryDark.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expert IA AgriSmart',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Une question sur vos cultures ? Posez-la ici.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, String firstName, String today, String? avatarUrl) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryLight,
          child: ClipOval(
            child: avatarUrl != null && avatarUrl.isNotEmpty
                ? Image.network(
                    avatarUrl,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, color: AppColors.primary),
                  )
                : const Icon(Icons.person, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour, $firstName 👋',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                today,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.push('/chatbot'),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, Course course) {
    return GestureDetector(
      onTap: () => context.push('/learning/detail', extra: course),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: BlackboardThumbnail(title: course.title, category: course.category),
                  ),
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: course.progress,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    color: AppColors.primary,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          course.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${(course.progress * 100).toInt()}%',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
