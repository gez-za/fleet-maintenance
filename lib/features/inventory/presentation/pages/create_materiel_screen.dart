import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fleet_maintenance_app/features/inventory/models/material.dart';
import 'package:fleet_maintenance_app/features/inventory/presentation/providers/inventory_providers.dart';

class CreateMaterielScreen extends ConsumerStatefulWidget {
  const CreateMaterielScreen({super.key});

  @override
  ConsumerState<CreateMaterielScreen> createState() => _CreateMaterielScreenState();
}

class _CreateMaterielScreenState extends ConsumerState<CreateMaterielScreen> {
  final _formKey = GlobalKey<FormState>();
  final _refController = TextEditingController();
  final _designationController = TextEditingController();
  final _categorieController = TextEditingController();
  final _stockController = TextEditingController();
  final _seuilController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _refController.dispose();
    _designationController.dispose();
    _categorieController.dispose();
    _stockController.dispose();
    _seuilController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final material = MaterialModel(
        id: '',
        reference: _refController.text,
        designation: _designationController.text,
        categorie: _categorieController.text,
        quantiteStock: double.parse(_stockController.text),
        seuilAlerte: double.parse(_seuilController.text),
      );

      await ref.read(materielsProvider.notifier).createMaterial(material);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Matériel créé avec succès'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nouveau Matériel'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D2939),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _refController,
                label: 'Référence',
                hint: 'Ex: FIL-HUI-001',
                validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _designationController,
                label: 'Désignation',
                hint: 'Ex: Filtre à huile Toyota',
                validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _categorieController,
                label: 'Catégorie',
                hint: 'Ex: Pièces détachées',
                validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _stockController,
                      label: 'Stock Initial',
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _seuilController,
                      label: 'Seuil Alerte',
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Créer le matériel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF344054))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
