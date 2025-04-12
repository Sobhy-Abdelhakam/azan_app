import 'package:azan_app/core/services/settings_service.dart';
import 'package:azan_app/models/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _service = SettingsService();
  AppSettings? _settings;
  bool loading = true;

  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  Future<void> _playAzan() async {
    try {
      if (isPlaying) {
        await _player.stop();
      } else {
        await _player.setAsset('assets/sounds/azan.mp3');
        await _player.play();
      }

      setState(() {
        isPlaying = !isPlaying;
      });
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settings = await _service.loadSettings();
    _cityController.text = _settings!.manualCity;
    _countryController.text = _settings!.manualCountry;
    setState(() => loading = false);
  }

  void _save() async {
    final updated = AppSettings(
      notificationsEnabled: _settings!.notificationsEnabled,
      azanSoundEnabled: _settings!.azanSoundEnabled,
      calculationMethod: _settings!.calculationMethod,
      locationType: _settings!.locationType,
      manualCity: _cityController.text,
      manualCountry: _countryController.text,
    );
    await _service.saveSettings(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved!')),
      );
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
  _countryController.dispose();
  _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading || _settings == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.volume_up),
              title: const Text('Preview Azan Sound'),
              trailing: IconButton(
                icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                onPressed: _playAzan,
              ),
            ),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: _settings!.notificationsEnabled,
              onChanged: (value) {
                setState(() => _settings =
                    _settings!.copyWith(notificationsEnabled: value));
              },
            ),
            SwitchListTile(
              title: const Text('Enable Azan Sound'),
              value: _settings!.azanSoundEnabled,
              onChanged: (value) {
                setState(() {
                  _settings = _settings!.copyWith(azanSoundEnabled: value);
                });
              },
            ),
            const SizedBox(height: 20),
            const Text("Calculation Method",
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<CalculationMethodOption>(
              value: _settings!.calculationMethod,
              items: CalculationMethodOption.values
                  .map((method) => DropdownMenuItem(
                        value: method,
                        child: Text(method.name),
                      ))
                  .toList(),
              onChanged: (val) => setState(() {
                _settings = _settings!.copyWith(calculationMethod: val!);
              }),
            ),
            const SizedBox(height: 20),
            const Text("Location Type",
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<LocationType>(
              value: _settings!.locationType,
              items: LocationType.values
                  .map((loc) => DropdownMenuItem(
                        value: loc,
                        child: Text(loc.name),
                      ))
                  .toList(),
              onChanged: (val) => setState(() {
                _settings = _settings!.copyWith(locationType: val!);
              }),
            ),
            if (_settings!.locationType == LocationType.manual) ...[
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: "City"),
              ),
              TextField(
                controller: _countryController,
                decoration: const InputDecoration(labelText: "Country"),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Save Settings"),
              onPressed: _save,
            )
          ],
        ),
      ),
    );
  }
}
