import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'stream_quality.dart';
import '../network/models/signaling_message.dart';

enum ConnectionStateStatus {
  idle,
  connecting,
  connected,
  disconnected,
  failed,
}

class WebRTCManager extends ChangeNotifier {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  ConnectionStateStatus _status = ConnectionStateStatus.idle;
  ConnectionStateStatus get status => _status;

  StreamMetrics _metrics = const StreamMetrics();
  StreamMetrics get metrics => _metrics;

  StreamQualityConfig _qualityConfig = const StreamQualityConfig();
  StreamQualityConfig get qualityConfig => _qualityConfig;

  void Function(SignalingMessage message)? onSignalingMessageReady;
  Timer? _statsTimer;
  List<DesktopCapturerSource> _availableSources = [];
  List<DesktopCapturerSource> get availableSources => _availableSources;
  DesktopCapturerSource? _selectedSource;
  DesktopCapturerSource? get selectedSource => _selectedSource;

  final List<RTCIceCandidate> _remoteCandidatesQueue = [];
  bool _isRemoteDescriptionSet = false;

  Future<void> initialize() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  void updateQualityConfig(StreamQualityConfig config) {
    _qualityConfig = config;
    notifyListeners();
  }

  /// Refreshes available display screens and windows on macOS or Windows
  Future<List<DesktopCapturerSource>> refreshCaptureSources() async {
    try {
      final sources = await desktopCapturer.getSources(
        types: [SourceType.Screen, SourceType.Window],
      );
      _availableSources = sources;
      if (_selectedSource == null && sources.isNotEmpty) {
        _selectedSource = sources.first;
      }
      notifyListeners();
      return sources;
    } catch (e) {
      debugPrint('[WebRTCManager] Failed to get capture sources: $e');
      return [];
    }
  }

  void setSelectedSource(DesktopCapturerSource source) {
    _selectedSource = source;
    notifyListeners();
  }

  Map<String, dynamic> _buildConfiguration() {
    return {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
      'sdpSemantics': 'unified-plan',
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
    };
  }

  // --- SENDER IMPLEMENTATION ---

