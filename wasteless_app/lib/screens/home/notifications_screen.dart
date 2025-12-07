import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          ListTile(
            leading: Icon(Icons.warning, color: Colors.orange),
            title: Text("Carrots expire in 2 days"),
          ),
          ListTile(
            leading: Icon(Icons.timer, color: Colors.red),
            title: Text("Spinach expired"),
          ),
        ],
      ),
    );
  }
}
