import 'package:flutter/material.dart';
import '../core/services/audio_service.dart';

class AudioButtonWidget extends StatefulWidget {
  final String audioPath;
  final String? slideId;

  const AudioButtonWidget({
    super.key,
    required this.audioPath,
    this.slideId,
  });

  @override
  State<AudioButtonWidget> createState() => _AudioButtonWidgetState();
}

class _AudioButtonWidgetState extends State<AudioButtonWidget>
    with TickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _isCurrentAudioPlaying {
    return _audioService.isPlaying && 
           _audioService.currentAudioPath == widget.audioPath;
  }

  void _handleAudioToggle() async {
    if (_isCurrentAudioPlaying) {
      await _audioService.pauseAudio();
    } else {
      await _audioService.playAudio(widget.audioPath);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isCurrentAudioPlaying
                    ? [
                        const Color(0xFF66BB6A),
                        const Color(0xFF66BB6A).withOpacity(0.8),
                      ]
                    : [
                        Colors.white,
                        Colors.white.withOpacity(0.9),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _isCurrentAudioPlaying
                      ? const Color(0xFF66BB6A).withOpacity(0.4)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: _isCurrentAudioPlaying ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: _isCurrentAudioPlaying
                    ? const Color(0xFF66BB6A)
                    : const Color(0xFF66BB6A).withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                  });
                  _handleAudioToggle();
                },
                borderRadius: BorderRadius.circular(24),
                splashColor: const Color(0xFF66BB6A).withOpacity(0.1),
                highlightColor: const Color(0xFF66BB6A).withOpacity(0.05),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _isCurrentAudioPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      key: ValueKey(_isCurrentAudioPlaying),
                      color: _isCurrentAudioPlaying
                          ? Colors.white
                          : const Color(0xFF66BB6A),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
