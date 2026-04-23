import 'dart:io';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/image_picker_web_fallback.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/models/user.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../providers/auth_notifier.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/header_widget.dart';
import '../widgets/primary_button.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  static const String routeName = '/profile-setup';

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with TickerProviderStateMixin {
  final _formKey             = GlobalKey<FormState>();
  final _picker              = ImagePicker();
  final _nomController       = TextEditingController();
  final _prenomController    = TextEditingController();
  final _phoneController     = TextEditingController();
  final _addressController   = TextEditingController();
  final _matriculeController = TextEditingController();
  final _specialiteController = TextEditingController();
  final _permisNumController = TextEditingController();
  final _permisCatController = TextEditingController();

  UserRole _selectedRole = UserRole.CHAUFFEUR;

  // ── Photo de profil ──────────────────────────────────────────
  File?   _imageFile;        // image choisie localement (mobile)
  Uint8List? _webImageBytes; // image choisie localement (web/mobile bytes)
  String? _pickedFileName;   // nom du fichier choisi
  bool    _isUploadingPhoto = false;

  late AnimationController      _animController;
  late List<Animation<Offset>>  _slideAnimations;
  late List<Animation<double>>  _fadeAnimations;

  // ── Cycle de vie ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _initAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        setState(() => _selectedRole = user.role);
        if (user.profile != null) {
          _nomController.text     = user.profile!.nom;
          _prenomController.text  = user.profile!.prenom;
          _phoneController.text   = user.profile!.telephone ?? '';
          _addressController.text = user.profile!.adresse   ?? '';

          if (user.roleInfo != null) {
            if (user.role == UserRole.TECHNICIEN) {
              _matriculeController.text  = user.roleInfo!['matricule']  ?? '';
              _specialiteController.text = user.roleInfo!['specialite'] ?? '';
            } else if (user.role == UserRole.CHAUFFEUR) {
              _permisNumController.text = user.roleInfo!['numero_permis']    ?? '';
              _permisCatController.text = user.roleInfo!['categorie_permis'] ?? '';
            }
          }
        }
      }
      _animController.forward();
    });
  }

  void _initAnimations() {
    _slideAnimations = List.generate(
      11,
          (i) => Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Interval(
          i * 0.05,
          0.5 + (i * 0.05),
          curve: Curves.easeOutQuart,
        ),
      )),
    );
    _fadeAnimations = List.generate(
      11,
          (i) => Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animController,
        curve: Interval(
          i * 0.05,
          0.4 + (i * 0.05),
          curve: Curves.easeIn,
        ),
      )),
    );
  }

  @override
  void dispose() {
    for (final c in [
      _nomController,
      _prenomController,
      _phoneController,
      _addressController,
      _matriculeController,
      _specialiteController,
      _permisNumController,
      _permisCatController,
    ]) {
      c.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  // ── Photo — sélection ────────────────────────────────────────

  void _showPhotoSourceSheet() {
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choisir une photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.photo_library_outlined,
                      color: Color(0xFF1A6B3A)),
                ),
                title: Text(kIsWeb ? 'Choisir un fichier' : 'Galerie photos'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.camera_alt_outlined,
                        color: Color(0xFF1A6B3A)),
                  ),
                  title: const Text('Prendre une photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              if (_imageFile != null || _webImageBytes != null || (ref.read(authProvider).user?.profile?.photoUrl?.isNotEmpty ?? false))
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  title: const Text(
                    'Supprimer la photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _imageFile = null;
                      _webImageBytes = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (kIsWeb) await Future.delayed(const Duration(milliseconds: 100));
    
    setState(() => _isUploadingPhoto = true);
    try {
      XFile? picked;
      
      if (kIsWeb) {
        picked = await ImagePickerWebFallback.pickImage();
      } else {
        picked = await _picker.pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 800,
          maxHeight: 800,
        );
      }
      
      if (picked == null) {
        setState(() => _isUploadingPhoto = false);
        return;
      }

      final bytes = await picked.readAsBytes();
      final pName = picked.name;
      final pPath = picked.path;

      setState(() {
        _webImageBytes = bytes;
        _pickedFileName = pName;
        if (!kIsWeb) {
          _imageFile = File(pPath);
        }
        _isUploadingPhoto = false;
      });
    } catch (e) {
      setState(() => _isUploadingPhoto = false);
      debugPrint('Error picking image: $e');
    }
  }

  // ── Sauvegarde ───────────────────────────────────────────────

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(authProvider.notifier).updateProfile(
      nom:             _nomController.text.trim(),
      prenom:          _prenomController.text.trim(),
      role:            _selectedRole,
      telephone:       _phoneController.text.trim(),
      adresse:         _addressController.text.trim(),
      matricule:       _matriculeController.text.trim(),
      specialite:      _specialiteController.text.trim(),
      numeroPermis:    _permisNumController.text.trim(),
      categoriePermis: _permisCatController.text.trim(),
      photoPath:       !kIsWeb ? _imageFile?.path : null,
      photoBytes:      _webImageBytes,
      photoName:       _pickedFileName,
    );

    if (mounted && ref.read(authProvider).error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profil enregistré"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A6B3A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Modifier Profil",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
                title: "Configuration",
                subtitle: "Mise à jour de vos informations",
              ),
              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingHorizontal,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.space20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(AppDimensions.radiusXL),
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
                          _buildAnimated(
                            index: 0,
                            child: _buildAvatarPicker(authState.user),
                          ),
                          const SizedBox(height: 24),

                          _buildAnimated(
                            index: 1,
                            child: _buildRoleDropdown(),
                          ),
                          const SizedBox(height: 20),

                          _buildAnimated(
                            index: 2,
                            child: CustomTextField(
                              label: "Nom",
                              hintText: "Nom",
                              prefixIcon: Icons.person,
                              controller: _nomController,
                              validator: (v) =>
                              v!.isEmpty ? "Requis" : null,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildAnimated(
                            index: 3,
                            child: CustomTextField(
                              label: "Prénom",
                              hintText: "Prénom",
                              prefixIcon: Icons.person_outline,
                              controller: _prenomController,
                              validator: (v) =>
                              v!.isEmpty ? "Requis" : null,
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (_selectedRole == UserRole.TECHNICIEN) ...[
                            _buildAnimated(
                              index: 4,
                              child: CustomTextField(
                                label: "Matricule",
                                hintText: "Matricule",
                                prefixIcon: Icons.badge,
                                controller: _matriculeController,
                                validator: (v) =>
                                v!.isEmpty ? "Requis" : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildAnimated(
                              index: 5,
                              child: CustomTextField(
                                label: "Spécialité",
                                hintText: "Spécialité",
                                prefixIcon: Icons.settings,
                                controller: _specialiteController,
                                validator: (v) =>
                                v!.isEmpty ? "Requis" : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (_selectedRole == UserRole.CHAUFFEUR) ...[
                            _buildAnimated(
                              index: 4,
                              child: CustomTextField(
                                label: "Permis",
                                hintText: "N° Permis",
                                prefixIcon: Icons.card_membership,
                                controller: _permisNumController,
                                validator: (v) =>
                                v!.isEmpty ? "Requis" : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildAnimated(
                              index: 5,
                              child: CustomTextField(
                                label: "Catégorie",
                                hintText: "Catégorie",
                                prefixIcon: Icons.category,
                                controller: _permisCatController,
                                validator: (v) =>
                                v!.isEmpty ? "Requis" : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          _buildAnimated(
                            index: 6,
                            child: CustomTextField(
                              label: "Téléphone",
                              hintText: "Tél",
                              prefixIcon: Icons.phone,
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (v) =>
                              v!.isEmpty ? "Requis" : null,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildAnimated(
                            index: 7,
                            child: CustomTextField(
                              label: "Adresse",
                              hintText: "Adresse",
                              prefixIcon: Icons.location_on,
                              controller: _addressController,
                              validator: (v) =>
                              v!.isEmpty ? "Requis" : null,
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (authState.error != null) ...[
                            Text(
                              authState.error!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                          ],

                          _buildAnimated(
                            index: 9,
                            child: PrimaryButton(
                              text: "Enregistrer le profil",
                              onPressed: _saveProfile,
                              isLoading:
                              authState.isLoading || _isUploadingPhoto,
                              prefixIcon: Icons.check,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPicker(User? user) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: kIsWeb ? () => _pickImage(ImageSource.gallery) : _showPhotoSourceSheet,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                UserAvatar(
                  user: user,
                  radius: 52,
                  localImage: _imageFile,
                  localBytes: _webImageBytes,
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
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  ),
                ),
                if (_isUploadingPhoto)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyer pour changer la photo',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Votre rôle",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<UserRole>(
              value: _selectedRole,
              isExpanded: true,
              items: UserRole.values
                  .map((r) => DropdownMenuItem(
                value: r,
                child: Text(r.label),
              ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedRole = v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimated({required int index, required Widget child}) {
    return SlideTransition(
      position: _slideAnimations[index],
      child: FadeTransition(
        opacity: _fadeAnimations[index],
        child: child,
      ),
    );
  }
}
