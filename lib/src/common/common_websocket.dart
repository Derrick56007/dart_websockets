import 'dart:async';
import 'dart:convert';

abstract class CommonWebSocket {
  static const _typeIndex = 0;
  static const _messageIndex = 1;
  static const _defaultLength = 2;
  static const _two = 2;

  static const defaultRetrySeconds = 2;

  final _dispatchers = <String, void Function(dynamic data)>{};

  final _singleDispatchCompleters = <String, Completer>{};

  bool reconnectScheduled = false;

  Future done;

  Future start({int retrySeconds = defaultRetrySeconds});

  void scheduleReconnect(int retrySeconds) {
    if (!reconnectScheduled) {
      final newRetrySeconds = retrySeconds * _two;

      print('scheduling reconnect in $newRetrySeconds seconds');

      Timer(Duration(seconds: retrySeconds), () async => await start(retrySeconds: newRetrySeconds));
    }
    reconnectScheduled = true;
  }

  void on(String type, void Function(dynamic data) function) {
    if (_dispatchers.containsKey(type)) {
      print('Overriding dispatch $type');
    }

    _dispatchers[type] = function;
  }

  Future onSingleAsync(String type, void Function(dynamic data) function) {
    _singleDispatchCompleters[type] = Completer();

    void runOnceFunction(dynamic data) {
      // remove single dispatch

      _singleDispatchCompleters[type].complete();

      removeSingleDispatch(type);

      function(data);
    }

    on(type, runOnceFunction);

    return _singleDispatchCompleters[type].future;
  }

  void removeDispatch(String type) {
    // print('removing dispatch $type');
    _dispatchers.remove(type);
  }

  void removeSingleDispatch(String type) {
    removeDispatch(type);

    _singleDispatchCompleters.remove(type);
  }

  void send(String type, [message]);

  void onDecodedData(data) {
    if (data is List && data.length == _defaultLength) {
      // check if dispatch exists
      final type = data[_typeIndex];
      if (type == null) {
        print('No such dispatch exists!: $type');
        return;
      }
      final msg = data[_messageIndex];

      _dispatchers[type](msg);

      return;
    }

    if (data is String) {
      final type = data;

      // check if is command msg
      if (!_dispatchers.containsKey(type)) {
        print('No such dispatch exists!: $type');
        return;
      }
      _dispatchers[type]({});
      return;
    }

    print('No such dispatch exists!: $data');
  }

  void onData(d) => onDecodedData(jsonDecode(d));
}
