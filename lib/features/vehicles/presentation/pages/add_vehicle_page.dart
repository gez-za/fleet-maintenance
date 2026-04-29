import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../models/vehicle.dart';
import '../providers/vehicle_notifier.dart';

class AddVehiclePage extends ConsumerStatefulWidget {
  const AddVehiclePage({super.key});

  @override
  ConsumerState<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends ConsumerState<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();

  final _marqueController          = TextEditingController();
  final _modeleController          = TextEditingController();
  final _immatriculationController = TextEditingController();
  final _anneeController           = TextEditingController();
  final _numeroChassisController   = TextEditingController();
  final _kmActuelController        = TextEditingController();

  VehicleCategorie _selectedCategorie = VehicleCategorie.SERVICE;
  VehicleStatut    _selectedStatut    = VehicleStatut.DISPONIBLE;

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

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
    if (selected != null) setState(() => _imageFile = selected);
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
    if (_imageFile != null) imageBytes = await _imageFile!.readAsBytes();

    final success = await ref.read(vehicleProvider.notifier).createVehicle(
      data,
      imageBytes: imageBytes,
      imageName: _imageFile?.name,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Véhicule ajouté avec succès !'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      } else {
        final error = ref.read(vehicleProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Erreur lors de l\'ajout'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(vehicleProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ajouter un véhicule'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingHorizontal),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Photo ─────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMedium),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [AppColors.cardShadow],
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMedium),
                      child: kIsWeb
                          ? Image.network(_imageFile!.path,
                          fit: BoxFit.cover)
                          : Image.file(File(_imageFile!.path),
                          fit: BoxFit.cover),
                    )
                        : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined,
                            color: AppColors.textHint, size: 40),
                        SizedBox(height: 8),
                        Text('Photo',
                            style: TextStyle(
                                color: AppColors.textHint)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space32),

              // ── Informations générales ─────────────────────────
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
                  if (n == null || n < 1900 || n > DateTime.now().year) {
                    return 'Année invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.space32),

              // ── Caractéristiques ───────────────────────────────
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

              // ── Catégorie ──────────────────────────────────────
              _buildSectionTitle('Catégorie'),
              const SizedBox(height: AppDimensions.space16),

              // ✅ initialValue remplace value: (déprécié >= Flutter 3.33)
              DropdownButtonFormField<VehicleCategorie>(
                initialValue: _selectedCategorie,
                decoration: _inputDecoration('Catégorie du véhicule'),
                items: VehicleCategorie.values
                    .map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(cat.icon, size: 18, color: cat.color),
                      const SizedBox(width: 8),
                      Text(cat.label),
                    ],
                  ),
                ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategorie = v);
                },
                validator: (v) => v == null ? 'Requis' : null,
              ),
              const SizedBox(height: AppDimensions.space32),

              // ── Statut initial ─────────────────────────────────
              _buildSectionTitle('Statut initial'),
              const SizedBox(height: AppDimensions.space16),

              // ✅ initialValue remplace value: (déprécié >= Flutter 3.33)
              DropdownButtonFormField<VehicleStatut>(
                initialValue: _selectedStatut,
                decoration: _inputDecoration('Statut'),
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

              // ── Bouton ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMedium),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'AJOUTER LE VÉHICULE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppDimensions.fontMD,
                    ),
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

  // ── Helpers ───────────────────────────────────────────────────────────────

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Requis' : null;

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: AppDimensions.fontXS,
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(label, hint: hint),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}