// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScanResult _$ScanResultFromJson(Map<String, dynamic> json) {
  return _ScanResult.fromJson(json);
}

/// @nodoc
mixin _$ScanResult {
  String get id => throw _privateConstructorUsedError;
  String get diseaseName => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  Severity get severity => throw _privateConstructorUsedError;
  List<String> get recommendations => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScanResultCopyWith<ScanResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScanResultCopyWith<$Res> {
  factory $ScanResultCopyWith(
          ScanResult value, $Res Function(ScanResult) then) =
      _$ScanResultCopyWithImpl<$Res, ScanResult>;
  @useResult
  $Res call(
      {String id,
      String diseaseName,
      double confidence,
      Severity severity,
      List<String> recommendations,
      String imageUrl,
      DateTime timestamp});
}

/// @nodoc
class _$ScanResultCopyWithImpl<$Res, $Val extends ScanResult>
    implements $ScanResultCopyWith<$Res> {
  _$ScanResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? diseaseName = null,
    Object? confidence = null,
    Object? severity = null,
    Object? recommendations = null,
    Object? imageUrl = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      diseaseName: null == diseaseName
          ? _value.diseaseName
          : diseaseName // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as Severity,
      recommendations: null == recommendations
          ? _value.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScanResultImplCopyWith<$Res>
    implements $ScanResultCopyWith<$Res> {
  factory _$$ScanResultImplCopyWith(
          _$ScanResultImpl value, $Res Function(_$ScanResultImpl) then) =
      __$$ScanResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String diseaseName,
      double confidence,
      Severity severity,
      List<String> recommendations,
      String imageUrl,
      DateTime timestamp});
}

/// @nodoc
class __$$ScanResultImplCopyWithImpl<$Res>
    extends _$ScanResultCopyWithImpl<$Res, _$ScanResultImpl>
    implements _$$ScanResultImplCopyWith<$Res> {
  __$$ScanResultImplCopyWithImpl(
      _$ScanResultImpl _value, $Res Function(_$ScanResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? diseaseName = null,
    Object? confidence = null,
    Object? severity = null,
    Object? recommendations = null,
    Object? imageUrl = null,
    Object? timestamp = null,
  }) {
    return _then(_$ScanResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      diseaseName: null == diseaseName
          ? _value.diseaseName
          : diseaseName // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as Severity,
      recommendations: null == recommendations
          ? _value._recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScanResultImpl implements _ScanResult {
  const _$ScanResultImpl(
      {required this.id,
      required this.diseaseName,
      required this.confidence,
      required this.severity,
      required final List<String> recommendations,
      required this.imageUrl,
      required this.timestamp})
      : _recommendations = recommendations;

  factory _$ScanResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScanResultImplFromJson(json);

  @override
  final String id;
  @override
  final String diseaseName;
  @override
  final double confidence;
  @override
  final Severity severity;
  final List<String> _recommendations;
  @override
  List<String> get recommendations {
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendations);
  }

  @override
  final String imageUrl;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'ScanResult(id: $id, diseaseName: $diseaseName, confidence: $confidence, severity: $severity, recommendations: $recommendations, imageUrl: $imageUrl, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScanResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.diseaseName, diseaseName) ||
                other.diseaseName == diseaseName) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            const DeepCollectionEquality()
                .equals(other._recommendations, _recommendations) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      diseaseName,
      confidence,
      severity,
      const DeepCollectionEquality().hash(_recommendations),
      imageUrl,
      timestamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScanResultImplCopyWith<_$ScanResultImpl> get copyWith =>
      __$$ScanResultImplCopyWithImpl<_$ScanResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScanResultImplToJson(
      this,
    );
  }
}

abstract class _ScanResult implements ScanResult {
  const factory _ScanResult(
      {required final String id,
      required final String diseaseName,
      required final double confidence,
      required final Severity severity,
      required final List<String> recommendations,
      required final String imageUrl,
      required final DateTime timestamp}) = _$ScanResultImpl;

  factory _ScanResult.fromJson(Map<String, dynamic> json) =
      _$ScanResultImpl.fromJson;

  @override
  String get id;
  @override
  String get diseaseName;
  @override
  double get confidence;
  @override
  Severity get severity;
  @override
  List<String> get recommendations;
  @override
  String get imageUrl;
  @override
  DateTime get timestamp;
  @override
  @JsonKey(ignore: true)
  _$$ScanResultImplCopyWith<_$ScanResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
