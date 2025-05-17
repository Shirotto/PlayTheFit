import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isEditingProfile = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  late TabController _tabController;

  StreamSubscription? _userDataSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _tabController.dispose();
    _userDataSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      _userDataSubscription = _firestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .listen((snapshot) {
            setState(() {
              _userData = snapshot.data();
              _isLoading = false;

              // Imposta i valori degli input se non sono in modalità di modifica
              if (!_isEditingProfile) {
                _usernameController.text = _userData?['username'] ?? '';
                _bioController.text = _userData?['bio'] ?? '';
              }
            });
          });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_authService.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore
          .collection('users')
          .doc(_authService.currentUser!.uid)
          .update({
            'username': _usernameController.text.trim(),
            'bio': _bioController.text.trim(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      setState(() {
        _isEditingProfile = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profilo aggiornato con successo!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante l\'aggiornamento: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade900, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildProfileHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInfoTab(),
                    _buildStatsTab(),
                    _buildSettingsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          _isEditingProfile
              ? FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: _saveProfile,
                child: const Icon(Icons.save),
              )
              : null,
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade900, Colors.black],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final isOnline = _userData?['isOnline'] ?? false;
    final lastOnline = _userData?['lastOnline'] as Timestamp?;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.shade400,
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    isOnline ? Icons.circle : Icons.access_time,
                    color: isOnline ? Colors.green : Colors.amber,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            _userData?['username'] ?? 'Username',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _userData?['email'] ?? 'email@example.com',
            style: TextStyle(color: Colors.grey[300], fontSize: 16),
          ),
          if (!isOnline && lastOnline != null)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'Ultimo accesso: ${_formatDate(lastOnline.toDate())}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          const SizedBox(height: 10),
          Text(
            _userData?['bio'] ?? 'Nessuna bio disponibile',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Colors.blue.shade400,
      tabs: const [
        Tab(text: 'Profilo'),
        Tab(text: 'Statistiche'),
        Tab(text: 'Impostazioni'),
      ],
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditingProfile)
            _buildEditProfileForm()
          else
            _buildProfileInfo(),

          if (!_isEditingProfile)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Modifica Profilo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isEditingProfile = true;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditProfileForm() {
    return Column(
      children: [
        _buildInfoField(
          'Username',
          Icons.person,
          controller: _usernameController,
          isEditable: true,
        ),
        const SizedBox(height: 15),
        _buildInfoField(
          'Bio',
          Icons.description,
          controller: _bioController,
          isEditable: true,
          maxLines: 4,
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text('Annulla'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                setState(() {
                  _usernameController.text = _userData?['username'] ?? '';
                  _bioController.text = _userData?['bio'] ?? '';
                  _isEditingProfile = false;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    final friendsCount = _userData?['friendsCount'] ?? 0;
    final memberSince = _userData?['createdAt'] as Timestamp?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoField(
          'Username',
          Icons.person,
          value: _userData?['username'] ?? 'Non impostato',
        ),
        const SizedBox(height: 15),
        _buildInfoField(
          'Email',
          Icons.email,
          value: _userData?['email'] ?? 'Non impostato',
        ),
        const SizedBox(height: 15),
        _buildInfoField(
          'Bio',
          Icons.description,
          value: _userData?['bio'] ?? 'Nessuna bio disponibile',
        ),
        const SizedBox(height: 15),
        _buildInfoField('Amici', Icons.people, value: '$friendsCount'),
        const SizedBox(height: 15),
        _buildInfoField(
          'Membro da',
          Icons.calendar_today,
          value:
              memberSince != null
                  ? _formatDate(memberSince.toDate())
                  : 'Data non disponibile',
        ),
      ],
    );
  }

  Widget _buildInfoField(
    String label,
    IconData icon, {
    String? value,
    TextEditingController? controller,
    bool isEditable = false,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade800.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue.shade300, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.blue.shade300,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isEditable)
            TextField(
              controller: controller,
              maxLines: maxLines,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Inserisci $label',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            )
          else
            Text(
              value ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 100,
            color: Colors.blue.shade400.withOpacity(0.7),
          ),
          const SizedBox(height: 20),
          const Text(
            'Le tue statistiche',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Questa sezione mostrerà le statistiche dei tuoi allenamenti',
            style: TextStyle(color: Colors.grey[300]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingsCategory('Account'),
          _buildSettingsTile(
            'Modifica Password',
            Icons.lock_outline,
            onTap: () {
              // Implementare modifica password
            },
          ),
          _buildSettingsTile(
            'Privacy',
            Icons.privacy_tip_outlined,
            onTap: () {
              // Implementare impostazioni privacy
            },
          ),
          _buildSettingsCategory('Notifiche'),
          _buildSettingsTile(
            'Preferenze notifiche',
            Icons.notifications_active_outlined,
            onTap: () {
              // Implementare preferenze notifiche
            },
          ),
          _buildSettingsCategory('Altro'),
          _buildSettingsTile(
            'Aiuto',
            Icons.help_outline,
            onTap: () {
              // Implementare help
            },
          ),
          const Spacer(),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              onPressed: () async {
                await _authService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCategory(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.blue.shade300,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade900.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
