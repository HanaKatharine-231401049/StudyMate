import 'package:flutter/services.dart';

class FocusDndService {
  static const MethodChannel _channel =
      MethodChannel('focus_dnd');

  static Future<bool> hasPermission() async {
    return await _channel.invokeMethod('hasPermission');
  }

  static Future<void> enable() async {
    await _channel.invokeMethod('enableDnd');
  }

  static Future<void> disable() async {
    await _channel.invokeMethod('disableDnd');
  }
}