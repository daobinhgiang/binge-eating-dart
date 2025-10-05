import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../models/food_diary.dart';
import '../../core/services/food_diary_service.dart';

class AllFoodDiaryEntriesScreen extends ConsumerStatefulWidget {
  const AllFoodDiaryEntriesScreen({super.key});

  @override
  ConsumerState<AllFoodDiaryEntriesScreen> createState() => _AllFoodDiaryEntriesScreenState();
}

class _AllFoodDiaryEntriesScreenState extends ConsumerState<AllFoodDiaryEntriesScreen> {
  final FoodDiaryService _foodDiaryService = FoodDiaryService();
  List<FoodDiary> _allEntries = [];
  List<FoodDiary> _filteredEntries = [];
  bool _isLoading = true;
  String? _error;

  // Filter states
  DateTime? _startDate;
  DateTime? _endDate;
  List<String>? _selectedLocations;
  List<bool>? _selectedBingeStatuses;
  List<String>? _selectedPurgeMethods;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _ensureFiltersInitialized();
    _loadAllEntries();
  }

  void _ensureFiltersInitialized() {
    _selectedLocations ??= <String>[];
    _selectedBingeStatuses ??= <bool>[];
    _selectedPurgeMethods ??= <String>[];
  }

  Future<void> _loadAllEntries() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final user = ref.read(currentUserDataProvider);
      if (user == null) return;

      final entriesByWeek = await _foodDiaryService.getAllFoodDiaries(user.id);
      final allEntries = <FoodDiary>[];
      
      for (final weekEntries in entriesByWeek.values) {
        allEntries.addAll(weekEntries);
      }
      
      allEntries.sort((a, b) => b.mealTime.compareTo(a.mealTime));
      
      setState(() {
        _allEntries = allEntries;
        _filteredEntries = allEntries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _ensureFiltersInitialized();
      final selectedLocations = _selectedLocations!;
      final selectedBingeStatuses = _selectedBingeStatuses!;
      final selectedPurgeMethods = _selectedPurgeMethods!;

      _filteredEntries = _allEntries.where((entry) {
        // Date filter
        if (_startDate != null && entry.mealTime.isBefore(_startDate!)) {
          return false;
        }
        if (_endDate != null && entry.mealTime.isAfter(_endDate!.add(const Duration(days: 1)))) {
          return false;
        }

        // Location filter
        if (selectedLocations.isNotEmpty && !selectedLocations.contains(entry.location)) {
          return false;
        }

        // Binge filter
        if (selectedBingeStatuses.isNotEmpty && !selectedBingeStatuses.contains(entry.isBinge)) {
          return false;
        }

        // Purge method filter
        if (selectedPurgeMethods.isNotEmpty && !selectedPurgeMethods.contains(entry.purgeMethod)) {
          return false;
        }

        // Search query filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          if (!entry.foodAndDrinks.toLowerCase().contains(query) &&
              !entry.contextAndComments.toLowerCase().contains(query)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _ensureFiltersInitialized();
      _selectedLocations!.clear();
      _selectedBingeStatuses!.clear();
      _selectedPurgeMethods!.clear();
      _searchQuery = '';
      _filteredEntries = _allEntries;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Navigation Bar
            _buildNavigationBar(context),
            
            // Filter Section
            _buildFilterSection(),
            
            // Results Section
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorState()
                      : _buildEntriesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'All Food Diary Entries',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _clearFilters,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.clear_all,
                        size: 16,
                        color: Color(0xFF4CAF50),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Clear Filters',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _applyFilters();
            },
            decoration: InputDecoration(
              hintText: 'Search food, drinks, or comments...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF4CAF50)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4CAF50)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'Date Range',
                  _startDate != null || _endDate != null,
                  () => _showDateRangePicker(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Location',
                  (_selectedLocations ?? const []).isNotEmpty,
                  () => _showLocationFilter(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Binge Status',
                  (_selectedBingeStatuses ?? const []).isNotEmpty,
                  () => _showBingeFilter(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Purge Method',
                  (_selectedPurgeMethods ?? const []).isNotEmpty,
                  () => _showPurgeMethodFilter(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Results count
          Text(
            '${_filteredEntries.length} of ${_allEntries.length} entries',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4CAF50) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFF4CAF50) : Colors.grey[300]!,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading entries',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAllEntries,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList() {
    if (_filteredEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _allEntries.isEmpty ? Icons.restaurant_outlined : Icons.filter_list,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _allEntries.isEmpty ? 'No entries found' : 'No entries match your filters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            if (_allEntries.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredEntries.length,
      itemBuilder: (context, index) {
        final entry = _filteredEntries[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showEntryDetails(context, entry),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: Color(0xFF4CAF50),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.foodAndDrinks,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_formatTime(entry.mealTime)} • ${_formatDate(entry.mealTime)} • ${entry.displayLocation}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: entry.isBinge ? Colors.red[50] : Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            entry.isBinge ? 'Binge' : 'Normal',
                            style: TextStyle(
                              color: entry.isBinge ? Colors.red[700] : Colors.green[700],
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (entry.contextAndComments.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        entry.contextAndComments,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (entry.isBinge && entry.purgeMethod != 'none') ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Purge: ${entry.purgeMethodDisplay}',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDateRangePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Date Range'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Start Date'),
              subtitle: Text(_startDate != null ? _formatDate(_startDate!) : 'Not selected'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _startDate = date;
                  });
                  _applyFilters();
                }
              },
            ),
            ListTile(
              title: const Text('End Date'),
              subtitle: Text(_endDate != null ? _formatDate(_endDate!) : 'Not selected'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? DateTime.now(),
                  firstDate: _startDate ?? DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _endDate = date;
                  });
                  _applyFilters();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
              _applyFilters();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showLocationFilter() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter by Location'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text('All Locations'),
                  value: (_selectedLocations ?? const []).isEmpty,
                  onChanged: (value) {
                    setDialogState(() {
                      _ensureFiltersInitialized();
                      if (value == true) {
                        _selectedLocations!.clear();
                      }
                    });
                    setState(() {
                      _ensureFiltersInitialized();
                      if (value == true) {
                        _selectedLocations!.clear();
                      }
                    });
                    _applyFilters();
                    Navigator.of(context).pop();
                  },
                ),
                ...FoodDiary.locationOptions.map((location) => CheckboxListTile(
                  title: Text(location),
                  value: (_selectedLocations ?? const []).contains(location),
                  onChanged: (value) {
                    setDialogState(() {
                      _ensureFiltersInitialized();
                      if (value == true) {
                        _selectedLocations!.add(location);
                      } else {
                        _selectedLocations!.remove(location);
                      }
                    });
                    setState(() {
                      _ensureFiltersInitialized();
                      if (value == true) {
                        _selectedLocations!.add(location);
                      } else {
                        _selectedLocations!.remove(location);
                      }
                    });
                    _applyFilters();
                  },
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  _ensureFiltersInitialized();
                  _selectedLocations!.clear();
                });
                setState(() {
                  _ensureFiltersInitialized();
                  _selectedLocations!.clear();
                });
                _applyFilters();
                Navigator.of(context).pop();
              },
              child: const Text('Clear All'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBingeFilter() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter by Binge Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: const Text('All Entries'),
                value: (_selectedBingeStatuses ?? const []).isEmpty,
                onChanged: (value) {
                  setDialogState(() {
                    _ensureFiltersInitialized();
                    if (value == true) {
                      _selectedBingeStatuses!.clear();
                    }
                  });
                  setState(() {
                    _ensureFiltersInitialized();
                    if (value == true) {
                      _selectedBingeStatuses!.clear();
                    }
                  });
                  _applyFilters();
                  Navigator.of(context).pop();
                },
              ),
              CheckboxListTile(
                title: const Text('Normal Eating'),
                value: (_selectedBingeStatuses ?? const []).contains(false),
                onChanged: (value) {
                  setDialogState(() {
                    _ensureFiltersInitialized();
                    if (value == true) {
                      _selectedBingeStatuses!.add(false);
                    } else {
                      _selectedBingeStatuses!.remove(false);
                    }
                  });
                  setState(() {
                    _ensureFiltersInitialized();
                    if (value == true) {
                      _selectedBingeStatuses!.add(false);
                    } else {
                      _selectedBingeStatuses!.remove(false);
                    }
                  });
                  _applyFilters();
                },
              ),
              CheckboxListTile(
                title: const Text('Binge Episodes'),
                value: (_selectedBingeStatuses ?? const []).contains(true),
                onChanged: (value) {
                  setDialogState(() {
                    _ensureFiltersInitialized();
                    if (value == true) {
                      _selectedBingeStatuses!.add(true);
                    } else {
                      _selectedBingeStatuses!.remove(true);
                    }
                  });
                  setState(() {
                    _ensureFiltersInitialized();
                    if (value == true) {
                      _selectedBingeStatuses!.add(true);
                    } else {
                      _selectedBingeStatuses!.remove(true);
                    }
                  });
                  _applyFilters();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  _ensureFiltersInitialized();
                  _selectedBingeStatuses!.clear();
                });
                setState(() {
                  _ensureFiltersInitialized();
                  _selectedBingeStatuses!.clear();
                });
                _applyFilters();
                Navigator.of(context).pop();
              },
              child: const Text('Clear All'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPurgeMethodFilter() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter by Purge Method'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text('All Methods'),
                  value: (_selectedPurgeMethods ?? const []).isEmpty,
                  onChanged: (value) {
                    setDialogState(() {
                      _ensureFiltersInitialized();
                      if (value == true) {
                        _selectedPurgeMethods!.clear();
                      }
                    });
                    setState(() {
                      _ensureFiltersInitialized();
                      if (value == true) {
                        _selectedPurgeMethods!.clear();
                      }
                    });
                    _applyFilters();
                    Navigator.of(context).pop();
                  },
                ),
                ...FoodDiary.purgeMethodOptions.map((method) => CheckboxListTile(
                  title: Text(_getPurgeMethodDisplay(method)),
                  value: (_selectedPurgeMethods ?? const []).contains(method),
                  onChanged: (value) {
                    setDialogState(() {
                      _ensureFiltersInitialized();
                      if (value == true) {
                        _selectedPurgeMethods!.add(method);
                      } else {
                        _selectedPurgeMethods!.remove(method);
                      }
                    });
                    setState(() {
                      _ensureFiltersInitialized();
                      if (value == true) {
                        _selectedPurgeMethods!.add(method);
                      } else {
                        _selectedPurgeMethods!.remove(method);
                      }
                    });
                    _applyFilters();
                  },
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  _ensureFiltersInitialized();
                  _selectedPurgeMethods!.clear();
                });
                setState(() {
                  _ensureFiltersInitialized();
                  _selectedPurgeMethods!.clear();
                });
                _applyFilters();
                Navigator.of(context).pop();
              },
              child: const Text('Clear All'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  String _getPurgeMethodDisplay(String method) {
    switch (method) {
      case 'none':
        return 'No Purge';
      case 'vomit':
        return 'Vomiting';
      case 'laxatives':
        return 'Laxatives';
      case 'both':
        return 'Both vomiting and laxatives';
      default:
        return 'No Purge';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (entryDate == today) {
      return 'Today';
    } else if (entryDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  void _showEntryDetails(BuildContext context, FoodDiary entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Entry Details - ${_formatTime(entry.mealTime)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Food & Drinks:', entry.foodAndDrinks),
              _buildDetailRow('Time:', _formatTime(entry.mealTime)),
              _buildDetailRow('Date:', '${entry.mealTime.month}/${entry.mealTime.day}/${entry.mealTime.year}'),
              _buildDetailRow('Location:', entry.displayLocation),
              _buildDetailRow('Type:', entry.isBinge ? 'Binge Episode' : 'Normal Eating'),
              if (entry.isBinge) _buildDetailRow('Purge Method:', entry.purgeMethodDisplay),
              if (entry.contextAndComments.isNotEmpty) 
                _buildDetailRow('Comments:', entry.contextAndComments),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
