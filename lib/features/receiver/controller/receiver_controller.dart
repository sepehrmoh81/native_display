import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:window_manager/window_manager.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/discovery_service.dart';
import '../../../core/network/models/peer_device.dart';
import '../../../core/network/models/signaling_message.dart';
import '../../../core/network/signaling_server.dart';
import '../../../core/webrtc/webrtc_manager.dart';

enum ReceiverStatus {
  idle,
  listening,
  connected,
  error,
}

class ReceiverController extends ChangeNotifier {
  final DiscoveryService discoveryService;
  final WebRTCManager webrtcManager;
  final SignalingServer signalingServer =
      SignalingServer(port: AppConstants.defaultSignalingPort);

  ReceiverStatus _status = ReceiverStatus.idle;
  ReceiverStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _deviceName = 'Windows Display';
  String get deviceName => _deviceName;

  bool _isFullscreen = false;
  bool get isFullscreen => _isFullscreen;

  WebSocketChannel? _activeClient;

  ReceiverController({
    required this.discoveryService,
    required this.webrtcManager,
  }) {
    _init();
  }

  Future<void> _init() async {
    _deviceName = Platform.localHostname.isNotEmpty
        ? Platform.localHostname
        : 'Windows Secondary Display';

    // Signaling server message dispatch
    signalingServer.onClientConnected = (client) {
      debugPrint('[ReceiverController] Client connected to signaling server');
      _activeClient ??= client;
    };

    signalingServer.onMessage = (message, client) {
      _activeClient = client;
      webrtcManager.handleIncomingSignaling(message);
    };

    signalingServer.onClientDisconnected = (client) {
      debugPrint('[ReceiverController] Client disconnected from signaling server');
      if (_activeClient == client) {
        _activeClient = null;
        webrtcManager.stopSession();
        _status = ReceiverStatus.listening;
        notifyListeners();
      }
    };

    // Forward WebRTC local signaling messages (e.g. answer & candidates) to sender client
    webrtcManager.onSignalingMessageReady = (message) {
      debugPrint('[ReceiverController] WebRTC message ready: ${message.type.name} (has activeClient: ${_activeClient != null})');
      if (_activeClient != null) {
        signalingServer.sendTo(_activeClient!, message);
      } else {
        debugPrint('[ReceiverController] Fallback: Broadcasting ${message.type.name} to all connected clients');
        signalingServer.broadcast(message);
      }
    };

    // Listen to WebRTC connection changes
    webrtcManager.addListener(() {
      if (webrtcManager.status == ConnectionStateStatus.connected) {
        _status = ReceiverStatus.connected;
        _errorMessage = null;
      } else if (webrtcManager.status == ConnectionStateStatus.failed) {
        _status = ReceiverStatus.error;
        _errorMessage = 'Connection lost or WebRTC negotiation failed.';
      } else if (webrtcManager.status == ConnectionStateStatus.idle ||
                 webrtcManager.status == ConnectionStateStatus.disconnected) {
        if (_status != ReceiverStatus.listening) {
          _status = ReceiverStatus.listening;
        }
      }
      notifyListeners();
    });

    // Start hosting and broadcasting (Windows starts immediately; macOS starts when user selects receiver tab)
    if (Platform.isWindows) {
      await startListening();
    }
  }

  void setDeviceName(String name) {
    _deviceName = name;
    if (_status == ReceiverStatus.listening) {
      startListening(); // restart broadcast with new name
    }
    notifyListeners();
  }

  Future<void> startListening() async {
    _status = ReceiverStatus.listening;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Start Signaling WebSocket server
      await signalingServer.start();

      // 2. Prepare WebRTC receiver session
      await webrtcManager.prepareReceiverSession();

      // 3. Broadcast service via mDNS and UDP
      await discoveryService.startBroadcasting(
        deviceName: _deviceName,
        port: AppConstants.defaultSignalingPort,
        mode: AppMode.receiver,
        platform: Platform.isWindows
            ? DevicePlatform.windows
            : (Platform.isMacOS ? DevicePlatform.macos : DevicePlatform.unknown),
        screenWidth: 1920,
        screenHeight: 1080,
        refreshRate: 60,
      );
    } catch (e) {
      _status = ReceiverStatus.error;
      _errorMessage = 'Could not start receiver service: $e';
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    try {
      discoveryService.stopBroadcasting();
      await signalingServer.stop();
      await webrtcManager.stopSession();
      _activeClient = null;
      _status = ReceiverStatus.idle;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      debugPrint('[ReceiverController] stopListening error: $e');
    }
  }

  Future<void> toggleFullscreen() async {
    try {
      _isFullscreen = !_isFullscreen;
      await windowManager.setFullScreen(_isFullscreen);
      notifyListeners();
    } catch (e) {
      debugPrint('[ReceiverController] Fullscreen error: $e');
    }
  }

  Future<void> disconnectSender() async {
    if (_activeClient != null) {
      signalingServer.sendTo(_activeClient!, const SignalingMessage(
        type: SignalingType.disconnect,
        data: {},
        senderId: 'receiver',
      ));
    }
    await webrtcManager.stopSession();
    _status = ReceiverStatus.listening;
    notifyListeners();
  }

  @override
  void dispose() {
    signalingServer.stop();
    discoveryService.stopBroadcasting();
    super.dispose();
  }
}
