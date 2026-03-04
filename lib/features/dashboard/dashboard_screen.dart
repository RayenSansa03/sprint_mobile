import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/summary_card.dart';
import '../../shared/widgets/action_tile.dart';
import '../auth/auth_service.dart';
import '../learning/learning_models.dart';
import '../learning/widgets/blackboard_thumbnail.dart';
import 'widgets/field_map_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final coursesAsync = ref.watch(coursesProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user?.firstName ?? 'Marcus'),
              const SizedBox(height: 32),
              _buildSectionTitle('DAILY SUMMARY'),
              const SizedBox(height: 16),
              // ... summary cards unchanged
              const SummaryCard(
                icon: Icons.eco,
                iconBgColor: AppColors.primaryLight,
                title: 'My Fields',
                value: '8 Healthy',
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
              const SummaryCard(
                icon: Icons.warning_amber_rounded,
                iconBgColor: Color(0xFFFFF3E0),
                title: 'Active Alerts',
                value: '2 Urgent',
                borderColor: Colors.orange,
                trailing: Icon(Icons.error, color: Colors.orange),
              ),
              const SummaryCard(
                icon: Icons.storefront,
                iconBgColor: Color(0xFFE3F2FD),
                title: 'Current Sales',
                value: '3 Pending',
                trailing: Chip(
                  label: Text('ACTIVE', style: TextStyle(color: Colors.blue, fontSize: 10)),
                  backgroundColor: Color(0xFFE3F2FD),
                  side: BorderSide.none,
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('QUICK ACTIONS'),
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
                    icon: Icons.camera_alt_outlined,
                    title: 'Scan Plant',
                    backgroundColor: AppColors.primary,
                    contentColor: Colors.white,
                    onTap: () => context.go('/scan'),
                  ),
                  ActionTile(
                    icon: Icons.shopping_basket_outlined,
                    title: 'Marketplace',
                    onTap: () => context.go('/marketplace'),
                  ),
                  ActionTile(
                    icon: Icons.menu_book_outlined,
                    title: 'E-Learning',
                    onTap: () => context.go('/learning'),
                  ),
                  ActionTile(
                    icon: Icons.cloud_outlined,
                    title: 'Weather',
                    onTap: () => context.push('/weather'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('CONTINUE LEARNING'),
                  GestureDetector(
                    onTap: () => context.go('/learning'),
                    child: const Text('View All',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              coursesAsync.when(
                data: (courses) => courses.isNotEmpty 
                  ? _buildFeaturedCard(context, courses.first)
                  : const Center(child: Text('No courses available')),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('FARM MAP'),
              const SizedBox(height: 16),
              const FieldMapWidget(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryLight,
          child: ClipOval(
            child: Image.network(
              'https://i.pravatar.cc/150?u=farmer',
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Monday, 12 June',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
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
