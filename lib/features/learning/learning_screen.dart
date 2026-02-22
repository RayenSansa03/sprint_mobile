import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'learning_models.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  String selectedCategory = 'All Courses';
  final List<String> categories = ['All Courses', 'Irrigation', 'Pest Control', 'Fertilization'];

  final List<Course> courses = const [
    Course(
      id: '1',
      title: 'Drip Irrigation Masterclass',
      description: 'Learn how to install and maintain efficient drip irrigation systems.',
      category: 'Irrigation',
      thumbnailUrl: 'https://images.unsplash.com/photo-1563514223300-89429c32e921?w=400',
      duration: '15 mins',
      type: 'Video Lesson',
      progress: 0.75,
    ),
    Course(
      id: '2',
      title: 'Integrated Pest Management',
      description: 'Sustainable methods to protect your seasonal crops.',
      category: 'Pest Control',
      thumbnailUrl: 'https://images.unsplash.com/photo-1595180630010-09252084534a?w=400',
      duration: '24 mins',
      type: 'Video',
      progress: 0.0,
    ),
    Course(
      id: '3',
      title: 'Agricultural Loans & Grants 2024',
      description: 'Complete guide to government funding and applications.',
      category: 'Finance',
      thumbnailUrl: 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400',
      duration: '12 pages',
      type: 'PDF Guide',
      progress: 0.0,
    ),
    Course(
      id: '4',
      title: 'Soil Nutrition & Fertilization',
      description: 'Deep dive into soil health and effective fertilization.',
      category: 'Fertilization',
      thumbnailUrl: 'https://images.unsplash.com/photo-1592919016327-50503ef4ce5c?w=400',
      duration: '40 mins',
      type: 'Video',
      progress: 1.0,
      isCompleted: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final featuredCourse = courses[0];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Learn & Grow'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(backgroundColor: Colors.orange.shade100, child: const Icon(Icons.menu_book, color: Colors.orange, size: 16)),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryChips(),
            const SizedBox(height: 24),
            const Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text('Continue Learning', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            _buildFeaturedCard(featuredCourse),
            const SizedBox(height: 32),
            const Text('Recommended for You', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            ...courses.skip(1).map((course) => _buildCourseCard(course)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = selectedCategory == categories[index];
          return ChoiceChip(
            label: Text(categories[index]),
            selected: isSelected,
            onSelected: (val) => setState(() => selectedCategory = categories[index]),
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontSize: 13),
            backgroundColor: Colors.white,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCard(Course course) {
    return Container(
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
                child: Image.network(course.thumbnailUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.black.withOpacity(0.4),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                  child: Text(course.category.toUpperCase(), style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(course.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    Text('${(course.progress * 100).toInt()}%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Text('Complete', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(course.duration, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 16),
                    const Icon(Icons.videocam_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(course.type, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Resume Course →'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(course.thumbnailUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
              if (course.isCompleted)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: 4),
                        Text('COMPLETED', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(course.description, style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(course.duration, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(width: 12),
                        const Icon(Icons.videocam_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(course.type, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    Text(course.isCompleted ? 'Review' : 'Start', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
