import 'dart:async';
import 'package:flutter/services.dart';

class SoundCode {
  Function(List<int>)? _callback;
  Function()? _error;
  static const MethodChannel _channel = const MethodChannel('com.cifrasoft.soundcode');

  static final SoundCode _singleton = SoundCode._internal();
  factory SoundCode() => _singleton;

  SoundCode._internal() {
    print("SoundCode Plugin");
    _channel.setMethodCallHandler((call) => receiveData(call));
  }

  setCallback({Function(List<int>)? callback}) {
    this._callback = callback;
  }

  setErrorCallback({Function()? error}) {
    this._error = error;
  }

  //to java
  Future<bool> requestPermission() async {
    final bool result = await _channel.invokeMethod('requestPermission');
    return result;
  }

  Future<String> start() async {
    final String result = await _channel.invokeMethod('start');
    return result;
  }

  Future<String> stop() async {
    final String result = await _channel.invokeMethod('stop');
    return result;
  }

  //from java
  Future<void> receiveData(MethodCall call) async {
    switch (call.method) {
      case "onDetectedId":
        print("onDetectedId ");
        var data = List<int>.from(call.arguments as List<dynamic>);
        _callback?.call(data);
        break;
      case "onAudioInitFailed":
        print("onAudioInitFailed ");
        _error?.call();
        break;
    }
  }
}
