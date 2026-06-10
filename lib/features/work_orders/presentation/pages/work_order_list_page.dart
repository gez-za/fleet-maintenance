import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../providers/work_order_notifier.dart';
import '../widgets/work_order_card.dart';

class WorkOrderListPage extends ConsumerStatefulWidget {
  const WorkOrderListPage({super.key});

  @override
  ConsumerState<WorkOrderListPage> createState() => _WorkOrderListPageState();
}

class _WorkOrderListPageState extends ConsumerState<WorkOrderListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(workOrderProvider.notifier).fetchWorkOrders(page: 1);
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
      final state = ref.read(workOrderProvider);
      if (!state.isLoading && state.currentPage < state.totalPages) {
        ref.read(workOrderProvider.notifier).fetchWorkOrders(page: state.currentPage + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final woState = ref.watch(workOrderProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ordres de Travail'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(workOrderProvider.notifier).refresh(),
        child: _buildContent(woState),
      ),
    );
  }

  Widget _buildContent(WorkOrderState state) {
    if (state.isLoading && state.workOrders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.workOrders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
              const SizedBox(height: 16),
              Text(state.error!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.read(workOrderProvider.notifier).refresh(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.workOrders.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          const Center(
            child: Column(
              children: [
                Icon(Icons.assignment_outlined, size: 64, color: AppColors.textHint),
                SizedBox(height: 16),
                Text('Aucun ordre de travail en cours.', style: TextStyle(color: AppColors.textSecondary)),
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
      itemCount: state.workOrders.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < state.workOrders.length) {
          final wo = state.workOrders[index];
          return WorkOrderCard(
            workOrder: wo,
            onTap: () => Navigator.pushNamed(context, '/work-orders/detail', arguments: wo.id),
          );
        } else {
          return const Center(
            child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
