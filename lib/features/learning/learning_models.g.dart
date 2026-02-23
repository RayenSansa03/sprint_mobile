// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CoursePartImpl _$$CoursePartImplFromJson(Map<String, dynamic> json) =>
    _$CoursePartImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      type: json['type'] as String? ?? 'video',
    );

Map<String, dynamic> _$$CoursePartImplToJson(_$CoursePartImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'isCompleted': instance.isCompleted,
      'type': instance.type,
    };

_$CourseImpl _$$CourseImplFromJson(Map<String, dynamic> json) => _$CourseImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      duration: json['duration'] as String,
      type: json['type'] as String,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      parts: (json['parts'] as List<dynamic>?)
              ?.map((e) => CoursePart.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CourseImplToJson(_$CourseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'thumbnailUrl': instance.thumbnailUrl,
      'duration': instance.duration,
      'type': instance.type,
      'progress': instance.progress,
      'isCompleted': instance.isCompleted,
      'parts': instance.parts,
    };
