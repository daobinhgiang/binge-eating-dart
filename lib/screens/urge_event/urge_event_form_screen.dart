import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class UrgeEventFormScreen extends ConsumerStatefulWidget {
  final int initialUrgeLevel;
  final String? returnRoute;

  const UrgeEventFormScreen({
    super.key,
    required this.initialUrgeLevel,
    this.returnRoute,
  });

  @override
  ConsumerState<UrgeEventFormScreen> createState() => _UrgeEventFormScreenState();
}

class _UrgeEventFormScreenState extends ConsumerState<UrgeEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  int _urgeLevel = 0;
  String? _location;
  final List<String> _selectedTriggers = [];
  final List<String> _selectedCopingStrategies = [];
  bool _wasResisted = false;

  final List<String> _locationOptions = [
    'Home',
    'Work/School',
    'In transit',
    'Restaurant/Store',
    'Outdoors',
    'Other'
  ];

  final List<String> _triggerOptions = [
    'Skipped/Delayed eating',
    'Conflict',
    'Criticism',
    'Work/School stress',
    'Boredom',
    'Exposure to tempting foods',
    'Alcohol',
    'Being alone',
    'Tired/poor sleep',
    'Emotional distress',
    'Other'
  ];

  final List<String> _copingOptions = [
    'Urge surfing',
    'Opposite action',
    'Mindful grounding',
    'Reaching out to someone',
    'Distraction (activity)',
    'Ate a planned meal/snack',
    'Left cue situation',
    'Deep breathing',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _urgeLevel = widget.initialUrgeLevel;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveUrgeEvent() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return;
      }

      // TODO: Save to Firestore using a service
      // For now, just show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URGE event logged successfully!')),
        );
        
        // Navigate back
        if (widget.returnRoute != null) {
          context.go(widget.returnRoute!);
        } else {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving URGE event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log URGE Event'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (widget.returnRoute != null) {
              context.go(widget.returnRoute!);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Urge Level
              Text(
                'Urge Level',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_urgeLevel',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Slider(
                value: _urgeLevel.toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                onChanged: (value) {
                  setState(() {
                    _urgeLevel = value.round();
                  });
                },
              ),
              const SizedBox(height: 24),

              // Location
              Text(
                'Location',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _location,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select location',
                ),
                items: _locationOptions.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _location = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Triggers
              Text(
                'What triggered this urge? (select all that apply)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._triggerOptions.map((trigger) {
                return CheckboxListTile(
                  title: Text(trigger),
                  value: _selectedTriggers.contains(trigger),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedTriggers.add(trigger);
                      } else {
                        _selectedTriggers.remove(trigger);
                      }
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 24),

              // Coping Strategies
              Text(
                'What coping strategies did you use? (select all that apply)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._copingOptions.map((coping) {
                return CheckboxListTile(
                  title: Text(coping),
                  value: _selectedCopingStrategies.contains(coping),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedCopingStrategies.add(coping);
                      } else {
                        _selectedCopingStrategies.remove(coping);
                      }
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 24),

              // Was Resisted
              SwitchListTile(
                title: const Text('Did you resist this urge?'),
                subtitle: const Text('Check if you successfully resisted the urge to binge'),
                value: _wasResisted,
                onChanged: (value) {
                  setState(() {
                    _wasResisted = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Outcome
              Text(
                'Outcome (optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Describe what happened after this urge...',
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveUrgeEvent,
                  child: const Text('Save URGE Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
