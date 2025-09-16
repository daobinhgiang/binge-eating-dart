import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/journal_entry.dart';
import '../../providers/journal_provider.dart';

class JournalEntryDetailScreen extends ConsumerStatefulWidget {
  final JournalEntry entry;

  const JournalEntryDetailScreen({
    super.key,
    required this.entry,
  });

  @override
  ConsumerState<JournalEntryDetailScreen> createState() => _JournalEntryDetailScreenState();
}

class _JournalEntryDetailScreenState extends ConsumerState<JournalEntryDetailScreen> {
  late TextEditingController _contentController;
  late TextEditingController _moodController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.entry.content);
    _moodController = TextEditingController(text: widget.entry.mood ?? '');
  }

  @override
  void dispose() {
    _contentController.dispose();
    _moodController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content cannot be empty')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(journalEntriesProvider.notifier).updateEntry(
        widget.entry.id,
        _contentController.text.trim(),
        mood: _moodController.text.trim().isEmpty ? null : _moodController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry updated successfully')),
        );
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating entry: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteEntry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this journal entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(journalEntriesProvider.notifier).deleteEntry(widget.entry.id);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entry deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting entry: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Entry' : 'Journal Entry'),
        actions: [
          if (!_isEditing) ...[
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: _deleteEntry,
              icon: const Icon(Icons.delete),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and time
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateTime(widget.entry.createdAt),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.entry.updatedAt != widget.entry.createdAt) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Edited ${_formatDateTime(widget.entry.updatedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Content
            Text(
              'Content',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_isEditing) ...[
              TextField(
                controller: _contentController,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Write your thoughts...',
                  border: OutlineInputBorder(),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.entry.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Mood
            Text(
              'Mood',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_isEditing) ...[
              TextField(
                controller: _moodController,
                decoration: const InputDecoration(
                  hintText: 'How are you feeling? (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.entry.mood ?? 'No mood recorded',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: widget.entry.mood != null 
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[600],
                    fontStyle: widget.entry.mood != null ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Tags
            if (widget.entry.tags.isNotEmpty) ...[
              Text(
                'Tags',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.entry.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tag,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _isEditing
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _contentController.text = widget.entry.content;
                          _moodController.text = widget.entry.mood ?? '';
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (entryDate == today) {
      return 'Today at ${_formatTime(dateTime)}';
    } else if (entryDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at ${_formatTime(dateTime)}';
    } else {
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} at ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
