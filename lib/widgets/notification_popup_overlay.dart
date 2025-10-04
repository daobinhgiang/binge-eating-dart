import 'package:flutter/material.dart';

/// A simple wrapper widget that just passes through its child
/// (notification popup functionality removed)
class NotificationPopupOverlay extends StatelessWidget {
  final Widget child;

  const NotificationPopupOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

