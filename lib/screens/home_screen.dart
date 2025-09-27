import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/analytics_provider.dart';
import '../models/todo_item.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            
            const SizedBox(height: 24),
            
            // Authenticated Content
        Consumer(
          builder: (context, ref, child) {
                final authState = ref.watch(authNotifierProvider);
                
                return authState.when(
                  data: (user) => user != null 
                      ? _buildAuthenticatedContent()
                      : const SizedBox.shrink(),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
            );
          },
        ),
      ],
        ),
        ),
      );
    }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
            'Welcome to Nurtra',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
          const SizedBox(height: 8),
                        Text(
            'Your journey to better health starts here',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[700],
                          ),
                        ),
                      ],
      ),
    );
  }

  Widget _buildAuthenticatedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnalyticsSection(),
        const SizedBox(height: 32),
        _buildTodosSection(),
          ],
    );
  }

  Widget _buildAnalyticsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authNotifierProvider);
        
        return authState.when(
          data: (user) {
            if (user == null) return const SizedBox.shrink();
            
            final analyticsAsync = ref.watch(analyticsNotifierProvider(user.id));
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                analyticsAsync.when(
                  data: (analysis) => _buildAnalyticsCard(context, ref, user.id, analysis ?? {}),
                  loading: () => _buildAnalyticsLoadingCard(context),
                  error: (error, stack) => _buildAnalyticsErrorCard(context, error.toString()),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildAnalyticsCard(BuildContext context, WidgetRef ref, String userId, Map<String, dynamic> analysis) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                    Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                      Text(
                  'Your Progress',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
            const SizedBox(height: 16),
            _buildAnalyticsRow('Total Entries', analysis['totalEntries']?.toString() ?? '0'),
            _buildAnalyticsRow('This Week', analysis['thisWeek']?.toString() ?? '0'),
            _buildAnalyticsRow('Streak', '${analysis['currentStreak'] ?? 0} days'),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
              Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
      ),
    );
  }

  Widget _buildAnalyticsLoadingCard(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text(
              'Loading analytics...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsErrorCard(BuildContext context, String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.orange),
            const SizedBox(width: 16),
            Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  const Text(
                    'Unable to load analytics',
                    style: TextStyle(
                      fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
                Text(
                    'Please try again later',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                  ),
                ),
              ],
                  ),
                ),
              ],
        ),
      ),
    );
  }

  Widget _buildTodosSection() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
              'Today\'s Tasks',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/todos'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
        Consumer(
          builder: (context, ref, child) {
            final user = ref.watch(currentUserDataProvider);
            if (user == null) return const SizedBox.shrink();
            final todosAsync = ref.watch(userTodosProvider(user.id));
            
            return todosAsync.when(
              data: (todos) {
                final incompleteTodos = todos.where((todo) => !todo.isCompleted).take(3).toList();
                
                if (incompleteTodos.isEmpty) {
    return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
                      child: Row(
            children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 32,
                          ),
                  const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'All tasks completed! Great job!',
                              style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
        ),
      ),
    );
  }

                return Column(
                  children: incompleteTodos.map((todo) => _buildTodoCard(todo)).toList(),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
      child: Row(
        children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Loading tasks...'),
              ],
            ),
          ),
              ),
              error: (error, stack) => Card(
      child: Padding(
                  padding: const EdgeInsets.all(16),
        child: Row(
          children: [
                      const Icon(Icons.error_outline, color: Colors.orange),
            const SizedBox(width: 16),
                      const Expanded(
                        child: Text('Unable to load tasks'),
            ),
          ],
        ),
      ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTodoCard(TodoItem todo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) {
            if (value != null) {
              final user = ref.read(currentUserDataProvider);
              if (user != null) {
                ref.read(userTodosProvider(user.id).notifier).markCompleted(todo.id);
              }
            }
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: todo.description.isNotEmpty ? Text(todo.description) : null,
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
  
}