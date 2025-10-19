import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentAudioPath;

  bool get isPlaying => _isPlaying;
  String? get currentAudioPath => _currentAudioPath;

  Future<void> playAudio(String audioPath) async {
    try {
      // If the same audio is already playing, pause it
      if (_isPlaying && _currentAudioPath == audioPath) {
        await pauseAudio();
        return;
      }

      // Stop any currently playing audio
      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      // Play the new audio
      await _audioPlayer.play(AssetSource(audioPath));
      _isPlaying = true;
      _currentAudioPath = audioPath;

      // Listen for completion
      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
        _currentAudioPath = null;
      });

    } catch (e) {
      debugPrint('Error playing audio: $e');
      _isPlaying = false;
      _currentAudioPath = null;
    }
  }

  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
    } catch (e) {
      debugPrint('Error pausing audio: $e');
    }
  }

  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentAudioPath = null;
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
