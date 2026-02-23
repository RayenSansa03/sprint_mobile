import 'package:freezed_annotation/freezed_annotation.dart';

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
  Future<List<Course>> getCourses() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      const Course(
        id: '1',
        title: 'Masterclass Irrigation',
        description: 'Apprenez à installer et entretenir des systèmes d\'irrigation goutte-à-goutte efficaces.',
        category: 'Irrigation',
        thumbnailUrl: 'blackboard_1',
        duration: '15 mins',
        type: 'Vidéo',
        progress: 0.75,
        parts: [
          CoursePart(id: '1a', title: 'Introduction à l\'irrigation', content: 'Base de l\'irrigation moderne', isCompleted: true),
          CoursePart(id: '1b', title: 'Matériel nécessaire', content: 'Tuyaux, raccords et pompes', isCompleted: true),
          CoursePart(id: '1c', title: 'Installation étape par étape', content: 'Mise en place sur le terrain', isCompleted: true),
          CoursePart(id: '1d', title: 'Maintenance', content: 'Nettoyage des filtres', isCompleted: false),
        ],
      ),
      const Course(
        id: '2',
        title: 'Lutte Antiparasitaire',
        description: 'Méthodes durables pour protéger vos cultures saisonnières.',
        category: 'Pest Control',
        thumbnailUrl: 'blackboard_2',
        duration: '24 mins',
        type: 'Vidéo',
        progress: 0.0,
        parts: [
          CoursePart(id: '2a', title: 'Identifier les nuisibles', content: 'Insectes et maladies communes', isCompleted: false),
          CoursePart(id: '2b', title: 'Solutions naturelles', content: 'Pesticides bio', isCompleted: false),
        ],
      ),
      const Course(
        id: '3',
        title: 'Prêts Agricoles 2024',
        description: 'Guide complet sur les financements gouvernementaux.',
        category: 'Finance',
        thumbnailUrl: 'blackboard_3',
        duration: '12 pages',
        type: 'PDF',
        progress: 0.0,
        parts: [
          CoursePart(id: '3a', title: 'Critères d\'éligibilité', content: 'Qui peut postuler ?', isCompleted: false),
          CoursePart(id: '3b', title: 'Documents requis', content: 'Liste des pièces à fournir', isCompleted: false),
        ],
      ),
      const Course(
        id: '4',
        title: 'Nutrition du Sol',
        description: 'Plongée profonde dans la santé des sols et la fertilisation.',
        category: 'Fertilization',
        thumbnailUrl: 'blackboard_4',
        duration: '40 mins',
        type: 'Vidéo',
        progress: 1.0,
        isCompleted: true,
        parts: [
          CoursePart(id: '4a', title: 'Analyse de terre', content: 'Comment tester son sol', isCompleted: true),
          CoursePart(id: '4b', title: 'Engrais NPK', content: 'Comprendre les ratios', isCompleted: true),
        ],
      ),
    ];
  }
}
