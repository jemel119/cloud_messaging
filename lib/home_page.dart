import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'fcm_service.dart';
 
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}
 
class _HomePageState extends State<HomePage> {
  final _fcm = FCMService();
 
  String _status = 'Waiting for a cloud message…';
  String _imagePath = 'assets/images/default.png';
  String? _token;
 
  @override
  void initState() {
    super.initState();
    _fcm.initialize(onData: _handleMessage);
    _fcm.getToken().then((t) => setState(() => _token = t));
  }
 
  void _handleMessage(RemoteMessage msg) {
    setState(() {
      // Update status from notification title or data
      _status = msg.notification?.title ?? msg.data['action'] ?? 'Payload received';
 
      // Swap image if payload includes "asset" key
      final asset = msg.data['asset'];
      if (asset != null) _imagePath = 'assets/images/$asset.png';
    });
    debugPrint('[UI] title=${msg.notification?.title} data=${msg.data}');
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FCM Demo — Activity 14')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status banner
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _status,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
 
            // Payload-driven image
            Expanded(
              child: Image.asset(
                _imagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.image_not_supported, size: 80),
                ),
              ),
            ),
            const SizedBox(height: 16),
 
            // Token display (for Firebase Console targeting)
            if (_token != null)
              GestureDetector(
                onTap: () {
                  // Copies token to clipboard via SnackBar hint
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Token shown in debug console')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Token (tap for hint):\n${_token!.substring(0, 20)}…',
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}