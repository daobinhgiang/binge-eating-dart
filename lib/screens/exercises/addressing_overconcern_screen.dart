import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/addressing_overconcern_provider.dart';
import '../../models/addressing_overconcern.dart';

class AddressingOverconcernScreen extends ConsumerStatefulWidget {
  const AddressingOverconcernScreen({super.key});

  @override
  ConsumerState<AddressingOverconcernScreen> createState() => _AddressingOverconcernScreenState();
}

class _AddressingOverconcernScreenState extends ConsumerState<AddressingOverconcernScreen> {
  List<ImportanceItem> _importanceItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadImportanceItems();
    });
  }

  Future<void> _loadImportanceItems() async {
    final user = ref.read(currentUserDataProvider);
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final exercisesAsync = ref.read(userAddressingOverconcernExercisesProvider(user.id));
      exercisesAsync.whenData((exercises) {
        if (exercises.isNotEmpty && mounted) {
          setState(() {
            _importanceItems = List.from(exercises.first.importanceItems);
          });
        }
      });
    } catch (e) {
      // Handle error silently, items will remain empty
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDataProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[600]!, Colors.deepOrange[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 20),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Addressing Overconcern',
                          style: GoogleFonts.quicksand(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button width
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: _importanceItems.isEmpty ? _buildEmptyState(context) : _buildContentWithChart(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addImportanceItem,
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 4,
      ),
    );
  }

  Widget _buildGuideSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.lightBlue[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40.0),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'How to Use',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildGuideStep('1', 'List the things that are important to you in how you evaluate yourself'),
            const SizedBox(height: 12),
            _buildGuideStep('2', 'Rate each item in terms of relative importance (total should be 100%)'),
            const SizedBox(height: 12),
            _buildGuideStep('3', 'View the pie chart to visualize your self-worth distribution'),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideStep(String number, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pie_chart_outline,
                size: 64,
                color: Colors.orange[400],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Items Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Add the things that are important to you in how you evaluate yourself.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _addImportanceItem,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add First Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentWithChart(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Guide Section
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: _buildGuideSection(context),
          ),

          // Summary Row
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your Items (${_importanceItems.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _isBalanced() ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(40.0),
                  border: Border.all(
                    color: _isBalanced() ? Colors.green[200]! : Colors.orange[200]!,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isBalanced() ? Icons.check_circle : Icons.warning,
                      size: 16,
                      color: _isBalanced() ? Colors.green[700] : Colors.orange[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_getTotalPercentage().toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: _isBalanced() ? Colors.green[700] : Colors.orange[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),

          // Pie Chart
          if (_importanceItems.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40.0),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.donut_large, color: Colors.orange[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Self-Worth Distribution',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieChartSections(),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius: 45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _buildLegend(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Items List
          ...List.generate(_importanceItems.length, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: _buildImportanceItemCard(context, _importanceItems[index], index),
            );
          }),
          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildImportanceItemCard(BuildContext context, ImportanceItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getItemColor(index).withOpacity(0.8),
                    _getItemColor(index),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(40.0),
                boxShadow: [
                  BoxShadow(
                    color: _getItemColor(index).withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.description,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(40.0),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Text(
                '${item.importance.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _editImportanceItem(index),
              borderRadius: BorderRadius.circular(40.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.edit, size: 18, color: Colors.grey[600]),
              ),
            ),
            InkWell(
              onTap: () => _removeImportanceItem(index),
              borderRadius: BorderRadius.circular(40.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = _getTotalPercentage();
    if (total == 0) return [];

    return _importanceItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final value = total > 0 ? (item.importance / total) * 100 : 0.0;
      
      return PieChartSectionData(
        color: _getItemColor(index),
        value: value,
        title: '${item.importance.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildLegend() {
    return _importanceItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(40.0),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: _getItemColor(index),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getItemColor(index).withOpacity(0.3),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              item.description.length > 18 
                  ? '${item.description.substring(0, 18)}...' 
                  : item.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getItemColor(int index) {
    final colors = [
      Colors.orange[600]!,
      Colors.blue[600]!,
      Colors.green[600]!,
      Colors.purple[600]!,
      Colors.red[600]!,
      Colors.teal[600]!,
      Colors.amber[600]!,
      Colors.indigo[600]!,
      Colors.pink[600]!,
      Colors.cyan[600]!,
    ];
    return colors[index % colors.length];
  }

  double _getTotalPercentage() {
    return _importanceItems.fold(0.0, (sum, item) => sum + item.importance);
  }

  bool _isBalanced() {
    final total = _getTotalPercentage();
    return (total - 100.0).abs() < 0.1;
  }

  void _addImportanceItem() {
    _showImportanceItemDialog();
  }

  void _editImportanceItem(int index) {
    _showImportanceItemDialog(existingItem: _importanceItems[index], index: index);
  }

  void _removeImportanceItem(int index) {
    setState(() {
      _importanceItems.removeAt(index);
    });
    // Auto-save after removing item
    _autoSave();
  }

  void _autoSave() {
    final user = ref.read(currentUserDataProvider);
    if (user != null) {
      _saveImportanceItems(user.id, showSuccessMessage: false);
    }
  }

  void _showImportanceItemDialog({ImportanceItem? existingItem, int? index}) {
    final descriptionController = TextEditingController(text: existingItem?.description ?? '');
    final importanceController = TextEditingController(text: existingItem?.importance.toStringAsFixed(1) ?? '');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
        child: GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping anywhere on the dialog
            FocusScope.of(context).unfocus();
          },
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange[50]!, Colors.deepOrange[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Icon(
                          existingItem != null ? Icons.edit : Icons.add_circle_outline,
                          color: Colors.orange[700],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        existingItem != null ? 'Edit Item' : 'Add New Item',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                ),

              // Content
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(40.0),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., How I look, Academic success, Relationships',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        maxLines: 2,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          // Dismiss keyboard when Done is pressed
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Importance (%)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(40.0),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: importanceController,
                        decoration: const InputDecoration(
                          hintText: '0.0 - 100.0',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                          suffixText: '%',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          // Dismiss keyboard when Done is pressed
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(40.0),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tip: All percentages should add up to 100%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (descriptionController.text.trim().isEmpty) {
                          _showValidationError('Please enter a description');
                          return;
                        }

                        final importance = double.tryParse(importanceController.text.trim()) ?? 0.0;
                        if (importance < 0 || importance > 100) {
                          _showValidationError('Importance must be between 0 and 100');
                          return;
                        }

                        final item = ImportanceItem(
                          id: existingItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          description: descriptionController.text.trim(),
                          importance: importance,
                        );

                        setState(() {
                          if (index != null) {
                            _importanceItems[index] = item;
                          } else {
                            _importanceItems.add(item);
                          }
                        });

                        Navigator.of(context).pop();
                        
                        // Auto-save after any change
                        _autoSave();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                      ),
                      child: Text(existingItem != null ? 'Update' : 'Add'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _saveImportanceItems(String userId, {bool showSuccessMessage = true}) async {
    if (_isLoading) return; // Prevent multiple simultaneous saves
    
    setState(() {
      _isLoading = true;
    });

    try {
      final exercisesAsync = ref.read(userAddressingOverconcernExercisesProvider(userId));
      
      await exercisesAsync.when(
        data: (exercises) async {
          if (exercises.isNotEmpty) {
            // Update existing exercise
            await ref.read(userAddressingOverconcernExercisesProvider(userId).notifier).updateExercise(
              exerciseId: exercises.first.id,
              importanceItems: _importanceItems,
            );
          } else {
            // Create new exercise
            await ref.read(userAddressingOverconcernExercisesProvider(userId).notifier).createExercise(
              importanceItems: _importanceItems,
            );
          }
        },
        loading: () async {
          // Create new exercise if still loading
          await ref.read(userAddressingOverconcernExercisesProvider(userId).notifier).createExercise(
            importanceItems: _importanceItems,
          );
        },
        error: (error, stackTrace) async {
          // Create new exercise on error
          await ref.read(userAddressingOverconcernExercisesProvider(userId).notifier).createExercise(
            importanceItems: _importanceItems,
          );
        },
      );

      if (mounted && showSuccessMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Items saved successfully!')),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error saving items: $e')),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

