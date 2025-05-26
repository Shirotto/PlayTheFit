import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'dart:async';
import '../theme/app_design_system.dart';
import '../widgets/app_components.dart';
import '../widgets/app_background.dart';

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

    return AppScaffold(
      body: Column(
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
      ),      floatingActionButton:
          _isEditingProfile
              ? FloatingActionButton(
                backgroundColor: AppDesignSystem.success,
                foregroundColor: AppDesignSystem.textPrimary,
                onPressed: _saveProfile,
                child: const Icon(Icons.save),
              )
              : null,
    );
  }
  Widget _buildLoadingScreen() {
    return AppScaffold(
      body: AppComponents.loadingIndicator(message: 'Caricamento profilo...'),
    );
  }
  Widget _buildProfileHeader() {
    final isOnline = _userData?['isOnline'] ?? false;
    final lastOnline = _userData?['lastOnline'] as Timestamp?;

    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.paddingL),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppDesignSystem.primary,
                child: Icon(
                  Icons.person, 
                  size: 50, 
                  color: AppDesignSystem.textPrimary,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppDesignSystem.cardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppDesignSystem.textPrimary, 
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isOnline ? Icons.circle : Icons.access_time,
                    color: isOnline ? AppDesignSystem.success : AppDesignSystem.warning,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.paddingM),
          Text(
            _userData?['username'] ?? 'Username',
            style: AppDesignSystem.headingLarge.copyWith(
              color: AppDesignSystem.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDesignSystem.paddingS),
          Text(
            _userData?['email'] ?? 'email@example.com',
            style: AppDesignSystem.bodyLarge.copyWith(
              color: AppDesignSystem.textSecondary,
            ),
          ),
          if (!isOnline && lastOnline != null)
            Padding(
              padding: const EdgeInsets.only(top: AppDesignSystem.paddingS),
              child: Text(
                'Ultimo accesso: ${_formatDate(lastOnline.toDate())}',
                style: AppDesignSystem.bodySmall.copyWith(
                  color: AppDesignSystem.textTertiary,
                ),
              ),
            ),
          const SizedBox(height: AppDesignSystem.paddingS),
          Text(
            _userData?['bio'] ?? 'Nessuna bio disponibile',
            style: AppDesignSystem.bodyMedium.copyWith(
              color: AppDesignSystem.textSecondary,
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
      indicatorColor: AppDesignSystem.primary,
      labelColor: AppDesignSystem.textPrimary,
      unselectedLabelColor: AppDesignSystem.textSecondary,
      labelStyle: AppDesignSystem.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
      ),
      tabs: const [
        Tab(text: 'Profilo'),
        Tab(text: 'Statistiche'),
        Tab(text: 'Impostazioni'),
      ],
    );
  }
  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDesignSystem.paddingL),
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
                padding: const EdgeInsets.only(top: AppDesignSystem.paddingL),
                child: AppComponents.primaryButton(
                  text: 'Modifica Profilo',
                  icon: Icons.edit,
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
  }  Widget _buildEditProfileForm() {
    return Column(
      children: [
        _buildInfoField(
          'Username',
          Icons.person,
          controller: _usernameController,
          isEditable: true,
        ),
        const SizedBox(height: AppDesignSystem.paddingM),
        _buildInfoField(
          'Bio',
          Icons.description,
          controller: _bioController,
          isEditable: true,
          maxLines: 4,
        ),
        const SizedBox(height: AppDesignSystem.paddingM),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: Icon(Icons.cancel, color: AppDesignSystem.error),
              label: Text(
                'Annulla',
                style: AppDesignSystem.bodyMedium.copyWith(
                  color: AppDesignSystem.error,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppDesignSystem.error,
              ),
              onPressed: () {
                setState(() {
                  _usernameController.text = _userData?['username'] ?? '';
                  _bioController.text = _userData?['bio'] ?? '';
                  _isEditingProfile = false;
                });
              },
            ),
            const SizedBox(width: AppDesignSystem.paddingL),
            AppComponents.successButton(
              text: 'Salva',
              icon: Icons.save,
              onPressed: _saveProfile,
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
        ),        const SizedBox(height: AppDesignSystem.paddingM),
        _buildInfoField(
          'Email',
          Icons.email,
          value: _userData?['email'] ?? 'Non impostato',
        ),
        const SizedBox(height: AppDesignSystem.paddingM),
        _buildInfoField(
          'Bio',
          Icons.description,
          value: _userData?['bio'] ?? 'Nessuna bio disponibile',
        ),
        const SizedBox(height: AppDesignSystem.paddingM),
        _buildInfoField('Amici', Icons.people, value: '$friendsCount'),
        const SizedBox(height: AppDesignSystem.paddingM),
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
    return AppComponents.standardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon, 
                color: AppDesignSystem.primary, 
                size: 18,
              ),
              const SizedBox(width: AppDesignSystem.paddingS),
              Text(
                label,
                style: AppDesignSystem.bodyMedium.copyWith(
                  color: AppDesignSystem.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.paddingS),
          if (isEditable)
            TextField(
              controller: controller,
              maxLines: maxLines,
              style: AppDesignSystem.bodyMedium.copyWith(
                color: AppDesignSystem.textPrimary,
              ),
              decoration: AppDesignSystem.inputDecoration(
                hintText: 'Inserisci $label',
              ),
            )
          else
            Text(
              value ?? '',
              style: AppDesignSystem.bodyLarge.copyWith(
                color: AppDesignSystem.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildStatsTab() {
    return AppComponents.emptyState(
      icon: Icons.timeline,
      title: 'Le tue statistiche',
      subtitle: 'Questa sezione mostrerà le statistiche dei tuoi allenamenti',
      iconColor: AppDesignSystem.primary,
    );
  }
  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(AppDesignSystem.paddingL),
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
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.error,
                foregroundColor: AppDesignSystem.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDesignSystem.radiusM),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDesignSystem.paddingXL,
                  vertical: AppDesignSystem.paddingM,
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
  }  Widget _buildSettingsCategory(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppDesignSystem.paddingL, 
        bottom: AppDesignSystem.paddingS,
      ),
      child: Text(
        title,
        style: AppDesignSystem.bodyLarge.copyWith(
          color: AppDesignSystem.primary,
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
    return AppComponents.standardCard(
      margin: const EdgeInsets.only(bottom: AppDesignSystem.paddingS),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppDesignSystem.paddingS, 
          horizontal: AppDesignSystem.paddingM,
        ),
        leading: Container(
          padding: const EdgeInsets.all(AppDesignSystem.paddingS),
          decoration: BoxDecoration(
            color: AppDesignSystem.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon, 
            color: AppDesignSystem.primary, 
            size: 20,
          ),
        ),
        title: Text(
          title, 
          style: AppDesignSystem.bodyMedium.copyWith(
            color: AppDesignSystem.textPrimary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right, 
          color: AppDesignSystem.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
