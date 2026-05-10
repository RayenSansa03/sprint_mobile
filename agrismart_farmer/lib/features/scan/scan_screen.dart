import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import 'scan_service.dart';
import 'scan_models.dart';
import '../chatbot/chatbot_service.dart';
import '../chatbot/chatbot_model.dart';
import '../chatbot/widgets/chat_widgets.dart';
import '../chatbot/widgets/typing_indicator.dart';
import '../chatbot/widgets/history_drawer.dart';

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
      final result = await service.analyzeImage(image);
      
      if (mounted) {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (context) => ScanResultScreen(result: result)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
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
            'Protégez vos cultures',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Protégez vos récoltes de maïs grâce à un diagnostic IA instantané et des traitements agricoles modernes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Spécialisé en culture de MAÏS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () => _processImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Prendre une Photo'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _processImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Choisir depuis Gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanResultScreen extends ConsumerStatefulWidget {
  final ScanResult result;
  const ScanResultScreen({super.key, required this.result});

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Auto-initiate conversation if it's a first-time view for this result
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scanChatbotControllerProvider.notifier).sendQuery(
        "Expliquez-moi plus sur la maladie : ${widget.result.diseaseName}",
        diagnosticContext: widget.result.diseaseName,
      );
    });
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;
    ref.read(scanChatbotControllerProvider.notifier).sendQuery(
      _chatController.text,
      diagnosticContext: widget.result.diseaseName,
    );
    _chatController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(scanChatbotControllerProvider);
    final isLoading = ref.watch(scanChatbotControllerProvider.notifier).isLoading;

    return Scaffold(
      drawer: const ScanHistoryDrawer(),
      appBar: AppBar(
        title: const Text('Analyse AgriSmart'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Diagnostic Header ---
                  kIsWeb 
                    ? Image.network(widget.result.imageUrl, height: 250, width: double.infinity, fit: BoxFit.cover)
                    : Image.file(File(widget.result.imageUrl), height: 250, width: double.infinity, fit: BoxFit.cover),
                  
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(widget.result.diseaseName, 
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildSeverityBadge(widget.result.severity),
                          ],
                        ),
                        Text('Confiance: ${(widget.result.confidence * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 20),
                        
                        const Text('Recommandations experts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ...widget.result.recommendations.map((r) => Padding(
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
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(),
                        ),
                        
                        // --- Chat Section ---
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('Discuter avec l\'expert IA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Custom ListView inside SingleChildScrollView with NeverScrollableScrollPhysics
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: messages.length + (isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == messages.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: TypingIndicator(color: AppColors.primary),
                              );
                            }
                            return ChatMessageBubble(msg: messages[index]);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // --- Fixed Input Area at bottom ---
          ChatInputArea(
            controller: _chatController,
            onSend: _sendMessage,
            onListen: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veuillez utiliser votre clavier pour cette discussion rapide.')),
              );
            },
            isListening: false,
            bottomPadding: 0, // Navbar enlevé via rootNavigator: true
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityBadge(Severity severity) {
    Color color;
    String label;
    switch (severity) {
      case Severity.low: color = Colors.green; label = 'FAIBLE'; break;
      case Severity.medium: color = Colors.orange; label = 'MOYEN'; break;
      case Severity.high: color = Colors.red; label = 'ÉLEVÉ'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