  Future<void> startSenderSession({DesktopCapturerSource? source}) async {
    _status = ConnectionStateStatus.connecting;
    notifyListeners();

    await _cleanupPeer();

    final targetSource = source ?? _selectedSource;
    if (targetSource != null) {
      _selectedSource = targetSource;
    } else {
      final sources = await refreshCaptureSources();
      if (sources.isNotEmpty) {
        _selectedSource = sources.first;
      }
    }

    try {
      // 1. Capture Screen Stream
      final Map<String, dynamic> mediaConstraints = {
        'audio': false,
        'video': {
          'deviceId': {'exact': _selectedSource?.id ?? '0'},
          'mandatory': {
            'minWidth': '${_qualityConfig.width}',
            'minHeight': '${_qualityConfig.height}',
            'minFrameRate': '${_qualityConfig.effectiveFps}',
            'maxFrameRate': '${_qualityConfig.effectiveFps}',
          },
        },
      };

      _localStream = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
      localRenderer.srcObject = _localStream;

      // 2. Initialize PeerConnection
      _peerConnection = await createPeerConnection(_buildConfiguration());

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate.candidate == null || candidate.candidate!.trim().isEmpty) {
          return;
        }
        onSignalingMessageReady?.call(SignalingMessage(
          type: SignalingType.candidate,
          data: candidate.toMap(),
          senderId: 'sender',
        ));
      };

      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        _handlePeerConnectionStateChange(state);
      };

      _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
        _handleIceConnectionStateChange(state);
      };

      // 3. Add video track to PeerConnection
      for (final track in _localStream!.getTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
      }

      // 4. Create and send Offer (Unified Plan)
      final offer = await _peerConnection!.createOffer({});

      await _peerConnection!.setLocalDescription(offer);

      onSignalingMessageReady?.call(SignalingMessage(
        type: SignalingType.offer,
        data: offer.toMap(),
        senderId: 'sender',
      ));

      _startStatsMonitoring();
    } catch (e) {
      debugPrint('[WebRTCManager] Failed to start sender session: $e');
      _status = ConnectionStateStatus.failed;
      notifyListeners();
    }
  }

  // --- RECEIVER IMPLEMENTATION ---

  Future<void> prepareReceiverSession() async {
    _status = ConnectionStateStatus.connecting;
    notifyListeners();

    await _cleanupPeer();

    try {
      _peerConnection = await createPeerConnection(_buildConfiguration());

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate.candidate == null || candidate.candidate!.trim().isEmpty) {
          return;
        }
        onSignalingMessageReady?.call(SignalingMessage(
          type: SignalingType.candidate,
          data: candidate.toMap(),
          senderId: 'receiver',
        ));
      };

      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        _handlePeerConnectionStateChange(state);
      };

      _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
        _handleIceConnectionStateChange(state);
      };

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        debugPrint('[WebRTCManager] onTrack: streams=${event.streams.length}, track=${event.track.id}');
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          remoteRenderer.srcObject = _remoteStream;
          _status = ConnectionStateStatus.connected;
          notifyListeners();
        }
      };

      _startStatsMonitoring();
    } catch (e) {
      debugPrint('[WebRTCManager] Failed to prepare receiver session: $e');
      _status = ConnectionStateStatus.failed;
      notifyListeners();
    }
  }

  // --- SIGNALING MESSAGE DISPATCH ---

  Future<void> handleIncomingSignaling(SignalingMessage message) async {
    debugPrint('[WebRTCManager] handleIncomingSignaling: ${message.type.name} from ${message.senderId}');
    try {
      switch (message.type) {
        case SignalingType.offer:
          debugPrint('[WebRTCManager] Processing Offer...');
          if (_peerConnection == null) {
            await prepareReceiverSession();
          }
          final sdp = RTCSessionDescription(
            message.data['sdp'] as String?,
            (message.data['type'] as String?) ?? 'offer',
          );
          await _peerConnection!.setRemoteDescription(sdp);
          _isRemoteDescriptionSet = true;
          debugPrint('[WebRTCManager] Set remote description (Offer)');
          await _drainRemoteCandidatesQueue();

          final answer = await _peerConnection!.createAnswer({});
          await _peerConnection!.setLocalDescription(answer);
          debugPrint('[WebRTCManager] Set local description (Answer)');

          onSignalingMessageReady?.call(SignalingMessage(
            type: SignalingType.answer,
            data: answer.toMap(),
            senderId: 'receiver',
          ));
          break;

        case SignalingType.answer:
          debugPrint('[WebRTCManager] Processing Answer...');
          if (_peerConnection != null) {
            final sdp = RTCSessionDescription(
              message.data['sdp'] as String?,
              (message.data['type'] as String?) ?? 'answer',
            );
            await _peerConnection!.setRemoteDescription(sdp);
            _isRemoteDescriptionSet = true;
            debugPrint('[WebRTCManager] Set remote description (Answer) successfully!');
            await _drainRemoteCandidatesQueue();
          } else {
            debugPrint('[WebRTCManager] Warning: Received Answer but _peerConnection is null');
          }
          break;

        case SignalingType.candidate:
          final candidateStr = message.data['candidate'] as String?;
          if (candidateStr == null || candidateStr.trim().isEmpty) {
            debugPrint('[WebRTCManager] Received end-of-candidates (null/empty candidate). Skipping.');
            break;
          }
          final sdpMid = message.data['sdpMid'] as String?;
          final sdpMLineIndex = (message.data['sdpMLineIndex'] as num?)?.toInt();

          final candidate = RTCIceCandidate(
            candidateStr,
            sdpMid,
            sdpMLineIndex,
          );

          if (_peerConnection != null) {
            if (_isRemoteDescriptionSet) {
              await _peerConnection!.addCandidate(candidate);
              debugPrint('[WebRTCManager] Added remote ICE candidate: $candidateStr');
            } else {
              debugPrint('[WebRTCManager] Queued remote ICE candidate: $candidateStr');
              _remoteCandidatesQueue.add(candidate);
            }
          }
          break;

        case SignalingType.disconnect:
          debugPrint('[WebRTCManager] Received disconnect signal from peer');
          await stopSession();
          break;

        default:
          break;
      }
    } catch (e, stack) {
      debugPrint('[WebRTCManager] Error in handleIncomingSignaling (${message.type.name}): $e\n$stack');
    }
  }

  Future<void> _drainRemoteCandidatesQueue() async {
    debugPrint('[WebRTCManager] Draining ${_remoteCandidatesQueue.length} queued remote candidates...');
    for (final candidate in _remoteCandidatesQueue) {
      try {
        await _peerConnection?.addCandidate(candidate);
      } catch (e) {
        debugPrint('[WebRTCManager] Failed to add queued candidate: $e');
      }
    }
    _remoteCandidatesQueue.clear();
  }

  void _handlePeerConnectionStateChange(RTCPeerConnectionState state) {
    debugPrint('[WebRTCManager] PeerConnectionState: $state');
    switch (state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        _status = ConnectionStateStatus.connected;
        notifyListeners();
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
        _status = ConnectionStateStatus.connecting;
        notifyListeners();
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        _status = ConnectionStateStatus.disconnected;
        notifyListeners();
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
        _status = ConnectionStateStatus.failed;
        notifyListeners();
        break;
      default:
        break;
    }
  }

  void _handleIceConnectionStateChange(RTCIceConnectionState state) {
    debugPrint('[WebRTCManager] IceConnectionState: $state');
    switch (state) {
      case RTCIceConnectionState.RTCIceConnectionStateConnected:
      case RTCIceConnectionState.RTCIceConnectionStateCompleted:
        if (_status != ConnectionStateStatus.connected) {
          _status = ConnectionStateStatus.connected;
          notifyListeners();
        }
        break;
      case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
        if (_status != ConnectionStateStatus.disconnected) {
          _status = ConnectionStateStatus.disconnected;
          notifyListeners();
        }
        break;
      case RTCIceConnectionState.RTCIceConnectionStateFailed:
        _status = ConnectionStateStatus.failed;
        notifyListeners();
        break;
      default:
        break;
    }
  }

  void _startStatsMonitoring() {
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_peerConnection != null && _status == ConnectionStateStatus.connected) {
        try {
          final stats = await _peerConnection!.getStats();
          double currentFps = _qualityConfig.effectiveFps.toDouble();
          double latency = 12.0; // Default typical LAN RTT ms
          double bitrate = _qualityConfig.effectiveBitrateKbps / 1000.0;
          int lostPackets = 0;

          for (final report in stats) {
            if (report.type == 'inbound-rtp' || report.type == 'outbound-rtp') {
              if (report.values['framesPerSecond'] != null) {
                currentFps = (report.values['framesPerSecond'] as num).toDouble();
              }
              if (report.values['roundTripTime'] != null) {
                latency = ((report.values['roundTripTime'] as num).toDouble()) * 1000.0;
              }
              if (report.values['packetsLost'] != null) {
                lostPackets = (report.values['packetsLost'] as num).toInt();
              }
            }
          }

          _metrics = StreamMetrics(
            fps: currentFps,
            latencyMs: latency,
            bitrateMbps: bitrate,
            packetLossCount: lostPackets,
            codec: 'H.264 High-Profile',
          );
          notifyListeners();
        } catch (_) {}
      }
    });
  }

  Future<void> stopSession() async {
    _statsTimer?.cancel();
    _statsTimer = null;
    await _cleanupPeer();
    _status = ConnectionStateStatus.idle;
    _metrics = const StreamMetrics();
    notifyListeners();
  }

  Future<void> _cleanupPeer() async {
    if (_localStream != null) {
      for (var track in _localStream!.getTracks()) {
        track.stop();
      }
      await _localStream!.dispose();
      _localStream = null;
    }

    if (_remoteStream != null) {
      for (var track in _remoteStream!.getTracks()) {
        track.stop();
      }
      await _remoteStream!.dispose();
      _remoteStream = null;
    }

    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;

    await _peerConnection?.close();
    _peerConnection = null;

    _remoteCandidatesQueue.clear();
    _isRemoteDescriptionSet = false;
  }

  @override
  void dispose() {
    stopSession();
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.dispose();
  }
}
