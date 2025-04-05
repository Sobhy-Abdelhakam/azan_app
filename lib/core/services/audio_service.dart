import 'package:just_audio/just_audio.dart';

class AudioService {
  final player = AudioPlayer();
  final String azanSoundPath = 'assets/azan.mp3';
  Future<void> playAzan() async {
    await player.setAsset(azanSoundPath);
    await player.play();
  }
}