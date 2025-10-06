import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../models/body_image_diary.dart';
import '../../core/services/body_image_diary_service.dart';

class AllBodyImageDiaryEntriesScreen extends ConsumerStatefulWidget {
  const AllBodyImageDiaryEntriesScreen({super.key});

  @override
  ConsumerState<AllBodyImageDiaryEntriesScreen> createState() => _AllBodyImageDiaryEntriesScreenState();
}

class _AllBodyImageDiaryEntriesScreenState extends ConsumerState<AllBodyImageDiaryEntriesScreen> {
  final BodyImageDiaryService _bodyImageDiaryService = BodyImageDiaryService();
  List<BodyImageDiary> _allEntries = [];
  List<BodyImageDiary> _filteredEntries = [];
  bool _isLoading = true;
  String? _error;

  // Filter states
  DateTime? _startDate;
  DateTime? _endDate;
  List<String>? _selectedHowChecked;
  List<String>? _selectedWhereChecked;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _ensureFiltersInitialized();
    _loadAllEntries();
  }

  void _ensureFiltersInitialized() {
    _selectedHowChecked ??= <String>[];
    _selectedWhereChecked ??= <String>[];
  }

  Future<void> _loadAllEntries() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final user = ref.read(currentUserDataProvider);
      if (user == null) return;

      final entriesByWeek = await _bodyImageDiaryService.getAllBodyImageDiaries(user.id);
      final allEntries = <BodyImageDiary>[];
      
      for (final weekEntries in entriesByWeek.values) {
        allEntries.addAll(weekEntries);
      }
      
      allEntries.sort((a, b) => b.checkTime.compareTo(a.checkTime));
      
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
      final selectedHowChecked = _selectedHowChecked!;
      final selectedWhereChecked = _selectedWhereChecked!;

      _filteredEntries = _allEntries.where((entry) {
        // Date filter
        if (_startDate != null && entry.checkTime.isBefore(_startDate!)) {
          return false;
        }
        if (_endDate != null && entry.checkTime.isAfter(_endDate!.add(const Duration(days: 1)))) {
          return false;
        }

        // How checked filter
        if (selectedHowChecked.isNotEmpty && !selectedHowChecked.contains(entry.howChecked)) {
          return false;
        }

        // Where checked filter
        if (selectedWhereChecked.isNotEmpty && !selectedWhereChecked.contains(entry.whereChecked)) {
          return false;
        }

        // Search query filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          if (!entry.contextAndFeelings.toLowerCase().contains(query)) {
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
      _selectedHowChecked!.clear();
      _selectedWhereChecked!.clear();
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
              color: Colors.teal[600],
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal[600]!.withOpacity(0.3),
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
            'All Body Image Diary Entries',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.teal[200]!,
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
                        color: Colors.teal,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Clear Filters',
                        style: TextStyle(
                          color: Colors.teal,
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
              hintText: 'Search context and feelings...',
              prefixIcon: Icon(Icons.search, color: Colors.teal[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.teal[600]!),
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
                  'How Checked',
                  (_selectedHowChecked ?? const []).isNotEmpty,
                  () => _showHowCheckedFilter(),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Where Checked',
                  (_selectedWhereChecked ?? const []).isNotEmpty,
                  () => _showWhereCheckedFilter(),
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
        color: isActive ? Colors.teal[600] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.teal[600]! : Colors.grey[300]!,
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
              backgroundColor: Colors.teal[600],
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
              _allEntries.isEmpty ? Icons.visibility_outlined : Icons.filter_list,
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
                            color: Colors.teal[600]!.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.visibility,
                            color: Colors.teal,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.displayHowChecked} • ${entry.displayWhereChecked}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${entry.displayCheckTime} • ${_formatDate(entry.checkTime)}',
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
                            color: Colors.teal[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Body Check',
                            style: TextStyle(
                              color: Colors.teal[700],
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (entry.contextAndFeelings.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        entry.contextAndFeelings,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  void _showHowCheckedFilter() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter by How Checked'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text('All Methods'),
                  value: (_selectedHowChecked ?? const []).isEmpty,
                  onChanged: (value) {
                    setDialogState(() {
                      _ensureFiltersInitialized();
                      if (value == true) {
                        _selectedHowChecked!.clear();
                      }
                    });
                    setState(() {
                      _ensureFiltersInitialized();
                      if (value == true) {
                        _selectedHowChecked!.clear();
                      }
                    });
                    _applyFilters();
                    Navigator.of(context).pop();
                  },
                ),
                ...BodyImageDiary.howCheckedOptions.map((method) => CheckboxListTile(
                  title: Text(method),
                  value: (_selectedHowChecked ?? const []).contains(method),
                  onChanged: (value) {
                    setDialogState(() {
                      _ensureFiltersInitialized();
                      if (value == true) {
                        _selectedHowChecked!.add(method);
                      } else {
                        _selectedHowChecked!.remove(method);
                      }
                    });
                    setState(() {
                      _ensureFiltersInitialized();
                      if (value == true) {
                        _selectedHowChecked!.add(method);
                      } else {
                        _selectedHowChecked!.remove(method);
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
                  _selectedHowChecked!.clear();
                });
                setState(() {
                  _ensureFiltersInitialized();
                  _selectedHowChecked!.clear();
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

  void _showWhereCheckedFilter() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter by Where Checked'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text('All Locations'),
                  value: (_selectedWhereChecked ?? const []).isEmpty,
                  onChanged: (value) {
                    setDialogState(() {
                      _ensureFiltersInitialized();
                      if (value == true) {
                        _selectedWhereChecked!.clear();
                      }
                    });
                    setState(() {
                      _ensureFiltersInitialized();
                      if (value == true) {
                        _selectedWhereChecked!.clear();
                      }
                    });
                    _applyFilters();
                    Navigator.of(context).pop();
                  },
                ),
                ...BodyImageDiary.whereCheckedOptions.map((location) => CheckboxListTile(
                  title: Text(location),
                  value: (_selectedWhereChecked ?? const []).contains(location),
                  onChanged: (value) {
                    setDialogState(() {
                      _ensureFiltersInitialized();
                      if (value == true) {
                        _selectedWhereChecked!.add(location);
                      } else {
                        _selectedWhereChecked!.remove(location);
                      }
                    });
                    setState(() {
                      _ensureFiltersInitialized();
                      if (value == true) {
                        _selectedWhereChecked!.add(location);
                      } else {
                        _selectedWhereChecked!.remove(location);
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
                  _selectedWhereChecked!.clear();
                });
                setState(() {
                  _ensureFiltersInitialized();
                  _selectedWhereChecked!.clear();
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

  void _showEntryDetails(BuildContext context, BodyImageDiary entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Entry Details - ${entry.displayCheckTime}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('How Checked:', entry.displayHowChecked),
              _buildDetailRow('Where Checked:', entry.displayWhereChecked),
              _buildDetailRow('Time:', entry.displayCheckTime),
              _buildDetailRow('Date:', '${entry.checkTime.month}/${entry.checkTime.day}/${entry.checkTime.year}'),
              if (entry.contextAndFeelings.isNotEmpty) 
                _buildDetailRow('Context & Feelings:', entry.contextAndFeelings),
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
