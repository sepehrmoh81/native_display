import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/discovery_service.dart';
import '../../../core/network/models/peer_device.dart';
import '../../../core/network/models/signaling_message.dart';
import '../../../core/network/signaling_client.dart';
import '../../../core/tray/tray_controller.dart';
import '../../../core/webrtc/webrtc_manager.dart';
import '../../../native/screen_capture_bridge.dart';

enum SenderStatus {
  idle,
  searching,
  connecting,
  streaming,
  error,
}

class SenderController extends ChangeNotifier {
  final DiscoveryService discoveryService;
  final WebRTCManager webrtcManager;
  final SignalingClient signalingClient = SignalingClient();

  SenderStatus _status = SenderStatus.idle;
  SenderStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PeerDevice? _selectedReceiver;
  PeerDevice? get selectedReceiver => _selectedReceiver;

  bool _hasScreenPermission = true;
  bool get hasScreenPermission => _hasScreenPermission;

  List<NativeDisplayInfo> _nativeDisplays = [];
  List<NativeDisplayInfo> get nativeDisplays => _nativeDisplays;

  SenderController({
    required this.discoveryService,
    required this.webrtcManager,
  }) {
    _init();
  }

  Future<void> _init() async {
    // Check macOS screen recording permission
    if (Platform.isMacOS) {
      _hasScreenPermission =
          await ScreenCaptureBridge.hasScreenRecordingPermission();
      _nativeDisplays = await ScreenCaptureBridge.getNativeDisplays();
    }

    // Refresh capture sources (screens/windows)
    await webrtcManager.refreshCaptureSources();

    // Listen to discovery updates
    discoveryService.addListener(_onDiscoveryUpdate);

    // Setup signaling client callbacks
    signalingClient.onMessage = (message) {
      webrtcManager.handleIncomingSignaling(message);
    };

    signalingClient.onDisconnected = () {
      if (_status == SenderStatus.streaming ||
          _status == SenderStatus.connecting) {
        stopStreaming();
      }
    };

    signalingClient.onError = (err) {
      _errorMessage = 'Signaling connection error: $err';
      _status = SenderStatus.error;
      notifyListeners();
    };

    // Forward WebRTC local signaling messages to receiver
    webrtcManager.onSignalingMessageReady = (message) {
      signalingClient.send(message);
    };

    // Listen to WebRTC status changes
    webrtcManager.addListener(() {
      if (webrtcManager.status == ConnectionStateStatus.connected) {
        _status = SenderStatus.streaming;
        _errorMessage = null;
        TrayController.instance.updateMenu(
          statusText: 'Streaming to ${_selectedReceiver?.name ?? "Windows"}',
          isStreaming: true,
        );
      } else if (webrtcManager.status == ConnectionStateStatus.failed) {
        _status = SenderStatus.error;
        _errorMessage = 'WebRTC PeerConnection failed to establish.';
        TrayController.instance.updateMenu(
          statusText: 'Error',
          isStreaming: false,
        );
      } else if (webrtcManager.status == ConnectionStateStatus.disconnected) {
        if (_status == SenderStatus.streaming || _status == SenderStatus.connecting) {
          _errorMessage = 'Connection dropped unexpectedly.';
          stopStreaming();
        }
      }
      notifyListeners();
    });

    // Start auto-discovering receivers
    startDiscovery();
  }

  void _onDiscoveryUpdate() {
    final receivers = availableReceivers;
    if (_selectedReceiver == null && receivers.isNotEmpty) {
      _selectedReceiver = receivers.first;
    }
    TrayController.instance.updateMenu(
      statusText: _status == SenderStatus.streaming ? 'Streaming' : 'Ready',
      isStreaming: _status == SenderStatus.streaming,
      receiverNames: receivers.map((r) => r.name).toList(),
    );
    notifyListeners();
  }

  List<PeerDevice> get availableReceivers => discoveryService.discoveredDevices
      .where((d) => d.mode == AppMode.receiver)
      .toList();

  void selectReceiver(PeerDevice receiver) {
    _selectedReceiver = receiver;
    notifyListeners();
  }

  void selectSource(DesktopCapturerSource source) {
    webrtcManager.setSelectedSource(source);
    notifyListeners();
  }

  Future<void> requestPermission() async {
    final granted =
        await ScreenCaptureBridge.requestScreenRecordingPermission();
    _hasScreenPermission = granted;
    if (granted) {
      await webrtcManager.refreshCaptureSources();
      _nativeDisplays = await ScreenCaptureBridge.getNativeDisplays();
    }
    notifyListeners();
  }

  void startDiscovery() {
    _status = SenderStatus.searching;
    discoveryService.startScanning();
    notifyListeners();
  }

  Future<void> startStreaming() async {
    if (_selectedReceiver == null) {
      _errorMessage = 'Please select a secondary display receiver first.';
      _status = SenderStatus.error;
      notifyListeners();
      return;
    }

    _status = SenderStatus.connecting;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Connect signaling client to target receiver
      await signalingClient.connect(_selectedReceiver!.endpoint);

      // 2. Start WebRTC sender session
      await webrtcManager.startSenderSession();
    } catch (e) {
      _status = SenderStatus.error;
      _errorMessage = 'Failed to connect to display receiver: $e';
      notifyListeners();
    }
  }

  Future<void> stopStreaming() async {
    signalingClient.send(const SignalingMessage(
      type: SignalingType.disconnect,
      data: {},
      senderId: 'sender',
    ));
    await signalingClient.disconnect();
    await webrtcManager.stopSession();
    _status = SenderStatus.idle;
    TrayController.instance.updateMenu(
      statusText: 'Idle',
      isStreaming: false,
      receiverNames: availableReceivers.map((r) => r.name).toList(),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    discoveryService.removeListener(_onDiscoveryUpdate);
    signalingClient.disconnect();
    super.dispose();
  }
}
