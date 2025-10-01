import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notification_popup_provider.dart';
import '../providers/app_notification_provider.dart';
import '../providers/auth_provider.dart';
import 'notification_popup.dart';

/// A widget that wraps the app and displays notification popups
class NotificationPopupOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const NotificationPopupOverlay({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<NotificationPopupOverlay> createState() => _NotificationPopupOverlayState();
}

class _NotificationPopupOverlayState extends ConsumerState<NotificationPopupOverlay> {
  @override
  void initState() {
    super.initState();
    
    // Initialize notification listener when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authNotifierProvider).value;
      if (user != null) {
        ref.read(notificationPopupProvider.notifier).initializeForUser(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notification = ref.watch(notificationPopupProvider);
    final user = ref.watch(authNotifierProvider).value;

    return Stack(
      children: [
        widget.child,
        if (notification != null && user != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NotificationPopup(
              notification: notification,
              onTap: () async {
                // Mark notification as read
                try {
                  await ref
                      .read(notificationActionsProvider.notifier)
                      .markAsRead(user.id, notification.id);
                } catch (e) {
                  debugPrint('Failed to mark notification as read: $e');
                }

                // Navigate to action URL if available
                if (notification.actionUrl != null && context.mounted) {
                  context.go(notification.actionUrl!);
                }

                // Clear the popup
                ref.read(notificationPopupProvider.notifier).clearNotification();
              },
              onDismiss: () {
                ref.read(notificationPopupProvider.notifier).clearNotification();
              },
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    // Clean up listener when widget is disposed
    ref.read(notificationPopupProvider.notifier).cleanup();
    super.dispose();
  }
}

