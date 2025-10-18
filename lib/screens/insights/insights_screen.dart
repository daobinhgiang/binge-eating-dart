import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/openai_service.dart';
import '../../core/services/user_learning_service.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  bool _isGeneratingInsights = false;
  List<Map<String, dynamic>> _insightsRecommendations = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Personalized Insights',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE8F5E8), // Light green
                      Color(0xFFF1F8E9), // Very light green
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF4CAF50),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI-Powered Insights',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2E7D32),
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Get personalized recommendations based on your progress',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF2E7D32).withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isGeneratingInsights ? null : _generateInsights,
                        icon: _isGeneratingInsights 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.auto_awesome, size: 20),
                        label: Text(
                          _isGeneratingInsights ? 'Generating...' : 'Generate Insights',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Recommendations section
              if (_insightsRecommendations.isNotEmpty) ...[
                Text(
                  'Recommended for you',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _insightsRecommendations.length,
                    itemBuilder: (context, index) {
                      return _buildInsightRecommendationCard(
                        _insightsRecommendations[index],
                        key: ValueKey('insight_$index'),
                      );
                    },
                  ),
                ),
              ] else if (!_isGeneratingInsights) ...[
                // Empty state
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.auto_awesome_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No insights yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap "Generate Insights" to get personalized recommendations',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
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
      // Get the current user ID
      final authState = ref.read(authNotifierProvider);
      final user = authState.valueOrNull;
      
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to generate insights'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      final openaiService = OpenAIService();
      final response = await openaiService.generateInsights(user.id);
      
      if (mounted) {
        setState(() {
          _insightsRecommendations = List<Map<String, dynamic>>.from(response['recommendations'] ?? []);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate insights: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingInsights = false;
        });
      }
    }
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
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
          onTap: () => _navigateToInsightRecommendation(recommendation),
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Icon(
                    typeIcon, 
                    color: typeColor, 
                    size: 20,
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
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _navigateToInsightRecommendation(Map<String, dynamic> recommendation) {
    final type = recommendation['type'] ?? '';
    final id = recommendation['id'] ?? '';
    
    switch (type) {
      case 'lesson':
        _navigateToInsightLesson(id);
        break;
      case 'tool':
        _navigateToInsightTool(id);
        break;
      case 'journal':
        _navigateToInsightJournal(id);
        break;
      case 'assessment':
        _navigateToInsightAssessment(id);
        break;
      default:
        // Fallback to home
        break;
    }
  }
  
  void _navigateToInsightLesson(String lessonId) {
    // Save last clicked lesson so Home can update the next lesson in realtime
    UserLearningService().saveLastLesson(lessonId);
    // Navigate to specific lesson based on lesson ID (same logic as chatbot)
    switch (lessonId) {
      // Stage 1 lessons
      case 'lesson_1_1':
        context.push('/lesson/1_1');
        break;
      case 'lesson_1_2':
        context.push('/lesson/1_2');
        break;
      case 'lesson_1_2_1':
        context.push('/lesson/1_2_1');
        break;
      case 'lesson_1_3':
        context.push('/lesson/1_3');
        break;
      case 'lesson_2_1':
        context.push('/lesson/2_1');
        break;
      case 'lesson_2_2':
        context.push('/lesson/2_2');
        break;
      case 'lesson_2_3':
        context.push('/lesson/2_3');
        break;
      case 'lesson_3_1':
        context.push('/lesson/3_1');
        break;
      case 'lesson_3_2':
        context.push('/lesson/3_2');
        break;
      case 'lesson_3_3':
        context.push('/lesson/3_3');
        break;
      case 'lesson_3_4':
        context.push('/lesson/3_4');
        break;
      case 'lesson_3_5':
        context.push('/lesson/3_5');
        break;
      case 'lesson_3_6':
        context.push('/lesson/3_6');
        break;
      case 'lesson_3_7':
        context.push('/lesson/3_7');
        break;
      case 'lesson_3_8':
        context.push('/lesson/3_8');
        break;
      case 'lesson_3_9':
        context.push('/lesson/3_9');
        break;
      case 'lesson_3_10':
        context.push('/lesson/3_10');
        break;
      
      // Stage 2 lessons
      case 'lesson_s2_0_1':
        context.push('/lesson/s2_0_1');
        break;
      case 'lesson_s2_0_2':
        context.push('/lesson/s2_0_2');
        break;
      case 'lesson_s2_0_3':
        context.push('/lesson/s2_0_3');
        break;
      case 'lesson_s2_0_4':
        context.push('/lesson/s2_0_4');
        break;
      case 'lesson_s2_0_5':
        context.push('/lesson/s2_0_5');
        break;
      case 'lesson_s2_0_6':
        context.push('/lesson/s2_0_6');
        break;
      case 'lesson_s2_1_1':
        context.push('/lesson/s2_1_1');
        break;
      case 'lesson_s2_1_2':
        context.push('/lesson/s2_1_2');
        break;
      case 'lesson_s2_1_3':
        context.push('/lesson/s2_1_3');
        break;
      case 'lesson_s2_2_1':
        context.push('/lesson/s2_2_1');
        break;
      case 'lesson_s2_2_2':
        context.push('/lesson/s2_2_2');
        break;
      case 'lesson_s2_2_3':
        context.push('/lesson/s2_2_3');
        break;
      case 'lesson_s2_2_4':
        context.push('/lesson/s2_2_4');
        break;
      case 'lesson_s2_2_5':
        context.push('/lesson/s2_2_5');
        break;
      case 'lesson_s2_2_5_1':
        context.push('/lesson/s2_2_5_1');
        break;
      case 'lesson_s2_2_7':
        context.push('/lesson/s2_2_7');
        break;
      case 'lesson_s2_3_1':
        context.push('/lesson/s2_3_1');
        break;
      case 'lesson_s2_3_2':
        context.push('/lesson/s2_3_2');
        break;
      case 'lesson_s2_3_2_1':
        context.push('/lesson/s2_3_2_1');
        break;
      case 'lesson_s2_3_3':
        context.push('/lesson/s2_3_3');
        break;
      case 'lesson_s2_3_4':
        context.push('/lesson/s2_3_4');
        break;
      case 'lesson_s2_3_5':
        context.push('/lesson/s2_3_5');
        break;
      case 'lesson_s2_4_1':
        context.push('/lesson/s2_4_1');
        break;
      case 'lesson_s2_4_2':
        context.push('/lesson/s2_4_2');
        break;
      case 'lesson_s2_4_2_1':
        context.push('/lesson/s2_4_2_1');
        break;
      case 'lesson_s2_4_3':
        context.push('/lesson/s2_4_3');
        break;
      case 'lesson_s2_5_1':
        context.push('/lesson/s2_5_1');
        break;
      case 'lesson_s2_5_2':
        context.push('/lesson/s2_5_2');
        break;
      case 'lesson_s2_6_1':
        context.push('/lesson/s2_6_1');
        break;
      case 'lesson_s2_6_2':
        context.push('/lesson/s2_6_2');
        break;
      case 'lesson_s2_6_3':
        context.push('/lesson/s2_6_3');
        break;
      case 'lesson_s2_7_1':
        context.push('/lesson/s2_7_1');
        break;
      case 'lesson_s2_7_1_1':
        context.push('/lesson/s2_7_1_1');
        break;
      case 'lesson_s2_7_2':
        context.push('/lesson/s2_7_2');
        break;
      case 'lesson_s2_7_3':
        context.push('/lesson/s2_7_3');
        break;
      case 'lesson_s2_7_4':
        context.push('/lesson/s2_7_4');
        break;
      case 'lesson_s2_7_5':
        context.push('/lesson/s2_7_5');
        break;
      case 'lesson_s2_7_6':
        context.push('/lesson/s2_7_6');
        break;
      case 'lesson_s2_7_7':
        context.push('/lesson/s2_7_7');
        break;
      case 'lesson_s2_7_8':
        context.push('/lesson/s2_7_8');
        break;
      case 'lesson_s2_7_2_1':
        context.push('/lesson/s2_7_2_1');
        break;
      
      // Stage 3 lessons
      case 'lesson_s3_0_1':
        context.push('/lesson/s3_0_1');
        break;
      case 'lesson_s3_0_2':
        context.push('/lesson/s3_0_2');
        break;
      case 'lesson_s3_0_2_1':
        context.push('/lesson/s3_0_2_1');
        break;
      default:
        _showInsightLessonNotAvailable(lessonId);
    }
  }
  
  void _navigateToInsightTool(String toolName) {
    // Use the same logic as the chatbot for tool navigation
    // Handle different formats: "Problem Solving", "problem solving", "problem_solving", etc.
    final normalizedName = toolName.toLowerCase().replaceAll('_', ' ');
    
    switch (normalizedName) {
      case 'problem solving':
        context.push('/tools/problem-solving');
        break;
      case 'meal planning':
        context.push('/tools/meal-planning');
        break;
      case 'urge surfing activities':
        context.push('/tools/urge-surfing');
        break;
      case 'addressing overconcern':
        context.push('/tools/addressing-overconcern');
        break;
      case 'addressing setbacks':
        context.push('/tools/addressing-setbacks');
        break;
      default:
        // Try to match partial names for better compatibility
        if (normalizedName.contains('problem') && normalizedName.contains('solving')) {
          context.push('/tools/problem-solving');
        } else if (normalizedName.contains('meal') && normalizedName.contains('planning')) {
          context.push('/tools/meal-planning');
        } else if (normalizedName.contains('urge') && (normalizedName.contains('surfing') || normalizedName.contains('activities'))) {
          context.push('/tools/urge-surfing');
        } else if (normalizedName.contains('overconcern')) {
          context.push('/tools/addressing-overconcern');
        } else if (normalizedName.contains('setbacks')) {
          context.push('/tools/addressing-setbacks');
        } else {
          _showInsightToolNotAvailable(toolName);
        }
    }
  }
  
  void _navigateToInsightJournal(String journalType) {
    // Use the same logic as the chatbot for journal navigation
    // Handle different formats: "Food Diary", "food diary", "food_diary", etc.
    final normalizedType = journalType.toLowerCase().replaceAll('_', ' ');
    
    switch (normalizedType) {
      case 'food diary':
        context.push('/journal/food-diary');
        break;
      case 'weight diary':
        context.push('/journal/weight-diary');
        break;
      case 'body image diary':
        context.push('/journal/body-image-diary');
        break;
      default:
        // Try to match partial names
        if (normalizedType.contains('food')) {
          context.push('/journal/food-diary');
        } else if (normalizedType.contains('weight')) {
          context.push('/journal/weight-diary');
        } else if (normalizedType.contains('body') || normalizedType.contains('image')) {
          context.push('/journal/body-image-diary');
        } else {
          context.push('/journal');
        }
    }
  }
  
  void _navigateToInsightAssessment(String assessmentName) {
    switch (assessmentName.toLowerCase()) {
      case 'ede-q':
        context.push('/lesson/2_1'); // EDE-Q assessment
        break;
      case 'cia':
        context.push('/lesson/2_2'); // CIA assessment
        break;
      case 'general psychiatric':
        context.push('/lesson/2_3'); // General psychiatric assessment
        break;
      default:
        _showInsightAssessmentNotAvailable(assessmentName);
    }
  }
  
  void _showInsightLessonNotAvailable(String lessonId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lesson "$lessonId" is not available yet. Please try another recommendation.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  void _showInsightToolNotAvailable(String toolName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tool "$toolName" is not available yet. Please try another recommendation.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  void _showInsightAssessmentNotAvailable(String assessmentName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Assessment "$assessmentName" is not available yet. Please try another recommendation.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
