import 'dart:async';
import 'package:async/async.dart';

extension FutureExtension<T> on Future<T> {
  Future onSuccess(Function(T? data) f) async {
    return await then((value) => f(value));
  }
}