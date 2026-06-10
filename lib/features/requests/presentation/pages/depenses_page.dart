import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../vehicles/presentation/providers/vehicle_notifier.dart';
import '../providers/demande_notifier.dart';

class DepensesPage extends ConsumerStatefulWidget {
  const DepensesPage({super.key});

  @override
  ConsumerState<DepensesPage> createState() => _DepensesPageState();
}

class _DepensesPageState extends ConsumerState<DepensesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(demandeProvider.notifier).fetchDepenses();
      ref.read(vehicleProvider.notifier).fetchVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demandeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Dépenses')),
      body: _buildContent(state),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDepenseDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(DemandeState state) {
    if (state.isLoading && state.depenses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.depenses.isEmpty) {
      return const Center(child: Text('Aucune dépense enregistrée.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.depenses.length,
      itemBuilder: (context, index) {
        final depense = state.depenses[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary),
            ),
            title: Text(depense.label, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${DateFormat('dd/MM/yyyy').format(depense.date)} - ${depense.vehicle?.immatriculation ?? 'N/A'}'),
            trailing: Text(
              '${depense.amount.toStringAsFixed(0)} XAF',
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  void _showAddDepenseDialog() {
    final labelController = TextEditingController();
    final amountController = TextEditingController();
    String? selectedVehicleId;
    File? justificatif;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nouvelle Dépense', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: labelController, decoration: const InputDecoration(labelText: 'Libellé', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Montant', border: OutlineInputBorder(), prefixText: 'XAF '), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildVehicleDropdownInDialog((val) => setModalState(() => selectedVehicleId = val), selectedVehicleId),
              const SizedBox(height: 12),
              _buildJustificatifPickerInDialog(() async {
                final picker = ImagePicker();
                final picked = await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) setModalState(() => justificatif = File(picked.path));
              }, justificatif),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (labelController.text.isEmpty || amountController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez remplir les champs obligatoires')),
                      );
                      return;
                    }

                    final success = await ref.read(demandeProvider.notifier).createDepense(
                      label: labelController.text,
                      amount: double.tryParse(amountController.text) ?? 0,
                      vehicleId: selectedVehicleId,
                      filePath: justificatif?.path,
                    );

                    if (success && mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dépense enregistrée'), backgroundColor: Colors.green),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('ENREGISTRER'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleDropdownInDialog(Function(String?) onChanged, String? value) {
    final vehicles = ref.read(vehicleProvider).vehicles;
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(labelText: 'Véhicule (Optionnel)', border: OutlineInputBorder()),
      items: vehicles.map((v) => DropdownMenuItem(value: v.id, child: Text(v.immatriculation))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildJustificatifPickerInDialog(VoidCallback onTap, File? file) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            const Icon(Icons.camera_alt, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(file == null ? 'Justificatif' : 'Fichier sélectionné'),
          ],
        ),
      ),
    );
  }
}
