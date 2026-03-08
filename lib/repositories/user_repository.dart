import '../services/user_service.dart';
import '../models/user.dart';

class UserRepository {
  final UserService service = UserService();

  Future<User> getUser() {
    return service.fetchUser();
  }
}
