import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/models/user.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../vehicles/presentation/providers/vehicle_notifier.dart';
import '../providers/fault_notifier.dart';
import '../widgets/fault_card.dart';

class FaultListPage extends ConsumerStatefulWidget {
  const FaultListPage({super.key});

  @override
  ConsumerState<FaultListPage> createState() => _FaultListPageState();
}

class _FaultListPageState extends ConsumerState<FaultListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(faultProvider.notifier).fetchFaults(page: 1);
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      final state = ref.read(faultProvider);
      if (!state.isLoading && state.currentPage < state.totalPages) {
        ref.read(faultProvider.notifier).fetchFaults(page: state.currentPage + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final faultState = ref.watch(faultProvider);
    final user = ref.watch(authProvider).user;

    // Si c'est un chauffeur, on écoute le chargement de son véhicule pour déclencher le fetch des pannes
    if (user?.role == UserRole.CHAUFFEUR) {
      ref.listen(myVehicleProvider, (previous, next) {
        if (previous == null && next != null) {
          ref.read(faultProvider.notifier).fetchFaults(page: 1, vehicleId: next.id);
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(faultProvider.notifier).refresh(),
        child: _buildContent(faultState),
      ),
      floatingActionButton: _buildFAB(user),
    );
  }

  Widget _buildContent(FaultState state) {
    if (state.isLoading && state.faults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.faults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 64, color: AppColors.danger),
              const SizedBox(height: 16),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.read(faultProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.faults.isEmpty) {
      return ListView( // Pour permettre le pull-to-refresh même si vide
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          const Center(
            child: Column(
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Aucune panne déclarée.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppDimensions.space16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.faults.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < state.faults.length) {
          final fault = state.faults[index];
          return FaultCard(
            fault: fault,
            onTap: () => Navigator.pushNamed(
              context, 
              '/faults/detail', 
              arguments: fault.id,
            ),
          );
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget? _buildFAB(User? user) {
    if (user == null) return null;
    
    // Uniquement Chauffeur, Admin ou Chef d'atelier peuvent déclarer
    if (user.role == UserRole.CHAUFFEUR || 
        user.role == UserRole.ADMIN || 
        user.role == UserRole.CHEF_ATELIER) {
      return FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/faults/declare'),
        label: const Text('Déclarer une panne'),
        icon: const Icon(Icons.add_photo_alternate_outlined),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      );
    }
    return null;
  }
}
