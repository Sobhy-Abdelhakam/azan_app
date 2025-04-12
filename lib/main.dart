import 'package:azan_app/app_init.dart';
import 'package:azan_app/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInit.initialize();
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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Map<String, DateTime>> _prayerTimesFuture;
  @override
  void initState() {
    super.initState();
    _prayerTimesFuture = _loadPrayerTimes();
  }

  Future<Map<String, DateTime>> _loadPrayerTimes() async {
    final prayerTimes = AppInit.prayerTimeService.getPrayerTimes();
    AppInit.notificationService.scheduleAzanNotifications(await prayerTimes);
    return prayerTimes;
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
            title: const Text('Azan App'),
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
            future: _prayerTimesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                print('Error loading prayer times: ${snapshot.error}');
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
