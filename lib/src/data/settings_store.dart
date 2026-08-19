import '../domain/app_settings.dart';

abstract interface class SettingsStore {
  Future<AppSettings> load();

  Future<void> save(AppSettings settings);

  Future<void> reset();
}
