import 'package:freezed_annotation/freezed_annotation.dart';

part 'learning_models.freezed.dart';
part 'learning_models.g.dart';

@freezed
class Course with _$Course {
  const factory Course({
    required String id,
    required String title,
    required String description,
    required String category,
    required String thumbnailUrl,
    required String duration,
    required String type,
    @Default(0.0) double progress,
    @Default(false) bool isCompleted,
  }) = _Course;

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
}

class LearningService {
  Future<List<Course>> getCourses() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      const Course(
        id: '1',
        title: 'Drip Irrigation Masterclass',
        description: 'Learn how to install and maintain efficient drip irrigation systems.',
        category: 'Irrigation',
        thumbnailUrl: 'https://images.unsplash.com/photo-1563514223300-89429c32e921?w=400',
        duration: '15 mins',
        type: 'Video Lesson',
        progress: 0.75,
      ),
      const Course(
        id: '2',
        title: 'Integrated Pest Management',
        description: 'Sustainable methods to protect your seasonal crops.',
        category: 'Pest Control',
        thumbnailUrl: 'https://images.unsplash.com/photo-1595180630010-09252084534a?w=400',
        duration: '24 mins',
        type: 'Video',
        progress: 0.0,
      ),
      const Course(
        id: '3',
        title: 'Agricultural Loans & Grants 2024',
        description: 'Complete guide to government funding and applications.',
        category: 'Finance',
        thumbnailUrl: 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400',
        duration: '12 pages',
        type: 'PDF Guide',
        progress: 0.0,
      ),
      const Course(
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
  }
}
