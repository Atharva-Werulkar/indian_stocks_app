import '../providers/settings_provider.dart';

class ApiKeyService {
  static final ApiKeyService _instance = ApiKeyService._internal();
  factory ApiKeyService() => _instance;
  ApiKeyService._internal();

  SettingsProvider? _settingsProvider;

  void setSettingsProvider(SettingsProvider settingsProvider) {
    _settingsProvider = settingsProvider;
  }

  String? getCurrentApiKey() {
    return _settingsProvider?.currentApiKey;
  }

  bool get hasCustomApiKey => _settingsProvider?.useCustomApiKey ?? false;
}
