import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storageService = StorageService();
  bool _celsius = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final celsius = await _storageService.isCelsius();
    setState(() => _celsius = celsius);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Temperature Unit'),
            subtitle: Text(_celsius ? 'Celsius (°C)' : 'Fahrenheit (°F)'),
            secondary: const Icon(Icons.thermostat),
            value: _celsius,
            onChanged: (v) async {
              await _storageService.setUseCelsius(v);
              setState(() => _celsius = v);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Weather app built with Flutter & Open-Meteo'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Codemagic Weather',
              applicationVersion: '1.1.0',
              children: [
                const Text('A demo weather app showcasing Flutter CI/CD '
                    'with Codemagic. Weather data from Open-Meteo API.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
