import 'dart:io';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/image_picker_mobile_fallback.dart'
    if (dart.library.html) '../../../../core/utils/image_picker_web_fallback.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/models/user.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../providers/auth_notifier.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/header_widget.dart';
import '../widgets/primary_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProfilePage — Création et édition du profil utilisateur
//
// Tables concernées (schéma PostgreSQL) :
//   • profiles     → nom, prenom, telephone, adresse, photo_url
//   • chauffeurs   → numero_permis, categorie_permis,
//                    date_expiration_permis (NOT NULL), km_cumule (NOT NULL)
//   • techniciens  → matricule, specialite
//
// Le champ `role` (table users) est en lecture seule :
// il est attribué par un ADMIN et ne doit pas être modifiable ici.
// ─────────────────────────────────────────────────────────────────────────────

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  static const String routeName = '/profile-setup';

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();

  // ── Contrôleurs — table profiles ─────────────────────────────────────────
  final _nomController     = TextEditingController();
  final _prenomController  = TextEditingController();
  final _phoneController   = TextEditingController();
  final _addressController = TextEditingController();

  // ── Contrôleurs — table chauffeurs ───────────────────────────────────────
  final _permisNumController = TextEditingController();
  final _permisCatController = TextEditingController();
  final _kmCumuleController  = TextEditingController(); // km_cumule NOT NULL DEFAULT 0
  DateTime? _dateExpirationPermis;                      // date_expiration_permis NOT NULL

  // ── Contrôleurs — table techniciens ──────────────────────────────────────
  final _matriculeController  = TextEditingController();
  final _specialiteController = TextEditingController();

  // ── Image de profil ───────────────────────────────────────────────────────
  final _picker = ImagePicker();
  File?      _imageFile;
  Uint8List? _webImageBytes;
  String?    _pickedFileName;
  bool       _isPickingImage = false;

  // ── Animation d'entrée ───────────────────────────────────────────────────
  late final AnimationController _animController;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;

  // ── Rôle lu depuis le provider (lecture seule) ────────────────────────────
  UserRole get _userRole =>
      ref.read(authProvider).user?.role ?? UserRole.CHAUFFEUR;

  // ─────────────────────────────────────────────────────────────────────────
  // Cycle de vie
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animController, curve: Curves.easeOutQuart));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillFromState();
      _animController.forward();
    });
  }

  void _prefillFromState() {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final p = user.profile;
    if (p != null) {
      _nomController.text     = p.nom;
      _prenomController.text  = p.prenom;
      _phoneController.text   = p.telephone ?? '';
      _addressController.text = p.adresse   ?? '';
    }

    final roleInfo = user.roleInfo;
    if (roleInfo != null) {
      if (user.role == UserRole.TECHNICIEN) {
        _matriculeController.text  = roleInfo['matricule']  ?? '';
        _specialiteController.text = roleInfo['specialite'] ?? '';
      } else if (user.role == UserRole.CHAUFFEUR) {
        _permisNumController.text = roleInfo['numero_permis']    ?? '';
        _permisCatController.text = roleInfo['categorie_permis'] ?? '';
        _kmCumuleController.text  =
            (roleInfo['km_cumule'] ?? 0).toString();

        // date_expiration_permis — parsé depuis ISO string ou DATE PG
        final rawDate = roleInfo['date_expiration_permis'];
        if (rawDate != null && rawDate is String && rawDate.isNotEmpty) {
          _dateExpirationPermis = DateTime.tryParse(rawDate);
        }
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    for (final c in [
      _nomController, _prenomController, _phoneController, _addressController,
      _permisNumController, _permisCatController, _kmCumuleController,
      _matriculeController, _specialiteController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sélecteur de date d'expiration du permis
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _pickExpirationDate() async {
    final now  = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateExpirationPermis ?? now.add(const Duration(days: 365)),
      firstDate: now,                                    // pas de date passée
      lastDate: DateTime(now.year + 20),
      helpText: 'Date d\'expiration du permis',
      confirmText: 'CONFIRMER',
      cancelText: 'ANNULER',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A6B3A),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dateExpirationPermis = picked);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Gestion de l'image
  // ─────────────────────────────────────────────────────────────────────────

  void _showPhotoSheet() {
    final hasPhoto = _webImageBytes != null ||
        (ref.read(authProvider).user?.profile?.photoUrl?.isNotEmpty ?? false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Choisir une photo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                leading: _sheetIcon(Icons.photo_library_outlined),
                title: Text(kIsWeb ? 'Choisir un fichier' : 'Galerie photos'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: _sheetIcon(Icons.camera_alt_outlined),
                  title: const Text('Prendre une photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              if (hasPhoto)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  title: const Text('Supprimer la photo',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _imageFile      = null;
                      _webImageBytes  = null;
                      _pickedFileName = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetIcon(IconData icon) => CircleAvatar(
    backgroundColor: const Color(0xFFE8F5E9),
    child: Icon(icon, color: const Color(0xFF1A6B3A)),
  );

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isPickingImage = true);
    try {
      XFile? picked;
      if (kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 100));
        picked = await ImagePickerWebFallback.pickImage();
      } else {
        picked = await _picker.pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 800,
          maxHeight: 800,
        );
      }
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _webImageBytes  = bytes;
        _pickedFileName = picked!.name;
        if (!kIsWeb) _imageFile = File(picked.path);
      });
    } catch (e) {
      debugPrint('Erreur sélection image : $e');
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sauvegarde
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation supplémentaire : date d'expiration obligatoire pour chauffeur
    if (_userRole == UserRole.CHAUFFEUR && _dateExpirationPermis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner la date d\'expiration du permis'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    await ref.read(authProvider.notifier).updateProfile(
      nom:             _nomController.text.trim(),
      prenom:          _prenomController.text.trim(),
      role:            _userRole,
      telephone:       _phoneController.text.trim(),
      adresse:         _addressController.text.trim(),
      // Champs chauffeurs
      numeroPermis:           _permisNumController.text.trim(),
      categoriePermis:        _permisCatController.text.trim(),
      dateExpirationPermis:   _dateExpirationPermis?.toIso8601String().split('T').first,
      kmCumule:               int.tryParse(_kmCumuleController.text.trim()) ?? 0,
      // Champs techniciens
      matricule:  _matriculeController.text.trim(),
      specialite: _specialiteController.text.trim(),
      // Image
      photoPath:  !kIsWeb ? _imageFile?.path : null,
      photoBytes: _webImageBytes,
      photoName:  _pickedFileName,
    );

    if (mounted && ref.read(authProvider).error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil enregistré'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final role      = _userRole;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A6B3A),
        elevation: 0,
        centerTitle: true,
        title: const Text('Modifier Profil',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: Navigator.of(context).canPop()
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        )
            : null,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HeaderWidget(
                height: 160,
                title: 'Configuration',
                subtitle: 'Mise à jour de vos informations',
              ),
              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingHorizontal),
                  child: SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.space20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusXL),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // ── Avatar ──────────────────────────────────
                              _AvatarPicker(
                                user: authState.user,
                                imageFile: _imageFile,
                                imageBytes: _webImageBytes,
                                isLoading: _isPickingImage,
                                onTap: kIsWeb
                                    ? () => _pickImage(ImageSource.gallery)
                                    : _showPhotoSheet,
                              ),
                              const SizedBox(height: 24),

                              // ── Badge rôle (lecture seule) ──────────────
                              _RoleBadge(role: role),
                              const SizedBox(height: 20),

                              // ── Informations personnelles ────────────────
                              const _SectionTitle(
                                icon: Icons.person_outline,
                                label: 'Informations personnelles',
                              ),
                              const SizedBox(height: 12),

                              CustomTextField(
                                label: 'Nom',
                                hintText: 'Nom de famille',
                                prefixIcon: Icons.person,
                                controller: _nomController,
                                validator: (v) => v!.isEmpty ? 'Requis' : null,
                              ),
                              const SizedBox(height: 16),

                              CustomTextField(
                                label: 'Prénom',
                                hintText: 'Prénom',
                                prefixIcon: Icons.person_outline,
                                controller: _prenomController,
                                validator: (v) => v!.isEmpty ? 'Requis' : null,
                              ),
                              const SizedBox(height: 16),

                              CustomTextField(
                                label: 'Téléphone',
                                hintText: '+237 6XX XXX XXX',
                                prefixIcon: Icons.phone,
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                validator: (v) => v!.isEmpty ? 'Requis' : null,
                              ),
                              const SizedBox(height: 16),

                              CustomTextField(
                                label: 'Adresse',
                                hintText: 'Adresse complète',
                                prefixIcon: Icons.location_on,
                                controller: _addressController,
                                validator: (v) => v!.isEmpty ? 'Requis' : null,
                              ),
                              const SizedBox(height: 24),

                              // ── Section CHAUFFEUR ────────────────────────
                              if (role == UserRole.CHAUFFEUR) ...[
                                const _SectionTitle(
                                  icon: Icons.card_membership_outlined,
                                  label: 'Informations permis',
                                ),
                                const SizedBox(height: 12),

                                CustomTextField(
                                  label: 'Numéro de permis',
                                  hintText: 'Ex : CM-2019-004512',
                                  prefixIcon: Icons.card_membership,
                                  controller: _permisNumController,
                                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                                ),
                                const SizedBox(height: 16),

                                CustomTextField(
                                  label: 'Catégorie de permis',
                                  hintText: 'Ex : B, C, D, CE...',
                                  prefixIcon: Icons.category,
                                  controller: _permisCatController,
                                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                                ),
                                const SizedBox(height: 16),

                                // date_expiration_permis — DATE NOT NULL
                                _DatePickerField(
                                  label: 'Date d\'expiration du permis',
                                  selectedDate: _dateExpirationPermis,
                                  isRequired: true,
                                  onTap: _pickExpirationDate,
                                ),
                                const SizedBox(height: 16),

                                // km_cumule — INTEGER NOT NULL DEFAULT 0
                                CustomTextField(
                                  label: 'Kilométrage cumulé',
                                  hintText: '0',
                                  prefixIcon: Icons.speed_outlined,
                                  controller: _kmCumuleController,
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return null;
                                    if (int.tryParse(v) == null) {
                                      return 'Valeur numérique requise';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                              ],

                              // ── Section TECHNICIEN ───────────────────────
                              if (role == UserRole.TECHNICIEN) ...[
                                const _SectionTitle(
                                  icon: Icons.build_outlined,
                                  label: 'Informations technicien',
                                ),
                                const SizedBox(height: 12),

                                CustomTextField(
                                  label: 'Matricule',
                                  hintText: 'Matricule employé',
                                  prefixIcon: Icons.badge,
                                  controller: _matriculeController,
                                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                                ),
                                const SizedBox(height: 16),

                                CustomTextField(
                                  label: 'Spécialité',
                                  hintText: 'Ex : Mécanique, Électricité...',
                                  prefixIcon: Icons.settings,
                                  controller: _specialiteController,
                                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                                ),
                                const SizedBox(height: 24),
                              ],

                              // ── Erreur API ───────────────────────────────
                              if (authState.error != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline,
                                          color: Colors.red, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          authState.error!,
                                          style: const TextStyle(
                                              color: Colors.red, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // ── Bouton ───────────────────────────────────
                              PrimaryButton(
                                text: 'Enregistrer le profil',
                                onPressed: _save,
                                isLoading:
                                authState.isLoading || _isPickingImage,
                                prefixIcon: Icons.check,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET : Sélecteur de date (date_expiration_permis)
// ─────────────────────────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  final String    label;
  final DateTime? selectedDate;
  final bool      isRequired;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.onTap,
    this.selectedDate,
    this.isRequired = false,
  });

  String get _displayValue {
    if (selectedDate == null) return 'Sélectionner une date';
    final d = selectedDate!;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  bool get _isExpired =>
      selectedDate != null && selectedDate!.isBefore(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final isEmpty = selectedDate == null;
    final borderColor = _isExpired
        ? Colors.orange
        : isEmpty && isRequired
        ? Colors.red.shade300
        : AppColors.border;
    final textColor = isEmpty
        ? AppColors.textHint
        : _isExpired
        ? Colors.orange.shade700
        : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 18,
                    color: _isExpired ? Colors.orange : AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _displayValue,
                    style: TextStyle(
                      fontSize: AppDimensions.fontSM,
                      color: textColor,
                    ),
                  ),
                ),
                if (_isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: const Text(
                      'Expiré',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS INTERNES
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarPicker extends StatelessWidget {
  final User?      user;
  final File?      imageFile;
  final Uint8List? imageBytes;
  final bool       isLoading;
  final VoidCallback onTap;

  const _AvatarPicker({
    required this.user,
    required this.isLoading,
    required this.onTap,
    this.imageFile,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                UserAvatar(
                  user: user,
                  radius: 52,
                  localImage: imageFile,
                  localBytes: imageBytes,
                  showBorder: true,
                  borderColor: const Color(0xFF1A6B3A).withOpacity(0.2),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A6B3A),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 16),
                  ),
                ),
                if (isLoading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Appuyer pour changer la photo',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A6B3A).withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1A6B3A).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined,
              size: 18, color: Color(0xFF1A6B3A)),
          const SizedBox(width: 10),
          Text(
            'Rôle : ${role.label}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF1A6B3A),
            ),
          ),
          const Spacer(),
          const Tooltip(
            message: 'Le rôle est attribué par un administrateur',
            child: Icon(Icons.lock_outline,
                size: 14, color: Color(0xFF1A6B3A)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String   label;

  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1A6B3A)),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A6B3A),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider(height: 1)),
      ],
    );
  }
}