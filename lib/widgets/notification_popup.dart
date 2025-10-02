import 'package:flutter/material.dart';
import '../models/app_notification.dart';

/// A popup notification widget that appears at the top of the screen
/// when a new notification arrives while the app is in the foreground
class NotificationPopup extends StatefulWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final Duration displayDuration;

  const NotificationPopup({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
    this.displayDuration = const Duration(seconds: 5),
  });

  @override
  State<NotificationPopup> createState() => _NotificationPopupState();
}

class _NotificationPopupState extends State<NotificationPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start animation
    _controller.forward();

    // Auto-dismiss after display duration
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    if (mounted) {
      widget.onDismiss();
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'lesson':
        return Icons.school;
      case 'reminder':
        return Icons.restaurant_menu;
      case 'achievement':
        return Icons.celebration;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'lesson':
        return Colors.blue;
      case 'reminder':
        return const Color(0xFF7fb781);
      case 'achievement':
        return Colors.amber;
      case 'system':
        return Colors.grey;
      default:
        return const Color(0xFF7fb781);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getNotificationColor(widget.notification.type);
    final icon = _getNotificationIcon(widget.notification.type);

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 48, 16, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _dismiss();
              widget.onTap();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.notification.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.notification.body,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Dismiss button
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: _dismiss,
                    color: Colors.grey[600],
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Service to display notification popups
class NotificationPopupService {
  static final NotificationPopupService _instance = NotificationPopupService._internal();
  factory NotificationPopupService() => _instance;
  NotificationPopupService._internal();

  OverlayEntry? _currentOverlay;

  /// Show a notification popup
  void show({
    required BuildContext context,
    required AppNotification notification,
    required VoidCallback onTap,
  }) {
    // Dismiss any existing popup
    dismiss();

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: NotificationPopup(
          notification: notification,
          onTap: onTap,
          onDismiss: dismiss,
        ),
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  /// Dismiss the current popup
  void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

