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
import '../../../native/virtual_display_bridge.dart';

enum SenderStatus {
  idle,
  searching,
  connecting,
  streaming,
  error,
}

enum SenderStreamMode {
  extend,
  mirror,
}

class SenderController extends ChangeNotifier {
  final DiscoveryService discoveryService;
  final WebRTCManager webrtcManager;
  final SignalingClient signalingClient = SignalingClient();

  SenderStatus _status = SenderStatus.idle;
  SenderStatus get status => _status;

  SenderStreamMode _streamMode = SenderStreamMode.extend;
  SenderStreamMode get streamMode => _streamMode;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PeerDevice? _selectedReceiver;
  PeerDevice? get selectedReceiver => _selectedReceiver;

  bool _hasScreenPermission = true;
  bool get hasScreenPermission => _hasScreenPermission;

  List<NativeDisplayInfo> _nativeDisplays = [];
  List<NativeDisplayInfo> get nativeDisplays => _nativeDisplays;

  // Virtual display settings
  VirtualDisplayInfo? _activeVirtualDisplay;
  VirtualDisplayInfo? get activeVirtualDisplay => _activeVirtualDisplay;

  int _virtualWidth = 1920;
  int get virtualWidth => _virtualWidth;

  int _virtualHeight = 1080;
  int get virtualHeight => _virtualHeight;

  double _virtualFps = 60.0;
  double get virtualFps => _virtualFps;

  bool _virtualHiDPI = true;
  bool get virtualHiDPI => _virtualHiDPI;

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
          statusText: _streamMode == SenderStreamMode.extend
              ? 'Extending to ${_selectedReceiver?.name ?? "Windows"}'
              : 'Mirroring to ${_selectedReceiver?.name ?? "Windows"}',
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
        if (_status == SenderStatus.streaming ||
            _status == SenderStatus.connecting) {
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

  void setStreamMode(SenderStreamMode mode) {
    _streamMode = mode;
    notifyListeners();
  }

  void setVirtualResolution(int width, int height) {
    _virtualWidth = width;
    _virtualHeight = height;
    notifyListeners();
  }

  void setVirtualFps(double fps) {
    _virtualFps = fps;
    notifyListeners();
  }

  void setVirtualHiDPI(bool enabled) {
    _virtualHiDPI = enabled;
    notifyListeners();
  }

  void selectSource(DesktopCapturerSource source) {
    webrtcManager.setSelectedSource(source);
    notifyListeners();
  }

  Future<void> openMacDisplaySettings() async {
    await VirtualDisplayBridge.openDisplaySettings();
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
      DesktopCapturerSource? targetCaptureSource;

      if (_streamMode == SenderStreamMode.extend && Platform.isMacOS) {
        // 1. Create native macOS virtual display
        final virtualDisplay = await VirtualDisplayBridge.createVirtualDisplay(
          width: _virtualWidth,
          height: _virtualHeight,
          refreshRate: _virtualFps,
          hiDPI: _virtualHiDPI,
          name: 'NativeDisplay - ${_selectedReceiver?.name ?? "Extended Screen"}',
        );

        if (virtualDisplay == null) {
          throw Exception('Failed to create native macOS virtual display.');
        }

        _activeVirtualDisplay = virtualDisplay;

        // 2. Allow macOS WindowServer brief moment to register display
        await Future.delayed(const Duration(milliseconds: 350));

        // 3. Refresh available sources to locate the new virtual display
        final sources = await webrtcManager.refreshCaptureSources();
        final vIdStr = virtualDisplay.displayId.toString();

        for (final s in sources) {
          if (s.id == vIdStr ||
              s.name.contains('NativeDisplay') ||
              s.name.contains('Virtual')) {
            targetCaptureSource = s;
            break;
          }
        }

        // If not matched by string or ID, fallback to the latest screen source
        targetCaptureSource ??= sources
            .where((s) => s.type == SourceType.Screen)
            .lastOrNull ?? sources.firstOrNull;

        debugPrint('[SenderController] Found ${sources.length} sources: ${sources.map((s) => "${s.id}:${s.name}:${s.type.name}").join(", ")}');
        debugPrint('[SenderController] Selected targetCaptureSource: ${targetCaptureSource?.id}:${targetCaptureSource?.name}');
      } else {
        // Mirror mode: use whatever source was selected in the UI
        targetCaptureSource = webrtcManager.selectedSource;
      }

      // 4. Connect signaling client to target receiver
      await signalingClient.connect(_selectedReceiver!.endpoint);

      // 5. Start WebRTC sender session with the target source
      await webrtcManager.startSenderSession(source: targetCaptureSource);
    } catch (e) {
      // If we created a virtual display but connection failed, clean it up
      if (_activeVirtualDisplay != null) {
        await VirtualDisplayBridge.destroyVirtualDisplay(
            _activeVirtualDisplay!.displayId);
        _activeVirtualDisplay = null;
      }
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

    // Destroy virtual display if active
    if (_activeVirtualDisplay != null) {
      await VirtualDisplayBridge.destroyVirtualDisplay(
          _activeVirtualDisplay!.displayId);
      _activeVirtualDisplay = null;
    }

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
    if (_activeVirtualDisplay != null) {
      VirtualDisplayBridge.destroyVirtualDisplay(
          _activeVirtualDisplay!.displayId);
      _activeVirtualDisplay = null;
    }
    VirtualDisplayBridge.destroyAllVirtualDisplays();
    super.dispose();
  }
}
