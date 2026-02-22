// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScanResultImpl _$$ScanResultImplFromJson(Map<String, dynamic> json) =>
    _$ScanResultImpl(
      id: json['id'] as String,
      diseaseName: json['diseaseName'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      severity: $enumDecode(_$SeverityEnumMap, json['severity']),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      imageUrl: json['imageUrl'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$ScanResultImplToJson(_$ScanResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'diseaseName': instance.diseaseName,
      'confidence': instance.confidence,
      'severity': _$SeverityEnumMap[instance.severity]!,
      'recommendations': instance.recommendations,
      'imageUrl': instance.imageUrl,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$SeverityEnumMap = {
  Severity.low: 'low',
  Severity.medium: 'medium',
  Severity.high: 'high',
};
