import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/models/user.dart';
import '../../../faults/models/fault.dart';
import '../../../users/presentation/providers/user_notifier.dart';
import '../providers/work_order_notifier.dart';

class CreateWorkOrderPage extends ConsumerStatefulWidget {
  final Fault fault;

  const CreateWorkOrderPage({super.key, required this.fault});

  @override
  ConsumerState<CreateWorkOrderPage> createState() => _CreateWorkOrderPageState();
}

class _CreateWorkOrderPageState extends ConsumerState<CreateWorkOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String? _selectedTechnicianId;
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _descriptionController.text = 'Réparation pour : ${widget.fault.description}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() => _startDate = picked);
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedTechnicianId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez assigner un technicien')),
        );
        return;
      }

      final success = await ref.read(workOrderProvider.notifier).createWorkOrder(
        faultId: widget.fault.id,
        description: _descriptionController.text,
        technicianId: _selectedTechnicianId!,
        startDate: _startDate,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ordre de travail créé avec succès'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userListProvider);
    final technicians = userState.users.where((u) => u.role == UserRole.TECHNICIEN || u.role == UserRole.CHEF_ATELIER).toList();
    final woState = ref.watch(workOrderProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Créer un OT'),
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
              _buildFaultSummary(),
              const SizedBox(height: 24),

              const Text('DESCRIPTION DE L\'INTERVENTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'La description est requise' : null,
              ),
              const SizedBox(height: 20),

              const Text('ASSIGNATION TECHNICIEN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              _buildTechnicianDropdown(technicians),
              const SizedBox(height: 20),

              const Text('DATE DE DÉBUT PRÉVUE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              _buildDatePicker(),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: woState.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                  ),
                  child: woState.isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('CONFIRMER LA CRÉATION', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaultSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PANNE : ${widget.fault.vehicle?.immatriculation ?? "Inconnu"}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                Text(
                  widget.fault.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianDropdown(List<User> technicians) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTechnicianId,
          hint: const Text('Sélectionner un technicien'),
          isExpanded: true,
          items: technicians.map((u) {
            return DropdownMenuItem(
              value: u.uuid,
              child: Text(u.displayName),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedTechnicianId = val),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              DateFormat('dd MMMM yyyy').format(_startDate),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            const Text('Modifier', style: TextStyle(color: AppColors.primary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
