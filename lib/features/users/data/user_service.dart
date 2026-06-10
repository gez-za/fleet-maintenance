import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/models/user.dart';
import '../../../../core/services/api_service.dart';

class UserService {
  final ApiService _api;

  UserService(this._api);

  /// Liste tous les utilisateurs
  Future<List<User>> getUsers() async {
    try {
      final response = await _api.get(ApiEndpoints.users);
      final dynamic rawData = response.data['data'];
      
      List<dynamic> usersList = [];
      
      if (rawData is List) {
        usersList = rawData;
      } else if (rawData is Map && rawData['users'] is List) {
        usersList = rawData['users'];
      } else if (response.data is List) {
        usersList = response.data;
      }

      return usersList.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Récupère un utilisateur par son UUID
  Future<User> getUserById(String uuid) async {
    try {
      final response = await _api.get('${ApiEndpoints.users}/$uuid');
      return User.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Ajoute un nouvel utilisateur (généralement via register mais peut être direct pour l'admin)
  Future<User> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _api.post(ApiEndpoints.users, data: userData);
      return User.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Met à jour un utilisateur
  Future<User> updateUser(String uuid, Map<String, dynamic> userData) async {
    try {
      final response = await _api.put('${ApiEndpoints.users}/$uuid', data: userData);
      return User.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Supprime un utilisateur
  Future<void> deleteUser(String uuid) async {
    try {
      await _api.delete('${ApiEndpoints.users}/$uuid');
    } catch (e) {
      rethrow;
    }
  }
}
