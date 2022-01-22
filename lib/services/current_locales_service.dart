import 'package:yaml/yaml.dart';

class CurrentLocalesService {
  final YamlMap _yamlMap;

  CurrentLocalesService(this._yamlMap);

  get _screens => _yamlMap['screens'];
  get camera_screen => _screens['camera_screen'];
  get login_screen => _screens['login_screen'];
  get photo_preview_screen => _screens['photo_preview_screen'];
  get photos_preview_screen => _screens['photos_preview_screen'];
}