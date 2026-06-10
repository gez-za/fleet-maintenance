import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/user_service.dart';
import '../../../../core/models/user.dart';

final userServiceProvider = Provider((ref) {
  final api = ref.watch(apiServiceProvider);
  return UserService(api);
});

class UserListState {
  final List<User> users;
  final bool isLoading;
  final String? error;

  UserListState({this.users = const [], this.isLoading = false, this.error});

  UserListState copyWith({List<User>? users, bool? isLoading, String? error}) {
    return UserListState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserNotifier extends StateNotifier<UserListState> {
  final UserService _service;

  UserNotifier(this._service) : super(UserListState()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final users = await _service.getUsers();
      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteUser(String uuid) async {
    try {
      await _service.deleteUser(uuid);
      state = state.copyWith(
        users: state.users.where((u) => u.uuid != uuid).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final userListProvider = StateNotifierProvider<UserNotifier, UserListState>((ref) {
  final service = ref.watch(userServiceProvider);
  return UserNotifier(service);
});
