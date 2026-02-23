// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'learning_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CoursePart _$CoursePartFromJson(Map<String, dynamic> json) {
  return _CoursePart.fromJson(json);
}

/// @nodoc
mixin _$CoursePart {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CoursePartCopyWith<CoursePart> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoursePartCopyWith<$Res> {
  factory $CoursePartCopyWith(
          CoursePart value, $Res Function(CoursePart) then) =
      _$CoursePartCopyWithImpl<$Res, CoursePart>;
  @useResult
  $Res call(
      {String id, String title, String content, bool isCompleted, String type});
}

/// @nodoc
class _$CoursePartCopyWithImpl<$Res, $Val extends CoursePart>
    implements $CoursePartCopyWith<$Res> {
  _$CoursePartCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? isCompleted = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CoursePartImplCopyWith<$Res>
    implements $CoursePartCopyWith<$Res> {
  factory _$$CoursePartImplCopyWith(
          _$CoursePartImpl value, $Res Function(_$CoursePartImpl) then) =
      __$$CoursePartImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, String title, String content, bool isCompleted, String type});
}

/// @nodoc
class __$$CoursePartImplCopyWithImpl<$Res>
    extends _$CoursePartCopyWithImpl<$Res, _$CoursePartImpl>
    implements _$$CoursePartImplCopyWith<$Res> {
  __$$CoursePartImplCopyWithImpl(
      _$CoursePartImpl _value, $Res Function(_$CoursePartImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? isCompleted = null,
    Object? type = null,
  }) {
    return _then(_$CoursePartImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoursePartImpl implements _CoursePart {
  const _$CoursePartImpl(
      {required this.id,
      required this.title,
      required this.content,
      this.isCompleted = false,
      this.type = 'video'});

  factory _$CoursePartImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoursePartImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String content;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  @JsonKey()
  final String type;

  @override
  String toString() {
    return 'CoursePart(id: $id, title: $title, content: $content, isCompleted: $isCompleted, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoursePartImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, content, isCompleted, type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CoursePartImplCopyWith<_$CoursePartImpl> get copyWith =>
      __$$CoursePartImplCopyWithImpl<_$CoursePartImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoursePartImplToJson(
      this,
    );
  }
}

abstract class _CoursePart implements CoursePart {
  const factory _CoursePart(
      {required final String id,
      required final String title,
      required final String content,
      final bool isCompleted,
      final String type}) = _$CoursePartImpl;

  factory _CoursePart.fromJson(Map<String, dynamic> json) =
      _$CoursePartImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get content;
  @override
  bool get isCompleted;
  @override
  String get type;
  @override
  @JsonKey(ignore: true)
  _$$CoursePartImplCopyWith<_$CoursePartImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Course _$CourseFromJson(Map<String, dynamic> json) {
  return _Course.fromJson(json);
}

/// @nodoc
mixin _$Course {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get thumbnailUrl => throw _privateConstructorUsedError;
  String get duration => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  List<CoursePart> get parts => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CourseCopyWith<Course> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseCopyWith<$Res> {
  factory $CourseCopyWith(Course value, $Res Function(Course) then) =
      _$CourseCopyWithImpl<$Res, Course>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String category,
      String thumbnailUrl,
      String duration,
      String type,
      double progress,
      bool isCompleted,
      List<CoursePart> parts});
}

/// @nodoc
class _$CourseCopyWithImpl<$Res, $Val extends Course>
    implements $CourseCopyWith<$Res> {
  _$CourseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? thumbnailUrl = null,
    Object? duration = null,
    Object? type = null,
    Object? progress = null,
    Object? isCompleted = null,
    Object? parts = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: null == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      parts: null == parts
          ? _value.parts
          : parts // ignore: cast_nullable_to_non_nullable
              as List<CoursePart>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CourseImplCopyWith<$Res> implements $CourseCopyWith<$Res> {
  factory _$$CourseImplCopyWith(
          _$CourseImpl value, $Res Function(_$CourseImpl) then) =
      __$$CourseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String category,
      String thumbnailUrl,
      String duration,
      String type,
      double progress,
      bool isCompleted,
      List<CoursePart> parts});
}

/// @nodoc
class __$$CourseImplCopyWithImpl<$Res>
    extends _$CourseCopyWithImpl<$Res, _$CourseImpl>
    implements _$$CourseImplCopyWith<$Res> {
  __$$CourseImplCopyWithImpl(
      _$CourseImpl _value, $Res Function(_$CourseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? thumbnailUrl = null,
    Object? duration = null,
    Object? type = null,
    Object? progress = null,
    Object? isCompleted = null,
    Object? parts = null,
  }) {
    return _then(_$CourseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: null == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      parts: null == parts
          ? _value._parts
          : parts // ignore: cast_nullable_to_non_nullable
              as List<CoursePart>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CourseImpl implements _Course {
  const _$CourseImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.category,
      required this.thumbnailUrl,
      required this.duration,
      required this.type,
      this.progress = 0.0,
      this.isCompleted = false,
      final List<CoursePart> parts = const []})
      : _parts = parts;

  factory _$CourseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String category;
  @override
  final String thumbnailUrl;
  @override
  final String duration;
  @override
  final String type;
  @override
  @JsonKey()
  final double progress;
  @override
  @JsonKey()
  final bool isCompleted;
  final List<CoursePart> _parts;
  @override
  @JsonKey()
  List<CoursePart> get parts {
    if (_parts is EqualUnmodifiableListView) return _parts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_parts);
  }

  @override
  String toString() {
    return 'Course(id: $id, title: $title, description: $description, category: $category, thumbnailUrl: $thumbnailUrl, duration: $duration, type: $type, progress: $progress, isCompleted: $isCompleted, parts: $parts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            const DeepCollectionEquality().equals(other._parts, _parts));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      category,
      thumbnailUrl,
      duration,
      type,
      progress,
      isCompleted,
      const DeepCollectionEquality().hash(_parts));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseImplCopyWith<_$CourseImpl> get copyWith =>
      __$$CourseImplCopyWithImpl<_$CourseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseImplToJson(
      this,
    );
  }
}

abstract class _Course implements Course {
  const factory _Course(
      {required final String id,
      required final String title,
      required final String description,
      required final String category,
      required final String thumbnailUrl,
      required final String duration,
      required final String type,
      final double progress,
      final bool isCompleted,
      final List<CoursePart> parts}) = _$CourseImpl;

  factory _Course.fromJson(Map<String, dynamic> json) = _$CourseImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get category;
  @override
  String get thumbnailUrl;
  @override
  String get duration;
  @override
  String get type;
  @override
  double get progress;
  @override
  bool get isCompleted;
  @override
  List<CoursePart> get parts;
  @override
  @JsonKey(ignore: true)
  _$$CourseImplCopyWith<_$CourseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
