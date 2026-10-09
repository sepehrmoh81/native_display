import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'models/signaling_message.dart';

typedef MessageCallback = void Function(SignalingMessage message, WebSocketChannel client);

class SignalingServer {
  HttpServer? _server;
  final int port;
  final List<WebSocketChannel> _clients = [];
  MessageCallback? onMessage;
  void Function(WebSocketChannel client)? onClientConnected;
  void Function(WebSocketChannel client)? onClientDisconnected;

  SignalingServer({this.port = 8989});

  bool get isRunning => _server != null;
  int get activeConnections => _clients.length;

  Future<void> start() async {
    if (_server != null) return;

    final wsHandler = webSocketHandler((WebSocketChannel channel, _) {
      _clients.add(channel);
      onClientConnected?.call(channel);

      channel.stream.listen(
        (data) {
          try {
            if (data is String) {
              final message = SignalingMessage.decode(data);
              debugPrint('[SignalingServer] Received signaling message: ${message.type.name}');
              onMessage?.call(message, channel);
            }
          } catch (e, stack) {
            debugPrint('[SignalingServer] Error processing signaling packet: $e\n$stack');
          }
        },
        onDone: () {
          _clients.remove(channel);
          onClientDisconnected?.call(channel);
        },
        onError: (error) {
          _clients.remove(channel);
          onClientDisconnected?.call(channel);
        },
      );
    });

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler((Request request) {
      if (request.url.path == 'ws' || request.url.path == '') {
        return wsHandler(request);
      }
      return Response.ok('Native Display Signaling Server Active');
    });

    try {
      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
    } catch (e) {
      rethrow;
    }
  }

  void broadcast(SignalingMessage message, {WebSocketChannel? exclude}) {
    final payload = message.encode();
    for (final client in _clients) {
      if (client != exclude) {
        try {
          client.sink.add(payload);
        } catch (_) {}
      }
    }
  }

  void sendTo(WebSocketChannel client, SignalingMessage message) {
    try {
      client.sink.add(message.encode());
    } catch (_) {}
  }

  Future<void> stop() async {
    for (final client in _clients) {
      try {
        client.sink.close();
      } catch (_) {}
    }
    _clients.clear();
    await _server?.close(force: true);
    _server = null;
  }
}
