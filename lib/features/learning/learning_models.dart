import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

part 'learning_models.freezed.dart';
part 'learning_models.g.dart';

@freezed
class CoursePart with _$CoursePart {
  const factory CoursePart({
    required String id,
    required String title,
    required String content,
    @Default(false) bool isCompleted,
    @Default('video') String type,
  }) = _CoursePart;

  factory CoursePart.fromJson(Map<String, dynamic> json) => _$CoursePartFromJson(json);
}

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
    @Default([]) List<CoursePart> parts,
  }) = _Course;

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
}



class LearningService {
  final ApiClient _api;

  LearningService(this._api);

  Future<List<Course>> getCourses() async {
    try {
      final response = await _api.get('/courses');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Course(
          id: json['id'] ?? '',
          title: json['title'] ?? '',
          description: json['description'] ?? '',
          category: json['tag'] ?? 'Général',
          thumbnailUrl: (json['image'] as String?)?.isNotEmpty == true ? json['image'] : 'blackboard_1',
          duration: '20 mins',
          type: 'Vidéo',
          progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
          isCompleted: (json['progress'] ?? 0) >= 100,
          parts: (json['chapters'] as List<dynamic>?)?.map((c) => CoursePart(
            id: c['id'] ?? '',
            title: c['title'] ?? '',
            content: c['content'] ?? '',
            isCompleted: false,
          )).toList() ?? [],
        )).toList();
      }
    } catch (e) {
      print('Learning fetch error: $e');
    }
    return [];
  }
}

final learningServiceProvider = Provider<LearningService>((ref) {
  final api = ref.watch(apiClientProvider);
  return LearningService(api);
});

final coursesProvider = FutureProvider<List<Course>>((ref) async {
  final service = ref.watch(learningServiceProvider);
  return service.getCourses();
});
