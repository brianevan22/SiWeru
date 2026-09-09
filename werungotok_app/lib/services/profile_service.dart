import '../core/api_client.dart';
import '../models/user_model.dart';

class ProfileService {
  final ApiClient client;
  ProfileService(this.client);

  Future<UserModel> show() async {
    final res = await client.get('/profile');
    return UserModel.fromJson(res['user']);
  }

  Future<UserModel> updateWa(String wa) async {
    final res = await client.put('/profile', body: {'wa': wa});
    return UserModel.fromJson(res['user']);
  }
}
