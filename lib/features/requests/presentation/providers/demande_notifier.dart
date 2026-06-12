import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/services/demande_service.dart';
import '../../models/demande.dart';

class DemandeState {
  final bool isLoading;
  final List<Demande> demandes;
  final List<Depense> depenses;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final String? error;
  final Map<String, dynamic>? stats;

  DemandeState({
    this.isLoading = false,
    this.demandes = const [],
    this.depenses = const [],
    this.totalItems = 0,
    this.currentPage = 1,
    this.totalPages = 1,
    this.error,
    this.stats,
  });

  DemandeState copyWith({
    bool? isLoading,
    List<Demande>? demandes,
    List<Depense>? depenses,
    int? totalItems,
    int? currentPage,
    int? totalPages,
    String? error,
    bool clearError = false,
    Map<String, dynamic>? stats,
  }) {
    return DemandeState(
      isLoading: isLoading ?? this.isLoading,
      demandes: demandes ?? this.demandes,
      depenses: depenses ?? this.depenses,
      totalItems: totalItems ?? this.totalItems,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      error: clearError ? null : (error ?? this.error),
      stats: stats ?? this.stats,
    );
  }
}

final demandeServiceProvider = Provider((ref) {
  final api = ref.watch(apiServiceProvider);
  return DemandeService(api);
});

final demandeProvider = NotifierProvider<DemandeNotifier, DemandeState>(() {
  return DemandeNotifier();
});

class DemandeNotifier extends Notifier<DemandeState> {
  @override
  DemandeState build() => DemandeState();

  Future<void> fetchDemandes({
    int page = 1, 
    String? status, 
    String? type,
    String? priority,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await ref.read(demandeServiceProvider).getDemandes(
        page: page, 
        status: status,
        type: type,
        priority: priority,
      );
      final List<dynamic> itemsJson = data['items'] ?? [];
      final List<Demande> items = itemsJson.map((j) => Demande.fromJson(j)).toList();
      
      final pagination = data['pagination'];
      
      state = state.copyWith(
        isLoading: false,
        demandes: page == 1 ? items : [...state.demandes, ...items],
        totalItems: pagination?['total'] ?? items.length,
        currentPage: pagination?['page'] ?? page,
        totalPages: pagination?['totalPages'] ?? 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createDemande({
    required Demande demande,
    String? filePath,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(demandeServiceProvider).createDemande(
        demande: demande,
        filePath: filePath,
      );
      await fetchDemandes(page: 1);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> processAction(String id, {
    required String status,
    String? rejectionReason,
    String? bonNumber,
    double? quantityGranted,
    DateTime? bonDate,
    DateTime? bonExpiryDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(demandeServiceProvider).processAction(
        id, 
        status: status,
        rejectionReason: rejectionReason,
        bonNumber: bonNumber,
        quantityGranted: quantityGranted,
        bonDate: bonDate,
        bonExpiryDate: bonExpiryDate,
      );
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> fetchDemandeDetail(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final demande = await ref.read(demandeServiceProvider).getDemandeById(id);
      final index = state.demandes.indexWhere((d) => d.id == id);
      if (index != -1) {
        final newDemandes = [...state.demandes];
        newDemandes[index] = demande;
        state = state.copyWith(isLoading: false, demandes: newDemandes);
      } else {
        state = state.copyWith(isLoading: false, demandes: [...state.demandes, demande]);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchDepenses({int page = 1}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await ref.read(demandeServiceProvider).getDepenses(page: page);
      final List<dynamic> itemsJson = data['items'] ?? [];
      final List<Depense> items = itemsJson.map((j) => Depense.fromJson(j)).toList();
      
      state = state.copyWith(
        isLoading: false,
        depenses: page == 1 ? items : [...state.depenses, ...items],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchStats() async {
    try {
      final stats = await ref.read(demandeServiceProvider).getStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      // Ignorer l'erreur pour les stats
    }
  }

  Future<bool> createDepense({
    required String label,
    required double amount,
    String? vehicleId,
    String? demandeId,
    String? filePath,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(demandeServiceProvider).createDepense(
        label: label,
        amount: amount,
        vehicleId: vehicleId,
        demandeId: demandeId,
        filePath: filePath,
      );
      await fetchDepenses(page: 1);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> refresh() async => fetchDemandes(page: 1);
}
