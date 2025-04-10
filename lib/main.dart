import 'package:azan_app/core/services/notification_service.dart';
import 'package:azan_app/core/services/prayer_time_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Azan App',
      navigatorKey: navigatorKey,
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
  Map<String, DateTime> _prayerTimes = {};

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    Map<String, DateTime> times = await PrayerTimeService().getPrayerTimes();
    print('prayer times: $times');
    setState(() => _prayerTimes = times);
    // await NotificationService().scheduleAzanNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _prayerTimes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: _prayerTimes.entries.map((entry) {
                      return ListTile(
                        title: Text(entry.key,
                            style: const TextStyle(fontSize: 20)),
                        subtitle: Text(entry.value.toLocal().toString()),
                      );
                    }).toList(),
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      await NotificationService().scheduleNotifi();
                    },
                    child: const Text("Click"))
              ],
            ),
    );
  }
}
