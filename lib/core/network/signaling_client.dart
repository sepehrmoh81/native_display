import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
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
      debugPrint('[SignalingClient] Connecting to WebSocket: $url');
      final uri = Uri.parse(url);
      final channel = WebSocketChannel.connect(uri);
      
      await channel.ready;
      
      _channel = channel;
      _isConnected = true;
      debugPrint('[SignalingClient] Connected successfully to $url');
      onConnected?.call();
      _startPing();

      _subscription = _channel!.stream.listen(
        (data) {
          final String raw;
          if (data is String) {
            raw = data;
          } else if (data is List<int>) {
            raw = utf8.decode(data);
          } else {
            raw = data.toString();
          }
          try {
            final message = SignalingMessage.decode(raw);
            debugPrint('[SignalingClient] Dispatched incoming message: ${message.type.name} (length: ${raw.length})');
            onMessage?.call(message);
          } catch (e, stack) {
            debugPrint('[SignalingClient] Error processing incoming signaling data: $e\n$stack');
          }
        },
        onDone: () {
          debugPrint('[SignalingClient] WebSocket stream closed (onDone)');
          _handleDisconnect();
        },
        onError: (err) {
          debugPrint('[SignalingClient] WebSocket stream error: $err');
          onError?.call(err);
          _handleDisconnect();
        },
      );
    } catch (e) {
      debugPrint('[SignalingClient] Connection error: $e');
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
        final payload = message.encode();
        debugPrint('[SignalingClient] Sending message ${message.type.name} (${payload.length} chars)');
        _channel!.sink.add(payload);
      } catch (e, stack) {
        debugPrint('[SignalingClient] Failed to send ${message.type.name}: $e\n$stack');
      }
    } else {
      debugPrint('[SignalingClient] Cannot send ${message.type.name}: channel null or not connected (connected=$_isConnected)');
    }
  }

  void _handleDisconnect() {
    debugPrint('[SignalingClient] Handling disconnect...');
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
