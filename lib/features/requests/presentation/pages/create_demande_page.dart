import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/models/demande_enums.dart';
import '../../../vehicles/presentation/providers/vehicle_notifier.dart';
import '../../models/demande.dart';
import '../providers/demande_notifier.dart';

class CreateDemandePage extends ConsumerStatefulWidget {
  const CreateDemandePage({super.key});

  @override
  ConsumerState<CreateDemandePage> createState() => _CreateDemandePageState();
}

class _CreateDemandePageState extends ConsumerState<CreateDemandePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Base fields
  DemandeType _selectedType = DemandeType.CARBURANT;
  String? _selectedVehicleId;
  final _motifController = TextEditingController();
  DemandePriority _selectedPriority = DemandePriority.NORMALE;
  File? _justificatif;
  
  // Details fields (Fuel)
  final _kmController = TextEditingController();
  final _quantiteCarburantController = TextEditingController();
  String _typeCarburant = 'Diesel';
  
  // Details fields (Part)
  final _nomPieceController = TextEditingController();
  final _quantitePieceController = TextEditingController();
  final _montantEstimeController = TextEditingController();
  
  // Details fields (Maintenance)
  String _typeMaintenance = 'Vidange';
  final _garageController = TextEditingController();
  final _descriptionMaintenanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(vehicleProvider.notifier).fetchVehicles());
  }

  @override
  void dispose() {
    _motifController.dispose();
    _kmController.dispose();
    _quantiteCarburantController.dispose();
    _nomPieceController.dispose();
    _quantitePieceController.dispose();
    _montantEstimeController.dispose();
    _garageController.dispose();
    _descriptionMaintenanceController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _justificatif = File(pickedFile.path));
    }
  }

  Map<String, dynamic> _buildDetails() {
    switch (_selectedType) {
      case DemandeType.CARBURANT:
        return {
          'km_actuel': int.tryParse(_kmController.text),
          'quantite_estimee': double.tryParse(_quantiteCarburantController.text),
          'type_carburant': _typeCarburant,
        };
      case DemandeType.PIECE:
        return {
          'nom_piece': _nomPieceController.text,
          'quantite': int.tryParse(_quantitePieceController.text),
          'montant_estime': double.tryParse(_montantEstimeController.text),
        };
      case DemandeType.MAINTENANCE:
        return {
          'type_maintenance': _typeMaintenance,
          'garage': _garageController.text,
          'description': _descriptionMaintenanceController.text,
        };
      default:
        return {};
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final demande = Demande(
      id: '', // Will be set by backend
      type: _selectedType,
      vehicleId: _selectedVehicleId,
      motif: _motifController.text,
      priority: _selectedPriority,
      status: DemandeStatus.EN_ATTENTE,
      details: _buildDetails(),
      requesterId: '', // Will be set by backend
      createdAt: DateTime.now(),
    );

    final success = await ref.read(demandeProvider.notifier).createDemande(
      demande: demande,
      filePath: _justificatif?.path,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande envoyée avec succès'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleState = ref.watch(vehicleProvider);
    final demandeState = ref.watch(demandeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle Demande')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('INFORMATIONS GÉNÉRALES'),
              const SizedBox(height: 12),
              _buildTypeSelector(),
              const SizedBox(height: 16),
              _buildVehicleDropdown(vehicleState),
              const SizedBox(height: 16),
              TextFormField(
                controller: _motifController,
                decoration: const InputDecoration(labelText: 'Motif de la demande', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              _buildPrioritySelector(),
              const SizedBox(height: 24),
              
              _buildSectionTitle('DÉTAILS SPÉCIFIQUES'),
              const SizedBox(height: 12),
              _buildDynamicFields(),
              const SizedBox(height: 24),
              
              _buildSectionTitle('JUSTIFICATIF (OPTIONNEL)'),
              const SizedBox(height: 12),
              _buildFilePicker(),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: demandeState.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: demandeState.isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('SOUMETTRE LA DEMANDE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary));
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Type de demande'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: DemandeType.values.map((t) => ChoiceChip(
            label: Text(t.label),
            selected: _selectedType == t,
            onSelected: (val) { if (val) setState(() => _selectedType = t); },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Priorité'),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: DemandePriority.values.map((p) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(p.label, style: const TextStyle(fontSize: 10)),
                selected: _selectedPriority == p,
                selectedColor: p.color.withOpacity(0.2),
                onSelected: (val) { if (val) setState(() => _selectedPriority = p); },
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildVehicleDropdown(VehicleState state) {
    return DropdownButtonFormField<String>(
      value: _selectedVehicleId,
      decoration: const InputDecoration(labelText: 'Véhicule', border: OutlineInputBorder()),
      items: state.vehicles.map((v) => DropdownMenuItem(
        value: v.id,
        child: Text('${v.immatriculation} - ${v.marque} ${v.modele}'),
      )).toList(),
      onChanged: (v) => setState(() => _selectedVehicleId = v),
      validator: (v) => v == null ? 'Sélectionnez un véhicule' : null,
    );
  }

  Widget _buildDynamicFields() {
    switch (_selectedType) {
      case DemandeType.CARBURANT:
        return Column(
          children: [
            TextFormField(
              controller: _kmController,
              decoration: const InputDecoration(labelText: 'Kilométrage actuel', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantiteCarburantController,
              decoration: const InputDecoration(labelText: 'Quantité estimée (L)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _typeCarburant,
              decoration: const InputDecoration(labelText: 'Type de carburant', border: OutlineInputBorder()),
              items: ['Diesel', 'Essence', 'GPL'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _typeCarburant = v!),
            ),
          ],
        );
      case DemandeType.PIECE:
        return Column(
          children: [
            TextFormField(
              controller: _nomPieceController,
              decoration: const InputDecoration(labelText: 'Nom de la pièce', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantitePieceController,
              decoration: const InputDecoration(labelText: 'Quantité', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _montantEstimeController,
              decoration: const InputDecoration(labelText: 'Montant estimé', border: OutlineInputBorder(), prefixText: 'XAF '),
              keyboardType: TextInputType.number,
            ),
          ],
        );
      case DemandeType.MAINTENANCE:
        return Column(
          children: [
            DropdownButtonFormField<String>(
              value: _typeMaintenance,
              decoration: const InputDecoration(labelText: 'Type de maintenance', border: OutlineInputBorder()),
              items: ['Vidange', 'Pneumatique', 'Freinage', 'Batterie', 'Autre'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _typeMaintenance = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _garageController,
              decoration: const InputDecoration(labelText: 'Garage suggéré', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionMaintenanceController,
              decoration: const InputDecoration(labelText: 'Description des travaux', border: OutlineInputBorder()),
              maxLines: 3,
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildFilePicker() {
    return InkWell(
      onTap: _pickFile,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            const Icon(Icons.attach_file, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(_justificatif == null ? 'Joindre un fichier' : _justificatif!.path.split('/').last)),
            if (_justificatif != null) IconButton(onPressed: () => setState(() => _justificatif = null), icon: const Icon(Icons.close)),
          ],
        ),
      ),
    );
  }
}
