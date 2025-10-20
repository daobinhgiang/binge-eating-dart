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
        borderRadius: BorderRadius.circular(40.0),
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
          borderRadius: BorderRadius.circular(40.0),
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
        borderRadius: BorderRadius.circular(40.0),
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
          borderRadius: BorderRadius.circular(40.0),
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
        borderRadius: BorderRadius.circular(40.0),
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
          borderRadius: BorderRadius.circular(40.0),
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
                        borderRadius: BorderRadius.circular(40.0),
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
        borderRadius: BorderRadius.circular(40.0),
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
        borderRadius: BorderRadius.circular(40.0),
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
          borderRadius: BorderRadius.circular(40.0),
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient background
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE57373).withOpacity(0.15),
                      const Color(0xFFEF5350).withOpacity(0.10),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE57373).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Color(0xFFE57373),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coping with Urges',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE57373),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Take control with these exercises',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'When you experience urges, these resources can help you stay on track:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildHelpOptionCard(
                      'Urge Surfing Activity',
                      'Practical exercises to manage urges as they arise',
                      Icons.waves,
                      const Color(0xFFE57373),
                      () {
                        Navigator.of(context).pop();
                        context.push('/exercises/urge-surfing');
                      },
                    ),
                  ],
                ),
              ),
              // Actions
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final trackDialog = ref.read(urgeHelpDialogTrackingProvider);
                      trackDialog('dialog_closed');
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE57373),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpOptionCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40.0),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.15),
                        color.withOpacity(0.10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

