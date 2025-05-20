import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // Importa image_picker
import 'dart:io'; // Importa dart:io per File

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  String? _profileImageUrl; // Inizializza come null

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _profileImageUrl = prefs.getString('profileImageUrl'); // Carica l'URL della foto profilo
    });
  }

  Future<void> _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  Future<void> _saveNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
  }

  Future<void> _saveProfileImage(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImageUrl', path ?? '');
  }

  Future<void> _changeProfilePicture(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImageUrl = image.path;
      });
      _saveProfileImage(_profileImageUrl); // Salva il percorso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profilo selezionata.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessuna foto profilo selezionata.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
        backgroundColor: Colors.indigo.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade900, Colors.black],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            const Text(
              'Profilo',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: GestureDetector(
                onTap: () {
                  _changeProfilePicture(context);
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: _profileImageUrl != null
                      ? FileImage(File(_profileImageUrl!)) as ImageProvider<Object>?
                      : const AssetImage('assets/default_profile.png'),
                ),
              ),
              title: const Text('Tocca per cambiare la foto profilo', style: TextStyle(color: Colors.white)),
              onTap: () {
                _changeProfilePicture(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text('Modifica Profilo', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Nome, email, ecc.', style: TextStyle(color: Colors.grey)),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funzionalità in sviluppo')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funzionalità in sviluppo')),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Preferenze App',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Modalità Scura', style: TextStyle(color: Colors.white)),
              value: _darkMode,
              secondary: const Icon(Icons.dark_mode, color: Colors.white),
              onChanged: (bool value) {
                setState(() {
                  _darkMode = value;
                  _saveDarkMode(value);
                  // Qui dovresti implementare la logica per cambiare il tema dell'app
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Modalità Scura ${value ? 'attivata' : 'disattivata'}')),
                  );
                });
              },
            ),
            SwitchListTile(
              title: const Text('Notifiche', style: TextStyle(color: Colors.white)),
              value: _notificationsEnabled,
              secondary: const Icon(Icons.notifications, color: Colors.white),
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                  _saveNotificationsEnabled(value);
                  // Qui dovresti implementare la logica per abilitare/disabilitare le notifiche
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Notifiche ${value ? 'attivate' : 'disattivate'}')),
                  );
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Informazioni',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: const Text('Versione App', style: TextStyle(color: Colors.white)),
              subtitle: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.white),
              title: const Text('Guida', style: TextStyle(color: Colors.white)),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funzionalità in sviluppo')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined, color: Colors.white),
              title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funzionalità in sviluppo')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}