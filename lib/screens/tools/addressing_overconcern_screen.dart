import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
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
      appBar: AppBar(
        title: const Text('Addressing Overconcern'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : () => _saveImportanceItems(user.id),
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
          ),
        ],
      ),
      body: Column(
        children: [
          // Guide Section
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: _buildGuideSection(context),
          ),

          // Content
          Expanded(
            child: _importanceItems.isEmpty ? _buildEmptyState(context) : _buildContentWithChart(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addImportanceItem,
        backgroundColor: Colors.orange[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildGuideSection(BuildContext context) {
    return Card(
      color: Colors.orange[50],
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Self-Evaluation Exercise',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '1. List the things that are important to you in how you evaluate or judge yourself as a person.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '2. Rate each item in terms of its relative importance (percentages should total 100%).',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '3. View the pie chart to visualize how you distribute your self-worth.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
        child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Items Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Add the things that are important to you in how you evaluate yourself.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _addImportanceItem,
              icon: const Icon(Icons.add),
              label: const Text('Add First Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Row
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your Self-Evaluation Items (${_importanceItems.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isBalanced() ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _isBalanced() ? Colors.green[200]! : Colors.orange[200]!),
                ),
                child: Text(
                  'Total: ${_getTotalPercentage().toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: _isBalanced() ? Colors.green[700] : Colors.orange[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),

          // Pie Chart
          if (_importanceItems.isNotEmpty) ...[
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Self-Worth Distribution',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieChartSections(),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _buildLegend(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Items List
          ...List.generate(_importanceItems.length, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: _buildImportanceItemCard(context, _importanceItems[index], index),
            );
          }),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildImportanceItemCard(BuildContext context, ImportanceItem item, int index) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _getItemColor(index),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
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
                    item.description,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${item.importance.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _editImportanceItem(index),
                      icon: const Icon(Icons.edit, size: 18),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    IconButton(
                      onPressed: () => _removeImportanceItem(index),
                      icon: const Icon(Icons.delete, size: 18),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      color: Colors.red[600],
                    ),
                  ],
                ),
              ],
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getItemColor(index),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              item.description.length > 20 
                  ? '${item.description.substring(0, 20)}...' 
                  : item.description,
              style: Theme.of(context).textTheme.bodySmall,
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
      builder: (context) => AlertDialog(
        title: Text(existingItem != null ? 'Edit Item' : 'Add Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'e.g., How I look, Academic success, Relationships',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: importanceController,
                decoration: const InputDecoration(
                  labelText: 'Importance (%) *',
                  hintText: '0.0 - 100.0',
                  border: OutlineInputBorder(),
                  suffixText: '%',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              Text(
                'Tip: All percentages should add up to 100%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (descriptionController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a description')),
                );
                return;
              }

              final importance = double.tryParse(importanceController.text.trim()) ?? 0.0;
              if (importance < 0 || importance > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Importance must be between 0 and 100')),
                );
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
              
              // Auto-save after adding/editing item
              final user = ref.read(currentUserDataProvider);
              if (user != null) {
                _saveImportanceItems(user.id, showSuccessMessage: false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
            ),
            child: Text(existingItem != null ? 'Update' : 'Add'),
          ),
        ],
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
          const SnackBar(
            content: Text('Items saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving items: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
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

