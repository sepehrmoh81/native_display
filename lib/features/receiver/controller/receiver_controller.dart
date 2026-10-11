import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
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

class ReceiverController extends ChangeNotifier with WindowListener {
  final DiscoveryService discoveryService;
  final WebRTCManager webrtcManager;
  final SignalingServer signalingServer =
      SignalingServer(port: AppConstants.defaultSignalingPort);

  ReceiverStatus _status = ReceiverStatus.idle;
  ReceiverStatus get status => _status;

  @visibleForTesting
  void setStatusForTesting(ReceiverStatus status) {
    _status = status;
    notifyListeners();
  }

  bool _discoveryEnabled = true;
  bool get isDiscoveryEnabled => _discoveryEnabled;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _deviceName = 'Windows Display';
  String get deviceName => _deviceName;

  int _screenWidth = 1920;
  int get screenWidth => _screenWidth;

  int _screenHeight = 1080;
  int get screenHeight => _screenHeight;

  int _refreshRate = 60;
  int get refreshRate => _refreshRate;

  bool _isFullscreen = false;
  bool get isFullscreen => _isFullscreen;

  WebSocketChannel? _activeClient;
  final bool autoStartOnWindows;

  ReceiverController({
    required this.discoveryService,
    required this.webrtcManager,
    this.autoStartOnWindows = true,
  }) {
    _init();
  }

  void _detectDisplayCapabilities() {
    try {
      final dispatcher = ui.PlatformDispatcher.instance;
      ui.Display? primaryDisplay;

      if (dispatcher.views.isNotEmpty) {
        primaryDisplay = dispatcher.views.first.display;
      } else if (dispatcher.displays.isNotEmpty) {
        primaryDisplay = dispatcher.displays.first;
      }

      if (primaryDisplay != null) {
        final w = primaryDisplay.size.width.toInt();
        final h = primaryDisplay.size.height.toInt();
        final hz = primaryDisplay.refreshRate.round();

        if (w > 0 && h > 0) {
          _screenWidth = w;
          _screenHeight = h;
        }
        if (hz > 0) {
          _refreshRate = hz;
        }
        debugPrint(
            '[ReceiverController] Detected display: ${_screenWidth}x$_screenHeight @ ${_refreshRate}Hz');
      }
    } catch (e) {
      debugPrint('[ReceiverController] Could not detect display specs: $e');
    }
  }

  void overrideDisplayCapabilities({int? width, int? height, int? refreshRate}) {
    if (width != null && width > 0) _screenWidth = width;
    if (height != null && height > 0) _screenHeight = height;
    if (refreshRate != null && refreshRate > 0) _refreshRate = refreshRate;
    if (_status == ReceiverStatus.listening) {
      startListening();
    }
    notifyListeners();
  }

  Future<void> _init() async {
    _detectDisplayCapabilities();
    if (Platform.isMacOS || Platform.isWindows) {
      windowManager.addListener(this);
    }
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
    if (autoStartOnWindows && Platform.isWindows) {
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
      // 1. Detect latest display capabilities
      _detectDisplayCapabilities();

      // 2. Start Signaling WebSocket server
      await signalingServer.start();

      // 3. Prepare WebRTC receiver session
      await webrtcManager.prepareReceiverSession();

      // 4. Broadcast service via mDNS and UDP with true monitor capabilities
      await discoveryService.startBroadcasting(
        deviceName: _deviceName,
        port: AppConstants.defaultSignalingPort,
        mode: AppMode.receiver,
        platform: Platform.isWindows
            ? DevicePlatform.windows
            : (Platform.isMacOS ? DevicePlatform.macos : DevicePlatform.unknown),
        screenWidth: _screenWidth,
        screenHeight: _screenHeight,
        refreshRate: _refreshRate,
      );
    } catch (e) {
      _status = ReceiverStatus.error;
      _errorMessage = 'Could not start receiver service: $e';
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    try {
      await discoveryService.stopBroadcasting();
    } catch (e) {
      debugPrint('[ReceiverController] stopBroadcasting error: $e');
    }

    try {
      await signalingServer.stop();
    } catch (e) {
      debugPrint('[ReceiverController] signalingServer.stop error: $e');
    }

    try {
      await webrtcManager.stopSession();
    } catch (e) {
      debugPrint('[ReceiverController] webrtcManager.stopSession error: $e');
    }

    _activeClient = null;
    _status = ReceiverStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> setDiscoveryEnabled(bool enabled) async {
    _discoveryEnabled = enabled;
    if (enabled) {
      await startListening();
    } else {
      await stopListening();
    }
  }

  Future<void> toggleDiscovery() async {
    await setDiscoveryEnabled(!_discoveryEnabled);
  }

  @override
  void onWindowEnterFullScreen() {
    if (!_isFullscreen) {
      _isFullscreen = true;
      notifyListeners();
    }
  }

  @override
  void onWindowLeaveFullScreen() {
    if (_isFullscreen) {
      _isFullscreen = false;
      notifyListeners();
    }
  }

  Future<void> setFullscreen(bool value) async {
    if (_isFullscreen == value) return;
    try {
      _isFullscreen = value;
      notifyListeners();
      if (Platform.isMacOS || Platform.isWindows) {
        await windowManager.setFullScreen(value);
      }
    } catch (e) {
      debugPrint('[ReceiverController] setFullscreen error: $e');
    }
  }

  Future<void> toggleFullscreen() async {
    await setFullscreen(!_isFullscreen);
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
    if (Platform.isMacOS || Platform.isWindows) {
      windowManager.removeListener(this);
    }
    signalingServer.stop();
    discoveryService.stopBroadcasting();
    super.dispose();
  }
}
