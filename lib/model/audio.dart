// Audio names correspond to the original short tones generated in tool/generate_sfx.ps1.
// ignore_for_file: constant_identifier_names
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../brand/progress.dart';

class Audio {
  static AudioPlayer? _player;
  static Future<void> _operations = Future.value();

  static Future<void> playAsset(AudioType type) {
    if (!GameProgress.instance.soundEnabled) return Future.value();
    _operations = _operations.then((_) async {
      try {
        final player = _player ??= AudioPlayer();
        await player.stop();
        await player.setAsset('assets/audio/${type.name}.wav');
        if (GameProgress.instance.soundEnabled) {
          unawaited(
            player.play().catchError((Object error) {
              debugPrint('Unable to play sound: $error');
            }),
          );
        }
      } catch (error) {
        debugPrint('Unable to play sound: $error');
      }
    });
    return _operations;
  }

  static Future<void> stop() async {
    await _operations;
    await _player?.stop();
  }
}

enum AudioType { select, invalid, swap, move_down, bomb, game_start, win, lost }
