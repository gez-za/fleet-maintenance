import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fleet_maintenance_app/features/inventory/models/material.dart';
import 'package:fleet_maintenance_app/features/inventory/models/stock_movement.dart';
import 'package:fleet_maintenance_app/features/inventory/presentation/providers/inventory_providers.dart';

class StockMovementScreen extends ConsumerStatefulWidget {
  final MaterialModel material;

  const StockMovementScreen({super.key, required this.material});

  @override
  ConsumerState<StockMovementScreen> createState() => _StockMovementScreenState();
}

class _StockMovementScreenState extends ConsumerState<StockMovementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantiteController = TextEditingController();
  final _motifController = TextEditingController();
  final _otController = TextEditingController();
  MovementType _selectedType = MovementType.SORTIE;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _quantiteController.dispose();
    _motifController.dispose();
    _otController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final movement = StockMovement(
        id: '',
        materielId: widget.material.id,
        type: _selectedType,
        quantite: double.parse(_quantiteController.text),
        motif: _motifController.text,
        otId: _otController.text.isNotEmpty ? _otController.text : null,
        createdAt: DateTime.now(),
      );

      await ref.read(movementsHistoryProvider.notifier).createMovement(movement);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mouvement enregistré avec succès'), backgroundColor: Colors.green),
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
        title: const Text('Enregistrer un mouvement'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D2939),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMaterialInfo(),
              const SizedBox(height: 24),
              const Text('Type de mouvement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _buildTypeSelector(),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _quantiteController,
                label: 'Quantité',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.add_chart,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requis';
                  if (double.tryParse(v) == null) return 'Nombre invalide';
                  if (double.parse(v) <= 0) return 'Doit être positif';
                  if (_selectedType == MovementType.SORTIE && double.parse(v) > widget.material.quantiteStock) {
                    return 'Stock insuffisant (${widget.material.quantiteStock} disponible)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _motifController,
                label: 'Motif / Description',
                prefixIcon: Icons.notes,
                validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _otController,
                label: 'ID Ordre de Travail (Optionnel)',
                prefixIcon: Icons.assignment_outlined,
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
                    : const Text('Enregistrer le mouvement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2, color: Color(0xFF1565C0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.material.designation, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Réf: ${widget.material.reference} • Stock: ${widget.material.quantiteStock}', style: const TextStyle(fontSize: 12, color: Color(0xFF667085))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        _buildTypeCard(MovementType.SORTIE, 'Sortie', Colors.orange, Icons.remove_circle_outline),
        const SizedBox(width: 12),
        _buildTypeCard(MovementType.ENTREE, 'Entrée', Colors.green, Icons.add_circle_outline),
        const SizedBox(width: 12),
        _buildTypeCard(MovementType.AJUSTEMENT, 'Ajustement', Colors.blue, Icons.swap_horiz),
      ],
    );
  }

  Widget _buildTypeCard(MovementType type, String label, Color color, IconData icon) {
    final bool isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : const Color(0xFFEAECF0), width: 2),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : const Color(0xFF667085)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : const Color(0xFF667085),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
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
    TextInputType? keyboardType,
    IconData? prefixIcon,
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
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF667085), size: 20) : null,
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
