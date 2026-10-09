import 'dart:async';
import 'dart:convert';
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
      debugPrint('[SignalingServer] Client connected. Active clients: ${_clients.length}');
      onClientConnected?.call(channel);

      channel.stream.listen(
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
            debugPrint('[SignalingServer] Received signaling message: ${message.type.name} (length: ${raw.length})');
            onMessage?.call(message, channel);
          } catch (e, stack) {
            debugPrint('[SignalingServer] Error processing signaling packet: $e\n$stack');
          }
        },
        onDone: () {
          debugPrint('[SignalingServer] Client connection onDone');
          _clients.remove(channel);
          onClientDisconnected?.call(channel);
        },
        onError: (error) {
          debugPrint('[SignalingServer] Client connection onError: $error');
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
      debugPrint('[SignalingServer] Listening on port $port');
    } catch (e) {
      debugPrint('[SignalingServer] Failed to bind port $port: $e');
      rethrow;
    }
  }

  void broadcast(SignalingMessage message, {WebSocketChannel? exclude}) {
    final payload = message.encode();
    debugPrint('[SignalingServer] Broadcasting ${message.type.name} to ${_clients.length} clients (${payload.length} chars)');
    for (final client in _clients) {
      if (client != exclude) {
        try {
          client.sink.add(payload);
        } catch (e) {
          debugPrint('[SignalingServer] Broadcast send error: $e');
        }
      }
    }
  }

  void sendTo(WebSocketChannel client, SignalingMessage message) {
    try {
      final payload = message.encode();
      debugPrint('[SignalingServer] Sending ${message.type.name} to client (${payload.length} chars)');
      client.sink.add(payload);
    } catch (e) {
      debugPrint('[SignalingServer] sendTo error for ${message.type.name}: $e');
    }
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
