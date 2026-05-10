import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../auth/auth_service.dart';
import 'dashboard_models.dart';

class DashboardNotifier extends StateNotifier<DashboardState> {
  final ApiClient _api;
  final Ref _ref;

  DashboardNotifier(this._api, this._ref) : super(const DashboardState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _ref.read(authStateProvider);
      if (user == null) {
        state = state.copyWith(isLoading: false, error: 'Utilisateur non connecté');
        return;
      }

      // 1. Fetch Plots
      final plotsResponse = await _api.get('plots/my');
      final List<Plot> plots = (plotsResponse.data as List)
          .map((p) => Plot.fromJson(p))
          .toList();

      // 2. Fetch Active Alerts count
      final alertsResponse = await _api.get('alerts/active');
      final int activeAlerts = (alertsResponse.data as List).length;

      // 3. Fetch Pending Orders count
      final ordersResponse = await _api.get('orders/user/${user.id}');
      final int pendingOrders = (ordersResponse.data as List)
          .where((o) => o['status'] == 'PENDING')
          .length;

      final stats = DashboardStats(
        totalPlots: plots.length,
        healthyPlots: plots.where((p) => p.status == 'healthy').length,
        activeAlerts: activeAlerts,
        pendingOrders: pendingOrders,
      );

      state = state.copyWith(
        isLoading: false,
        plots: plots,
        stats: stats,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement des données: $e',
      );
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final api = ref.watch(apiClientProvider);
  return DashboardNotifier(api, ref);
});
