import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/problem_solving_provider.dart';
import '../../models/problem_solving.dart';

class ProblemSolvingSurveyScreen extends ConsumerStatefulWidget {
  const ProblemSolvingSurveyScreen({super.key});

  @override
  ConsumerState<ProblemSolvingSurveyScreen> createState() => _ProblemSolvingSurveyScreenState();
}

class _ProblemSolvingSurveyScreenState extends ConsumerState<ProblemSolvingSurveyScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  // Form controllers and values
  final TextEditingController _problemDescriptionController = TextEditingController();
  final List<TextEditingController> _specificProblemControllers = [];
  final List<TextEditingController> _solutionControllers = [];
  final List<TextEditingController> _implicationControllers = [];
  final List<String> _specificProblems = [];
  final List<PotentialSolution> _potentialSolutions = [];
  final Set<String> _chosenSolutionIds = {};

  @override
  void dispose() {
    _pageController.dispose();
    _problemDescriptionController.dispose();
    for (final controller in _specificProblemControllers) {
      controller.dispose();
    }
    for (final controller in _solutionControllers) {
      controller.dispose();
    }
    for (final controller in _implicationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Problem Solving Exercise'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_currentPage + 1} of 5',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${((_currentPage + 1) / 5 * 100).round()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentPage + 1) / 5,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.deepOrange[600]!,
                  ),
                ),
              ],
            ),
          ),
          
          // Survey steps
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildIdentifyProblemStep(),
                _buildSpecifyProblemsStep(),
                _buildConsiderSolutionsStep(),
                _buildImplicationsStep(),
                _buildChooseSolutionsStep(),
              ],
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : (_currentPage < 4 ? _nextPage : _submitExercise),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange[600],
                      foregroundColor: Colors.white,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_currentPage < 4 ? 'Next' : 'Complete Exercise'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentifyProblemStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 1: Identify the Problem',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Take a moment to describe the situation or challenge you\'re facing. Be as detailed as possible.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: TextField(
              controller: _problemDescriptionController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Describe the problem or situation you\'re facing...\n\nFor example: "I\'m struggling with time management at work. I often feel overwhelmed by my workload and find myself procrastinating on important tasks."',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecifyProblemsStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 2: Specify the Problem Accurately',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'What were the root causes of the problem? Break down the main problem into specific, concrete issues. Add each specific problem as a separate item.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Specific Problems (${_specificProblems.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addSpecificProblem,
                icon: const Icon(Icons.add),
                label: const Text('Add Problem'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _specificProblems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.psychology_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No specific problems added yet',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap "Add Problem" to break down your main issue',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _specificProblems.length,
                    itemBuilder: (context, index) => _buildProblemTile(index),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsiderSolutionsStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 3: Consider as Many Solutions as Possible',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Brainstorm potential solutions. Don\'t judge them yet - just think of as many options as possible.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Potential Solutions (${_potentialSolutions.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addPotentialSolution,
                icon: const Icon(Icons.add),
                label: const Text('Add Solution'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _potentialSolutions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lightbulb_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No solutions added yet',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap "Add Solution" to brainstorm options',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _potentialSolutions.length,
                    itemBuilder: (context, index) => _buildSolutionTile(index, showImplications: false),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildImplicationsStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 4: Think Through the Implications',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'For each solution, consider the potential consequences, pros and cons, and what might happen if you implement it.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          if (_potentialSolutions.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No solutions to analyze',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Go back to Step 3 to add solutions first',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _potentialSolutions.length,
                itemBuilder: (context, index) => _buildSolutionTile(index, showImplications: true),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChooseSolutionsStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 5: Choose the Best Solution(s)',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select the solution(s) you want to implement. You can choose multiple solutions that work well together.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          if (_potentialSolutions.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No solutions to choose from',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Go back to Step 3 to add solutions first',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Solutions (${_chosenSolutionIds.length}/${_potentialSolutions.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _potentialSolutions.length,
                      itemBuilder: (context, index) => _buildChoosableSolutionTile(index),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProblemTile(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _specificProblems[index],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            IconButton(
              onPressed: () => _removeSpecificProblem(index),
              icon: const Icon(Icons.delete_outline),
              color: Colors.red[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionTile(int index, {required bool showImplications}) {
    final solution = _potentialSolutions[index];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    solution.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!showImplications)
                  IconButton(
                    onPressed: () => _removePotentialSolution(index),
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red[400],
                  ),
              ],
            ),
            if (showImplications) ...[
              const SizedBox(height: 16),
              Text(
                'Implications:',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _implicationControllers.length > index 
                    ? _implicationControllers[index] 
                    : null,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'What might happen if you implement this solution? Consider pros, cons, and consequences...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) => _updateSolutionImplications(index, value),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChoosableSolutionTile(int index) {
    final solution = _potentialSolutions[index];
    final isSelected = _chosenSolutionIds.contains(solution.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? Colors.deepOrange[50] : null,
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              _chosenSolutionIds.add(solution.id);
            } else {
              _chosenSolutionIds.remove(solution.id);
            }
          });
        },
        title: Text(
          solution.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: solution.implications.isNotEmpty 
            ? Text(
                'Implications: ${solution.implications}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              )
            : null,
        activeColor: Colors.deepOrange[600],
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  void _addSpecificProblem() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Specific Problem'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Describe a specific aspect of the problem...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _specificProblems.add(controller.text.trim());
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeSpecificProblem(int index) {
    setState(() {
      _specificProblems.removeAt(index);
    });
  }

  void _addPotentialSolution() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Potential Solution'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Describe a potential solution...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    final solution = PotentialSolution(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      description: controller.text.trim(),
                      implications: '',
                    );
                    _potentialSolutions.add(solution);
                    _implicationControllers.add(TextEditingController());
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removePotentialSolution(int index) {
    setState(() {
      final solutionId = _potentialSolutions[index].id;
      _potentialSolutions.removeAt(index);
      _chosenSolutionIds.remove(solutionId);
      if (index < _implicationControllers.length) {
        _implicationControllers[index].dispose();
        _implicationControllers.removeAt(index);
      }
    });
  }

  void _updateSolutionImplications(int index, String implications) {
    if (index < _potentialSolutions.length) {
      setState(() {
        _potentialSolutions[index] = _potentialSolutions[index].copyWith(
          implications: implications,
        );
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < 4) {
      if (_validateCurrentStep()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  bool _validateCurrentStep() {
    switch (_currentPage) {
      case 0: // Identify problem
        if (_problemDescriptionController.text.trim().isEmpty) {
          _showValidationError('Please describe the problem you\'re facing.');
          return false;
        }
        break;
      case 1: // Specify problems
        if (_specificProblems.isEmpty) {
          _showValidationError('Please add at least one specific problem.');
          return false;
        }
        break;
      case 2: // Consider solutions
        if (_potentialSolutions.isEmpty) {
          _showValidationError('Please add at least one potential solution.');
          return false;
        }
        break;
      case 3: // Think through implications
        final incompleteImplications = _potentialSolutions
            .where((solution) => solution.implications.trim().isEmpty)
            .length;
        if (incompleteImplications > 0) {
          _showValidationError('Please add implications for all solutions.');
          return false;
        }
        break;
      case 4: // Choose solutions
        if (_chosenSolutionIds.isEmpty) {
          _showValidationError('Please select at least one solution to implement.');
          return false;
        }
        break;
    }
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _submitExercise() async {
    if (!_validateCurrentStep()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) {
        throw 'User not found';
      }

      final exercise = await ref.read(userProblemSolvingExercisesProvider(user.id).notifier).createExercise(
        problemDescription: _problemDescriptionController.text.trim(),
        specificProblems: _specificProblems,
        potentialSolutions: _potentialSolutions,
        chosenSolutionIds: _chosenSolutionIds.toList(),
      );

      if (exercise != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Problem solving exercise completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
