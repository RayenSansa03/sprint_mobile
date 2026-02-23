import 'dart:math';
import 'package:flutter/material.dart';

class BlackboardThumbnail extends StatelessWidget {
  final String title;
  final String category;

  const BlackboardThumbnail({
    super.key,
    required this.title,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a pseudo-random seed based on the title to keep thumbnails consistent for the same course
    final random = Random(title.hashCode);
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1B262C), // Dark blackboard color
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        image: DecorationImage(
          image: const NetworkImage('https://www.transparenttextures.com/patterns/blackboard.png'),
          repeat: ImageRepeat.repeat,
          opacity: 0.2,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
        ),
      ),
      child: Stack(
        children: [
          // Chalk dust effect
          ...List.generate(5, (index) {
            return Positioned(
              left: random.nextDouble() * 200,
              top: random.nextDouble() * 100,
              child: Opacity(
                opacity: 0.05,
                child: Icon(Icons.cloud, size: 40 + random.nextDouble() * 40, color: Colors.white),
              ),
            );
          }),
          
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    color: Colors.white.withOpacity(0.8),
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Chalkboard SE', // Fallback to sans-serif if not available
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(height: 2, width: 40, color: Colors.white24),
                ],
              ),
            ),
          ),
          
          // Chalk border effect
          Positioned(
            bottom: 8,
            right: 8,
            child: Opacity(
              opacity: 0.3,
              child: Transform.rotate(
                angle: -0.1,
                child: Container(
                  height: 4,
                  width: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'irrigation': return Icons.water_drop_outlined;
      case 'pest control': return Icons.bug_report_outlined;
      case 'fertilization': return Icons.grass_outlined;
      case 'finance': return Icons.account_balance_outlined;
      default: return Icons.school_outlined;
    }
  }
}
