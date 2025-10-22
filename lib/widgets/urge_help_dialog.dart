import 'package:flutter/material.dart';

typedef TrackUrgeHelpEvent = void Function(String event);

class UrgeHelpDialog extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onUrgeSurfing;
  final VoidCallback? onLogUrge;
  final VoidCallback? onChat;
  final TrackUrgeHelpEvent? track;

  const UrgeHelpDialog({
    super.key,
    required this.onClose,
    required this.onUrgeSurfing,
    this.onLogUrge,
    this.onChat,
    this.track,
  });

  @override
  Widget build(BuildContext context) {
    track?.call('dialog_opened');

    final colorScheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).colorScheme.surface;
    final surfaceVariant = Theme.of(context).colorScheme.surfaceVariant;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container
        (
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SafeArea(
            minimum: const EdgeInsets.only(top: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, colorScheme),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _OptionCard(
                          title: 'Urge Surfing Activity',
                          icon: Icons.waves,
                          color: const Color(0xFFE57373),
                          surface: surface,
                          surfaceVariant: surfaceVariant,
                          onTap: () {
                            track?.call('tap_urge_surfing');
                            onUrgeSurfing();
                          },
                        ),
                        if (onLogUrge != null) ...[
                          const SizedBox(height: 12),
                          _OptionCard(
                            title: 'Log an Urge',
                            icon: Icons.edit_note,
                            color: const Color(0xFF4CAF50),
                            surface: surface,
                            surfaceVariant: surfaceVariant,
                            onTap: () {
                              track?.call('tap_log_urge');
                              onLogUrge!.call();
                            },
                          ),
                        ],
                        if (onChat != null) ...[
                          const SizedBox(height: 12),
                          _OptionCard(
                            title: 'Chat for Support',
                            icon: Icons.chat_bubble_outline,
                            color: const Color(0xFF2196F3),
                            surface: surface,
                            surfaceVariant: surfaceVariant,
                            onTap: () {
                              track?.call('tap_chat_support');
                              onChat!.call();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Container(height: 1, color: Colors.grey[200]),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            track?.call('dialog_primary_close');
                            onClose();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE57373),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Got it',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          track?.call('dialog_close');
                          onClose();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.psychology,
              color: colorScheme.primary,
              size: 28,
              semanticLabel: 'Urge help',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coping with Urges',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: 'Close',
            child: InkWell(
              onTap: () {
                track?.call('dialog_close_icon');
                onClose();
              },
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color surface;
  final Color surfaceVariant;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.surface,
    required this.surfaceVariant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.arrow_forward_ios, size: 16, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


