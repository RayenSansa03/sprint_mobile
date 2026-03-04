import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'learning_models.dart';

class CourseContentScreen extends StatefulWidget {
  final Course course;
  final int partIndex;

  const CourseContentScreen({
    super.key,
    required this.course,
    required this.partIndex,
  });

  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen> {
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.course.parts[widget.partIndex].isCompleted;
  }

  void _toggleCompletion() {
    setState(() {
      _isCompleted = !_isCompleted;
    });
    
    // In a real app, we would call a service to update the progress
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isCompleted ? 'Leçon marquée comme terminée !' : 'Statut mis à jour'),
        backgroundColor: _isCompleted ? AppColors.primary : Colors.grey.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final part = widget.course.parts[widget.partIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.course.title),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'LEÇON ${widget.partIndex + 1}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    part.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  if (part.type == 'video')
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'CONTENU DE LA LEÇON',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    part.content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _toggleCompletion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCompleted ? Colors.white : AppColors.primary,
                  foregroundColor: _isCompleted ? AppColors.primary : Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: _isCompleted ? const BorderSide(color: AppColors.primary) : BorderSide.none,
                  ),
                  elevation: _isCompleted ? 0 : 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isCompleted ? Icons.check_circle : Icons.check_circle_outline),
                    const SizedBox(width: 8),
                    Text(
                      _isCompleted ? 'TERMINÉ' : 'MARQUER COMME TERMINÉ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
