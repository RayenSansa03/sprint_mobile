import 'package:freezed_annotation/freezed_annotation.dart';

part 'scan_models.freezed.dart';
part 'scan_models.g.dart';

enum Severity { low, medium, high }

@freezed
class ScanResult with _$ScanResult {
  const factory ScanResult({
    required String id,
    required String diseaseName,
    required double confidence,
    required Severity severity,
    required List<String> recommendations,
    required String imageUrl,
    required DateTime timestamp,
  }) = _ScanResult;

  factory ScanResult.fromJson(Map<String, dynamic> json) => _$ScanResultFromJson(json);
}
