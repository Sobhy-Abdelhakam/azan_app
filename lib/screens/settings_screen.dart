import 'package:azan_app/core/services/settings_service.dart';
import 'package:azan_app/models/app_settings.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _service = SettingsService();
  late AppSettings _settings;
  bool loading = true;

  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settings = await _service.loadSettings();
    _cityController.text = _settings.manualCity;
    _countryController.text = _settings.manualCountry;
    setState(() => loading = false);
  }

  void _save() async {
    final updated = AppSettings(
      notificationsEnabled: _settings.notificationsEnabled,
      azanSoundEnabled: _settings.azanSoundEnabled,
      calculationMethod: _settings.calculationMethod,
      locationType: _settings.locationType,
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
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: _settings.notificationsEnabled,
              onChanged: (value) {
                setState(() => _settings =
                    _settings.copyWith(notificationsEnabled: value));
              },
            ),
            SwitchListTile(
              title: const Text('Enable Azan Sound'),
              value: _settings.azanSoundEnabled,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(azanSoundEnabled: value);
                });
              },
            ),
            // ListTile(
            //   title: const Text('Calculation Method'),
            //   subtitle: Text(_settings.calculationMethod.name),
            // ),
            // ListTile(
            //   title: const Text('Location Type'),
            //   subtitle: Text(_settings.locationType.name),
            // ),
            // TextField(
            //   controller: _cityController,
            //   decoration: const InputDecoration(labelText: 'Manual City'),
            // ),
            // TextField(
            //   controller: _countryController,
            //   decoration: const InputDecoration(labelText: 'Manual Country'),
            // ),
            // ElevatedButton(
            //   onPressed: _save,
            //   child: const Text('Save Settings'),
            // ),

            const SizedBox(height: 20),
            const Text("Calculation Method",
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<CalculationMethodOption>(
              value: _settings.calculationMethod,
              items: CalculationMethodOption.values
                  .map((method) => DropdownMenuItem(
                        value: method,
                        child: Text(method.name),
                      ))
                  .toList(),
              onChanged: (val) => setState(() {
                _settings = _settings.copyWith(calculationMethod: val!);
              }),
            ),
            const SizedBox(height: 20),
            const Text("Location Type",
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<LocationType>(
              value: _settings.locationType,
              items: LocationType.values
                  .map((loc) => DropdownMenuItem(
                        value: loc,
                        child: Text(loc.name),
                      ))
                  .toList(),
              onChanged: (val) => setState(() {
                _settings = _settings.copyWith(locationType: val!);
              }),
            ),
            if (_settings.locationType == LocationType.manual) ...[
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
