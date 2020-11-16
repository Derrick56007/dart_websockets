import 'dart:async';
import 'dart:convert';

abstract class CommonWebSocket {
  static const typeIndex = 0;
  static const messageIndex = 1;
  static const defaultLength = 2;
  static const defaultRetrySeconds = 2;
  static const two = 2;

  final dispatchers = <String, void Function(dynamic data)>{};

  final singleDispatchCompleters = <String, Completer>{};

  bool reconnectScheduled = false;

  Future done;

  Future start({int retrySeconds = defaultRetrySeconds});

  void scheduleReconnect(int retrySeconds) {
    if (!reconnectScheduled) {
      final newRetrySeconds = retrySeconds * two;

      print('scheduling reconnect in $newRetrySeconds seconds');

      Timer(Duration(seconds: retrySeconds),
          () async => await start(retrySeconds: newRetrySeconds));
    }
    reconnectScheduled = true;
  }

  void on(String type, void Function(dynamic data) function) {
    if (dispatchers.containsKey(type)) {
      print('Overriding dispatch $type');
    }

    dispatchers[type] = function;
  }

  Future onSingleAsync(String type, void Function(dynamic data) function) {
    singleDispatchCompleters[type] = Completer();

    void runOnceFunction(dynamic data) {
      // remove single dispatch

      singleDispatchCompleters[type].complete();

      removeSingleDispatch(type);

      function(data);
    }

    on(type, runOnceFunction);

    return singleDispatchCompleters[type].future;
  }

  void removeDispatch(String type) {
    // print('removing dispatch $type');
    dispatchers.remove(type);
  }

  void removeSingleDispatch(String type) {
    removeDispatch(type);

    singleDispatchCompleters.remove(type);
  }

  void send(String type, [message]);

  void onDecodedData(data) {
    if (data is List && data.length == defaultLength) {
      // check if dispatch exists
      final type = data[typeIndex];
      if (type == null) {
        print('No such dispatch exists!: $type');
        return;
      }
      final msg = data[messageIndex];

      dispatchers[type](msg);

      return;
    }

    if (data is String) {
      final type = data;

      // check if is command msg
      if (!dispatchers.containsKey(type)) {
        print('No such dispatch exists!: $type');
        return;
      }
      dispatchers[type]({});
      return;
    }

    print('No such dispatch exists!: $data');
  }

  void onData(d) => onDecodedData(jsonDecode(d));
}
