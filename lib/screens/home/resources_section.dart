import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/firebase_analytics_provider.dart';
import '../../core/services/openai_service.dart';
import '../../providers/auth_provider.dart';

class ResourcesSection extends ConsumerStatefulWidget {
  const ResourcesSection({super.key});

  @override
  ConsumerState<ResourcesSection> createState() => _ResourcesSectionState();
}

class _ResourcesSectionState extends ConsumerState<ResourcesSection> {
  bool _isGeneratingInsights = false;
  List<Map<String, dynamic>> _insightsRecommendations = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Resources title
        Transform.translate(
          offset: const Offset(0, -20),
          child: const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Resources',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 24,
              ),
            ),
          ),
        ),
        
        // Main buttons layout
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Column with Urge Help and AI Chat buttons
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  RepaintBoundary(
                    child: _buildUrgeHelpButton(),
                  ),
                  const SizedBox(height: 16),
                  RepaintBoundary(
                    child: _buildAIChatButton(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Right side - Larger Personalized Insights button
            Expanded(
              flex: 1,
              child: RepaintBoundary(
                child: _buildInsightsButton(),
              ),
            ),
          ],
        ),

        // Recommendations display (if any)
        if (_insightsRecommendations.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildRecommendationsContainer(),
        ],
      ],
    );
  }

  Widget _buildUrgeHelpButton() {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE57373).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final trackUrgeButton = ref.read(urgeRelapseButtonTrackingProvider);
            trackUrgeButton();
            _showUrgeHelpDialog();
          },
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Center(
              child: Text(
                'Urge Help',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE57373),
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIChatButton() {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF64B5F6).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/chat'),
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Center(
              child: Text(
                'AI Chat',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64B5F6),
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsButton() {
    return Container(
      height: 177,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isGeneratingInsights ? null : _generateInsights,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF4CAF50),
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Personalized',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Insights',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isGeneratingInsights ? null : _generateInsights,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: _isGeneratingInsights 
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 8,
                                height: 8,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Generating...',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Generate',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationsContainer() {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 80,
        maxHeight: 200,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[100]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recommended for you',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              ..._insightsRecommendations.asMap().entries.map((entry) => 
                _buildInsightRecommendationCard(entry.value, key: ValueKey('insight_${entry.key}'))
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightRecommendationCard(Map<String, dynamic> recommendation, {Key? key}) {
    final type = recommendation['type'] as String? ?? '';
    final title = recommendation['title'] as String? ?? '';
    final description = recommendation['description'] as String? ?? '';

    IconData typeIcon;
    Color typeColor;
    
    switch (type) {
      case 'lesson':
        typeIcon = Icons.school_outlined;
        typeColor = const Color(0xFF4CAF50);
        break;
      case 'tool':
        typeIcon = Icons.build_outlined;
        typeColor = const Color(0xFF2196F3);
        break;
      case 'journal':
        typeIcon = Icons.edit_note_outlined;
        typeColor = const Color(0xFF9C27B0);
        break;
      case 'assessment':
        typeIcon = Icons.quiz_outlined;
        typeColor = const Color(0xFFFF9800);
        break;
      default:
        typeIcon = Icons.help_outline;
        typeColor = Colors.grey;
    }

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigation will be handled by parent
            // This is a simplified version - full navigation logic from home_screen
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    typeIcon, 
                    color: typeColor, 
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateInsights() async {
    setState(() {
      _isGeneratingInsights = true;
    });
    
    try {
      final authState = ref.read(authNotifierProvider);
      final user = authState.valueOrNull;
      
      if (user == null) {
        return;
      }
      
      final openaiService = OpenAIService();
      final response = await openaiService.generateInsights(user.id);
      
      setState(() {
        _insightsRecommendations = List<Map<String, dynamic>>.from(response['recommendations'] ?? []);
      });
    } catch (e) {
      // Handle error silently or show a snackbar if needed
    } finally {
      setState(() {
        _isGeneratingInsights = false;
      });
    }
  }

  void _showUrgeHelpDialog() {
    final trackDialog = ref.read(urgeHelpDialogTrackingProvider);
    trackDialog('dialog_opened');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.psychology, color: Colors.red[700]),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Coping with Urges'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'When you experience urges to relapse, these resources can help:',
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Learn about urges and coping strategies:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '2. Practice practical coping skills:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildHelpOptionCard(
                'Urge Surfing Activity',
                'Practical exercises to manage urges as they arise',
                Icons.waves,
                Colors.teal,
                () {
                  Navigator.of(context).pop();
                  context.push('/tools/urge-surfing');
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final trackDialog = ref.read(urgeHelpDialogTrackingProvider);
              trackDialog('dialog_closed');
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpOptionCard(String title, String description, IconData icon, MaterialColor color, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.zero,
      color: color[50],
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color[700], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color[700],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: color[700],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

