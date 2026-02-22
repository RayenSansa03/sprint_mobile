import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'scan_models.dart';

class ScanService {
  Future<ScanResult> analyzeImage(File image) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock result
    return ScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      diseaseName: 'Tomato Leaf Miner',
      confidence: 0.94,
      severity: Severity.high,
      recommendations: [
        'Prune infested leaves immediately.',
        'Use pheromone traps to capture adult moths.',
        'Apply Neem oil or Spinosad-based bio-insecticides.',
      ],
      imageUrl: image.path,
      timestamp: DateTime.now(),
    );
  }
}

final scanServiceProvider = Provider((ref) => ScanService());
