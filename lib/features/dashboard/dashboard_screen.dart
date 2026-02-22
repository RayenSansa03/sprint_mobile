import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/summary_card.dart';
import '../../shared/widgets/action_tile.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildSectionTitle('DAILY SUMMARY'),
              const SizedBox(height: 16),
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
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('MONTHLY HARVEST (TONS)'),
                  const Text('Total: 142T', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              _buildHarvestChart(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=farmer'),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Marcus',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
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

  Widget _buildHarvestChart() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text('Chart Placeholder (using fl_chart)', style: TextStyle(color: AppColors.textHint)),
      ),
    );
  }
}
