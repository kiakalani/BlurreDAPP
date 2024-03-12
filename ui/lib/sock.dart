import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketIO {
  static SocketIO? _singleton_inst;
  IO.Socket? _socket_inst;
  SocketIO._internal();

  factory SocketIO([String url = ""]) {
    if (_singleton_inst == null) {
      _singleton_inst = SocketIO._internal();
      _singleton_inst!._socket_inst = IO.io(url, <String, dynamic>{
        'transports': ['websocket']
      });
    }
    return _singleton_inst!;
  }

  void connect() {
    _socket_inst!
        .on("conne(url)ct", (data) => {print("Connected!" + data.toString())});
  }

  void disconnect() {
    _socket_inst!.disconnect();
  }

  void on(String event, dynamic Function(dynamic) handler) {
    _socket_inst!.on(event, handler);
  }

  void emit(String event, [dynamic data]) {
    _socket_inst!.emit(event, data);
  }
}
