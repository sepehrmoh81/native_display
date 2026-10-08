import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'models/signaling_message.dart';

class SignalingClient {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _pingTimer;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void Function(SignalingMessage message)? onMessage;
  void Function()? onConnected;
  void Function(dynamic error)? onError;
  void Function()? onDisconnected;

  Future<void> connect(String url) async {
    await disconnect();

    try {
      final uri = Uri.parse(url);
      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        (data) {
          if (!_isConnected) {
            _isConnected = true;
            onConnected?.call();
            _startPing();
          }

          if (data is String) {
            try {
              final message = SignalingMessage.decode(data);
              onMessage?.call(message);
            } catch (e) {
              // Parse error
            }
          }
        },
        onDone: () {
          _handleDisconnect();
        },
        onError: (err) {
          onError?.call(err);
          _handleDisconnect();
        },
      );
    } catch (e) {
      _handleDisconnect();
      rethrow;
    }
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_isConnected) {
        send(const SignalingMessage(
          type: SignalingType.ping,
          data: {},
          senderId: 'client',
        ));
      }
    });
  }

  void send(SignalingMessage message) {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(message.encode());
      } catch (e) {
        // failed send
      }
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _pingTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    onDisconnected?.call();
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _pingTimer?.cancel();
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }
}
