import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../models/vehicle.dart';
import '../providers/vehicle_notifier.dart';

class EditVehiclePage extends ConsumerStatefulWidget {
  final Vehicle vehicle;

  const EditVehiclePage({super.key, required this.vehicle});

  @override
  ConsumerState<EditVehiclePage> createState() => _EditVehiclePageState();
}

class _EditVehiclePageState extends ConsumerState<EditVehiclePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _marqueController;
  late final TextEditingController _modeleController;
  late final TextEditingController _immatriculationController;
  late final TextEditingController _anneeController;
  late final TextEditingController _numeroChassisController;
  late final TextEditingController _kmActuelController;

  late VehicleCategorie _selectedCategorie;
  late VehicleStatut    _selectedStatut;

  XFile? _newImageFile;        // nouvelle image choisie
  String? _existingImageUrl;   // image déjà enregistrée
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _marqueController          = TextEditingController(text: v.marque);
    _modeleController          = TextEditingController(text: v.modele);
    _immatriculationController = TextEditingController(text: v.immatriculation);
    _anneeController           = TextEditingController(text: v.annee.toString());
    _numeroChassisController   = TextEditingController(text: v.numeroChassis ?? '');
    _kmActuelController        = TextEditingController(text: v.kmActuel.toString());
    _selectedCategorie         = v.categorie;
    _selectedStatut            = v.statut;
    _existingImageUrl          = v.image;
  }

  @override
  void dispose() {
    _marqueController.dispose();
    _modeleController.dispose();
    _immatriculationController.dispose();
    _anneeController.dispose();
    _numeroChassisController.dispose();
    _kmActuelController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (selected != null) setState(() => _newImageFile = selected);
  }

  void _removeImage() {
    setState(() {
      _newImageFile     = null;
      _existingImageUrl = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'marque':          _marqueController.text.trim(),
      'modele':          _modeleController.text.trim(),
      'immatriculation': _immatriculationController.text.trim(),
      'annee':           int.tryParse(_anneeController.text.trim()) ?? 0,
      'numero_chassis':  _numeroChassisController.text.trim(),
      'categorie':       _selectedCategorie.name,
      'statut':          _selectedStatut.name,
      'km_actuel':       int.tryParse(_kmActuelController.text.trim()) ?? 0,
    };

    Uint8List? imageBytes;
    String?   imageName;
    if (_newImageFile != null) {
      imageBytes = await _newImageFile!.readAsBytes();
      imageName  = _newImageFile!.name;
    }

    final success = await ref.read(vehicleProvider.notifier).updateVehicle(
      widget.vehicle.id,
      data,
      imageBytes: imageBytes,
      imageName: imageName,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Véhicule mis à jour avec succès !'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context, true); // true = changements effectués
      } else {
        final error = ref.read(vehicleProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Erreur lors de la mise à jour'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(vehicleProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Modifier le véhicule'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
          child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        padding:
        const EdgeInsets.all(AppDimensions.paddingHorizontal),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Photo ───────────────────────────────────────────
              Center(child: _buildImagePicker()),
              const SizedBox(height: AppDimensions.space32),

              // ── Informations générales ──────────────────────────
              _buildSectionTitle('Informations Générales'),
              const SizedBox(height: AppDimensions.space16),

              _buildTextField(
                controller: _marqueController,
                label: 'Marque',
                hint: 'Ex : Toyota',
                validator: _required,
              ),
              const SizedBox(height: AppDimensions.space16),

              _buildTextField(
                controller: _modeleController,
                label: 'Modèle',
                hint: 'Ex : Hilux',
                validator: _required,
              ),
              const SizedBox(height: AppDimensions.space16),

              _buildTextField(
                controller: _immatriculationController,
                label: 'Immatriculation',
                hint: 'Ex : AA-123-BB',
                validator: _required,
              ),
              const SizedBox(height: AppDimensions.space16),

              _buildTextField(
                controller: _anneeController,
                label: 'Année',
                hint: 'Ex : 2022',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requis';
                  final n = int.tryParse(v);
                  if (n == null ||
                      n < 1900 ||
                      n > DateTime.now().year) {
                    return 'Année invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.space32),

              // ── Caractéristiques ────────────────────────────────
              _buildSectionTitle('Caractéristiques'),
              const SizedBox(height: AppDimensions.space16),

              _buildTextField(
                controller: _numeroChassisController,
                label: 'Numéro de châssis (VIN)',
                hint: "Numéro d'identification du véhicule",
              ),
              const SizedBox(height: AppDimensions.space16),

              _buildTextField(
                controller: _kmActuelController,
                label: 'Kilométrage actuel',
                hint: '0',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  if (int.tryParse(v) == null) {
                    return 'Valeur numérique requise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.space32),

              // ── Catégorie ───────────────────────────────────────
              _buildSectionTitle('Catégorie'),
              const SizedBox(height: AppDimensions.space16),

              DropdownButtonFormField<VehicleCategorie>(
                initialValue: _selectedCategorie,
                decoration: _inputDecoration('Catégorie du véhicule'),
                items: VehicleCategorie.values
                    .map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(cat.icon,
                          size: 18, color: cat.color),
                      const SizedBox(width: 8),
                      Text(cat.label),
                    ],
                  ),
                ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _selectedCategorie = v);
                  }
                },
                validator: (v) => v == null ? 'Requis' : null,
              ),
              const SizedBox(height: AppDimensions.space32),

              // ── Statut ──────────────────────────────────────────
              _buildSectionTitle('Statut'),
              const SizedBox(height: AppDimensions.space16),

              DropdownButtonFormField<VehicleStatut>(
                initialValue: _selectedStatut,
                decoration: _inputDecoration('Statut du véhicule'),
                items: VehicleStatut.values
                    .map((s) => DropdownMenuItem(
                  value: s,
                  child: Row(
                    children: [
                      Icon(s.icon, size: 18, color: s.color),
                      const SizedBox(width: 8),
                      Text(s.label),
                    ],
                  ),
                ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedStatut = v);
                },
              ),
              const SizedBox(height: AppDimensions.space48),

              // ── Bouton ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMedium),
                    ),
                  ),
                  child: const Text(
                    'ENREGISTRER LES MODIFICATIONS',
                    style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: AppDimensions.fontMD),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widget image avec prévisualisation + suppression ─────────────────────
  Widget _buildImagePicker() {
    final bool hasNew      = _newImageFile != null;
    final bool hasExisting = _existingImageUrl != null &&
        _existingImageUrl!.isNotEmpty;
    final bool hasImage    = hasNew || hasExisting;

    return Stack(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
              BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: AppColors.border),
              boxShadow: [AppColors.cardShadow],
            ),
            child: hasImage
                ? ClipRRect(
              borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMedium),
              child: hasNew
                  ? (kIsWeb
                  ? Image.network(_newImageFile!.path,
                  fit: BoxFit.cover)
                  : Image.file(File(_newImageFile!.path),
                  fit: BoxFit.cover))
                  : Image.network(_existingImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _photoPlaceholder()),
            )
                : _photoPlaceholder(),
          ),
        ),
        // Bouton supprimer l'image
        if (hasImage)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: _removeImage,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close,
                    size: 16, color: Colors.white),
              ),
            ),
          ),
        // Bouton changer l'image
        Positioned(
          bottom: 4,
          right: 4,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt,
                  size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _photoPlaceholder() => const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.camera_alt_outlined,
          color: AppColors.textHint, size: 40),
      SizedBox(height: 8),
      Text('Photo',
          style: TextStyle(color: AppColors.textHint)),
    ],
  );

  // ── Helpers ───────────────────────────────────────────────────────────────

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Requis' : null;

  Widget _buildSectionTitle(String title) => Text(
    title.toUpperCase(),
    style: const TextStyle(
      fontSize: AppDimensions.fontXS,
      fontWeight: FontWeight.bold,
      color: AppColors.textSecondary,
      letterSpacing: 1.2,
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: _inputDecoration(label, hint: hint),
      );

  InputDecoration _inputDecoration(String label, {String? hint}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space12,
        ),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide:
          const BorderSide(color: AppColors.primary, width: 2),
        ),
      );
}