import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notification_provider.dart';
import '../../providers/regular_eating_provider.dart';
import '../../providers/auth_provider.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize notification service when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final user = ref.watch(authNotifierProvider).value;
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to manage notifications')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF7fb781),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Regular Eating Notifications Section
            _buildSectionCard(
              title: 'Regular Eating Reminders',
              icon: Icons.restaurant,
              children: [
                _buildNotificationToggle(
                  title: 'Enable Meal Reminders',
                  subtitle: 'Get notified at your scheduled meal times',
                  value: notificationSettings.isEnabled,
                  onChanged: (value) {
                    ref.read(notificationSettingsProvider.notifier).toggleNotifications(value);
                  },
                ),
                const SizedBox(height: 16),
                _buildNotificationToggle(
                  title: 'Sound Notifications',
                  subtitle: 'Play sound when notifications arrive',
                  value: notificationSettings.soundEnabled,
                  onChanged: (value) {
                    ref.read(notificationSettingsProvider.notifier).toggleSound(value);
                  },
                ),
                const SizedBox(height: 16),
                _buildNotificationToggle(
                  title: 'Vibration',
                  subtitle: 'Vibrate when notifications arrive',
                  value: notificationSettings.vibrationEnabled,
                  onChanged: (value) {
                    ref.read(notificationSettingsProvider.notifier).toggleVibration(value);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Notification Management Section
            _buildSectionCard(
              title: 'Notification Management',
              icon: Icons.settings,
              children: [
                _buildActionButton(
                  title: 'Reschedule Notifications',
                  subtitle: 'Update notifications based on your current eating schedule',
                  icon: Icons.schedule,
                  onTap: () async {
                    await ref.read(userRegularEatingProvider(user.id).notifier).rescheduleNotifications();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications have been rescheduled'),
                          backgroundColor: Color(0xFF7fb781),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  title: 'Cancel All Notifications',
                  subtitle: 'Stop all regular eating reminders',
                  icon: Icons.notifications_off,
                  onTap: () async {
                    await ref.read(userRegularEatingProvider(user.id).notifier).cancelNotifications();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All notifications have been cancelled'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Information Section
            _buildSectionCard(
              title: 'About Notifications',
              icon: Icons.info_outline,
              children: [
                const Text(
                  'Regular eating notifications help you maintain a consistent eating schedule. '
                  'Notifications are scheduled based on your first meal time and meal interval settings. '
                  'You can customize when and how you receive these reminders.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                if (notificationSettings.firebaseToken != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Push notifications are enabled',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF7fb781), size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5016),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D5016),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF7fb781),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF7fb781), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D5016),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
