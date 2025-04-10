import 'package:azan_app/core/services/audio_service.dart';
import 'package:flutter/material.dart';

class AzanScreen extends StatefulWidget {
  final String prayerName;
  const AzanScreen({super.key, required this.prayerName});

  @override
  State<AzanScreen> createState() => _AzanScreenState();
}

class _AzanScreenState extends State<AzanScreen> {
  final player = AudioService();

  @override
  void initState() {
    super.initState();
    player.playAzan();
  }
  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          spacing: 20,
          children: [
            const Icon(
              Icons.mosque,
              size: 100,
              color: Colors.greenAccent,
            ),
            Text(
              '${widget.prayerName} Azan',
              style: const TextStyle(color: Colors.white, fontSize: 28),
            ),
            ElevatedButton(
              onPressed: () {
                player.stopAzan();
                Navigator.pop(context);
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }
}
