import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceStorageService {
  static Future<void> save<T>(String key, T data) => const FlutterSecureStorage().write(key: key, value: json.encode(data));

  static Future<T?> read<T>(String key, Function fromJson) {
    return const FlutterSecureStorage().read(key: key).then((value) => value != null ? fromJson(json.decode(value)) : null);
  }

  static Future<void> delete(String key) async => await const FlutterSecureStorage().delete(key: key);
}
