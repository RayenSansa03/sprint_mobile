import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

class CoursePart {
  final String id;
  final String title;
  final String content;
  final bool isCompleted;
  final String type;
  final String? youtubeUrl;
  final String? fileUrl;

  CoursePart({
    required this.id,
    required this.title,
    required this.content,
    this.isCompleted = false,
    this.type = 'video',
    this.youtubeUrl,
    this.fileUrl,
  });

  factory CoursePart.fromJson(Map<String, dynamic> json) {
    return CoursePart(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      isCompleted: json['completed'] ?? false,
      type: json['type'] ?? 'video',
      youtubeUrl: json['youtubeUrl'],
      fileUrl: json['fileUrl'],
    );
  }
}

class Course {
  final String id;
  final String title;
  final String description;
  final String category;
  final String thumbnailUrl;
  final String duration;
  final String type;
  final double progress;
  final bool isCompleted;
  final List<CoursePart> parts;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.thumbnailUrl,
    required this.duration,
    required this.type,
    this.progress = 0.0,
    this.isCompleted = false,
    this.parts = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    // Flatten chapters into parts
    final List<CoursePart> allParts = [];
    if (json['chapters'] != null) {
      for (var chapter in json['chapters']) {
        if (chapter['lessons'] != null) {
          for (var lesson in chapter['lessons']) {
            allParts.add(CoursePart.fromJson(lesson));
          }
        }
      }
    }

    final progressVal = (json['progress'] as num?)?.toDouble() ?? 0.0;

    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['tag'] ?? 'General',
      thumbnailUrl: json['image'] ?? '',
      duration: 'Course', 
      type: 'Module',
      progress: progressVal,
      isCompleted: progressVal >= 100.0,
      parts: allParts,
    );
  }
}

class LearningService {
  final ApiClient _api;

  LearningService(this._api);

  Future<List<Course>> getCourses() async {
    try {
      final response = await _api.get('courses');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Course.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching courses: $e');
    }
    return [];
  }

  Future<Course?> getCourseById(String id) async {
    try {
      final response = await _api.get('courses/$id');
      if (response.statusCode == 200) {
        return Course.fromJson(response.data);
      }
    } catch (e) {
      print('Error fetching course by id: $e');
    }
    return null;
  }
}

final learningServiceProvider = Provider<LearningService>((ref) {
  final api = ref.watch(apiClientProvider);
  return LearningService(api);
});
