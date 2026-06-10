import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/models/demande_enums.dart';
import '../providers/demande_notifier.dart';
import '../widgets/demande_card.dart';

class DemandesPage extends ConsumerStatefulWidget {
  const DemandesPage({super.key});

  @override
  ConsumerState<DemandesPage> createState() => _DemandesPageState();
}

class _DemandesPageState extends ConsumerState<DemandesPage> {
  final ScrollController _scrollController = ScrollController();
  DemandeStatus? _filterStatus;
  DemandeType? _filterType;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(demandeProvider.notifier).fetchDemandes());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      final state = ref.read(demandeProvider);
      if (!state.isLoading && state.currentPage < state.totalPages) {
        ref.read(demandeProvider.notifier).fetchDemandes(page: state.currentPage + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(demandeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Demandes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(demandeProvider.notifier).refresh(),
        child: _buildContent(state),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/demandes/create'),
        label: const Text('Nouvelle demande'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildContent(DemandeState state) {
    if (state.isLoading && state.demandes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.demandes.isEmpty) {
      return const Center(child: Text('Aucune demande trouvée.'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.demandes.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < state.demandes.length) {
          final demande = state.demandes[index];
          return DemandeCard(
            demande: demande,
            onTap: () => Navigator.pushNamed(context, '/demandes/details', arguments: demande),
          );
        } else {
          return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
        }
      },
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filtrer par Statut', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: DemandeStatus.values.map((s) => ChoiceChip(
                  label: Text(s.label),
                  selected: _filterStatus == s,
                  onSelected: (val) {
                    setState(() => _filterStatus = val ? s : null);
                    setModalState(() {});
                  },
                )).toList(),
              ),
              const SizedBox(height: 24),
              const Text('Filtrer par Type', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: DemandeType.values.map((t) => ChoiceChip(
                  label: Text(t.label),
                  selected: _filterType == t,
                  onSelected: (val) {
                    setState(() => _filterType = val ? t : null);
                    setModalState(() {});
                  },
                )).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(demandeProvider.notifier).fetchDemandes(
                      status: _filterStatus?.name,
                      type: _filterType?.name,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('APPLIQUER'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
