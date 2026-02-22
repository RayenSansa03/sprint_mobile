import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import 'scan_service.dart';
import 'scan_models.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _processImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(scanServiceProvider);
      final result = await service.analyzeImage(File(image.path));
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ScanResultScreen(result: result)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Plant Health Scan')),
      body: Center(
        child: _isLoading 
          ? _buildLoadingState()
          : _buildOptionState(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: AppColors.primary),
        const SizedBox(height: 24),
        const Text(
          'Analyzing Plant...',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Our AI is detecting potential diseases',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildOptionState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, size: 100, color: AppColors.primary.withOpacity(0.1)),
          const SizedBox(height: 40),
          const Text(
            'Keep your crop healthy',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Scan your plant to detect diseases and get instant treatment recommendations.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () => _processImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take a Photo'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _processImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Upload from Gallery'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanResultScreen extends StatelessWidget {
  final ScanResult result;
  const ScanResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Result')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.file(File(result.imageUrl), height: 300, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(result.diseaseName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      _buildSeverityBadge(result.severity),
                    ],
                  ),
                  Text('Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  const Text('Recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...result.recommendations.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(r)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(Severity severity) {
    Color color;
    String label;
    switch (severity) {
      case Severity.low: color = Colors.green; label = 'LOW'; break;
      case Severity.medium: color = Colors.orange; label = 'MEDIUM'; break;
      case Severity.high: color = Colors.red; label = 'HIGH'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
