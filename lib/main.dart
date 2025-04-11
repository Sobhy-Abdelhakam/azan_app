import 'package:azan_app/core/services/notification_service.dart';
import 'package:azan_app/core/services/prayer_time_service.dart';
import 'package:azan_app/core/services/settings_service.dart';
import 'package:azan_app/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Azan App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Azan App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Map<String, DateTime>> _prayerTimes;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    final settings = await SettingsService().loadSettings();
    _prayerTimes = PrayerTimeService(settings: settings).getPrayerTimes();
    NotificationService().scheduleAzanNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/images/mosque.jpg',
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.white.withAlpha(100),
            elevation: 0,
            title: Text(widget.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Navigate to settings page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              )
            ],
          ),
          body: FutureBuilder<Map<String, DateTime>>(
            future: _prayerTimes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading prayer times.'));
              }
              final prayerTimes = snapshot.data!;
              return Center(
                child: Card(
                  elevation: 4,
                  color: Colors.white.withAlpha(100),
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ListView.separated(
                      itemCount: prayerTimes.length,
                      shrinkWrap: true,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final name = prayerTimes.keys.elementAt(index);
                        final time = prayerTimes[name]!;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.black),
                            ),
                            Text(
                              DateFormat('hh:mm a').format(time),
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
