import '../services/config_user_service.dart';
import '../models/config_user.dart';

class ConfigUserRepository {
  final ConfigUserService service = ConfigUserService();

  Future<ConfigUser> getConfigUser() {
    return service.fetchConfigUser();
  }
}
