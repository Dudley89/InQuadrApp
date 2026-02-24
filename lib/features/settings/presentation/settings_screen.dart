import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.tune),
            title: Text('Preferenze app'),
            subtitle: Text('Configura esperienza e notifiche.'),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.accessibility_new),
            title: Text('Accessibilità'),
            subtitle: Text('Dimensione testo, contrasto e semplificazioni.'),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Informazioni'),
            subtitle: Text('Versione, privacy e licenze.'),
          ),
        ],
      ),
    );
  }
}
