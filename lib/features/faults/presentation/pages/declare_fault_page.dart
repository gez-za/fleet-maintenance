import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/models/maintenance_enums.dart';
import '../../../../core/services/location_service.dart';
import '../../../vehicles/presentation/providers/vehicle_notifier.dart';
import '../providers/fault_notifier.dart';

class DeclareFaultPage extends ConsumerStatefulWidget {
  const DeclareFaultPage({super.key});

  @override
  ConsumerState<DeclareFaultPage> createState() => _DeclareFaultPageState();
}

class _DeclareFaultPageState extends ConsumerState<DeclareFaultPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedVehicleId;
  final _descriptionController = TextEditingController();
  PanneCriticite _criticality = PanneCriticite.MINEURE;
  File? _image;
  final _picker = ImagePicker();

  // Location state
  double? _latitude;
  double? _longitude;
  String? _address;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(vehicleProvider.notifier).fetchVehicles();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection de l\'image : $e')),
      );
    }
  }

  Future<void> _getLocation() async {
    setState(() => _isLocating = true);
    try {
      final position = await LocationService.getCurrentLocation();
      final address = await LocationService.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _address = address;
        _isLocating = false;
      });
    } catch (e) {
      setState(() => _isLocating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de localisation : $e')),
        );
      }
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedVehicleId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner un véhicule')),
        );
        return;
      }

      final success = await ref.read(faultProvider.notifier).createFault(
        vehicleId: _selectedVehicleId!,
        description: _descriptionController.text,
        criticality: _criticality.name,
        photoPath: _image?.path,
        latitude: _latitude,
        longitude: _longitude,
        addressApprox: _address,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Panne déclarée avec succès'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        final error = ref.read(faultProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Erreur lors de la déclaration'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleState = ref.watch(vehicleProvider);
    final faultState = ref.watch(faultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Déclarer une Panne'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Selection
              const Text('VÉHICULE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              _buildVehicleDropdown(vehicleState),
              const SizedBox(height: 20),

              // Description
              const Text('DESCRIPTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Décrivez le problème constaté...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty ? 'La description est requise' : null,
              ),
              const SizedBox(height: 20),

              // Location Section
              const Text('LOCALISATION DU VÉHICULE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              _buildLocationSection(),
              const SizedBox(height: 20),

              // Criticality
              const Text('CRITICITÉ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              _buildCriticalitySelector(),
              const SizedBox(height: 20),

              // Photo Picker
              const Text('PHOTO DU PROBLÈME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              _buildImagePicker(),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: faultState.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                    elevation: 2,
                  ),
                  child: faultState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ENVOYER LA DÉCLARATION', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (_address != null) ...[
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _address!,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Lat: ${_latitude?.toStringAsFixed(6)}, Long: ${_longitude?.toStringAsFixed(6)}",
              style: const TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
            const Divider(height: 24),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLocating ? null : _getLocation,
              icon: _isLocating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(_isLocating ? 'RECHERCHE...' : (_address == null ? 'OBTENIR MA POSITION' : 'METTRE À JOUR LA POSITION')),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSmall)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDropdown(VehicleState state) {
    if (state.isLoading && state.vehicles.isEmpty) {
      return const LinearProgressIndicator();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedVehicleId,
          hint: const Text('Sélectionnez un véhicule'),
          isExpanded: true,
          onChanged: (value) => setState(() => _selectedVehicleId = value),
          items: state.vehicles.map((v) {
            return DropdownMenuItem(
              value: v.id,
              child: Text('${v.immatriculation} - ${v.marque} ${v.modele}'),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCriticalitySelector() {
    return Row(
      children: PanneCriticite.values.map((c) {
        final isSelected = _criticality == c;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(c.label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _criticality = c);
              },
              selectedColor: c.color.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? c.color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                side: BorderSide(color: isSelected ? c.color : AppColors.border),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () => _showImageSourceActionSheet(),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: _image != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    child: Image.file(_image!, width: double.infinity, height: 180, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() => _image = null),
                      ),
                    ),
                  ),
                ],
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 48, color: AppColors.textHint),
                  SizedBox(height: 8),
                  Text('Prendre une photo', style: TextStyle(color: AppColors.textHint)),
                ],
              ),
      ),
    );
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Appareil photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
