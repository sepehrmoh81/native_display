import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'sdp_optimizer.dart';
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

  RTCPeerConnectionState? _peerConnectionState;
  RTCIceConnectionState? _iceConnectionState;

  final List<RTCIceCandidate> _remoteCandidatesQueue = [];
  bool _isRemoteDescriptionSet = false;

  int? _lastBytesSent;
  int? _lastBytesReceived;
  DateTime? _lastStatsTimestamp;

  Future<void> initialize() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  void updateQualityConfig(StreamQualityConfig config) {
    _qualityConfig = config;
    if (_peerConnection != null && _status == ConnectionStateStatus.connected) {
      _applySenderParameters();
    }
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
      // 1. Capture Screen Stream with numeric frameRate for macOS ScreenCaptureKit
      final Map<String, dynamic> mediaConstraints = {
        'audio': false,
        'video': {
          'deviceId': {'exact': _selectedSource?.id ?? '0'},
          'mandatory': {
            'frameRate': _qualityConfig.effectiveFps,
            'minFrameRate': _qualityConfig.effectiveFps,
            'maxFrameRate': _qualityConfig.effectiveFps,
            'width': _qualityConfig.width,
            'height': _qualityConfig.height,
            'minWidth': _qualityConfig.width,
            'minHeight': _qualityConfig.height,
          },
          'optional': [
            {'fps': _qualityConfig.effectiveFps},
          ],
        },
      };

      _localStream = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
      localRenderer.srcObject = _localStream;

      // 2. Initialize PeerConnection
      _peerConnection = await createPeerConnection(_buildConfiguration());

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate.candidate == null || candidate.candidate!.trim().isEmpty) {
          debugPrint('[WebRTCManager] Local candidate gathering complete (null/empty)');
          return;
        }
        debugPrint('[WebRTCManager] Generated local ICE candidate: ${candidate.candidate}');
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
        debugPrint('[WebRTCManager] Adding track ${track.kind}:${track.id} to PeerConnection');
        await _peerConnection!.addTrack(track, _localStream!);
      }

      // 4. Create, optimize with dynamic SDP munging, and send Offer
      debugPrint('[WebRTCManager] Creating Offer...');
      var offer = await _peerConnection!.createOffer({});
      final optimizedSdp = SdpOptimizer.optimize(
        offer.sdp ?? '',
        bitrateKbps: _qualityConfig.effectiveBitrateKbps,
        fps: _qualityConfig.effectiveFps,
        preferH264: _qualityConfig.enableHardwareAcceleration,
      );
      offer = RTCSessionDescription(optimizedSdp, offer.type);

      debugPrint('[WebRTCManager] Setting local description (Offer with optimized SDP)...');
      await _peerConnection!.setLocalDescription(offer);
      await _applySenderParameters();

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
          debugPrint('[WebRTCManager] Receiver candidate gathering complete (null/empty)');
          return;
        }
        debugPrint('[WebRTCManager] Generated local ICE candidate (receiver): ${candidate.candidate}');
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
          if (_iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateConnected ||
              _iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateCompleted ||
              _peerConnectionState == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
            _status = ConnectionStateStatus.connected;
          }
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

  // --- SENDER PARAMETERS OPTIMIZATION ---

  Future<void> _applySenderParameters() async {
    if (_peerConnection == null) return;
    try {
      final senders = await _peerConnection!.getSenders();
      for (final sender in senders) {
        if (sender.track?.kind == 'video') {
          final params = sender.parameters;
          params.degradationPreference =
              RTCDegradationPreference.MAINTAIN_FRAMERATE;
          final targetBitrateBps = _qualityConfig.effectiveBitrateKbps * 1000;
          final minBitrateBps = (_qualityConfig.effectiveBitrateKbps * 1000 ~/ 3)
              .clamp(2000000, targetBitrateBps);

          if (params.encodings != null && params.encodings!.isNotEmpty) {
            for (final encoding in params.encodings!) {
              encoding.maxBitrate = targetBitrateBps;
              encoding.minBitrate = minBitrateBps;
              encoding.maxFramerate = _qualityConfig.effectiveFps;
              encoding.priority = RTCPriorityType.high;
              encoding.networkPriority = RTCPriorityType.high;
            }
          } else {
            params.encodings = [
              RTCRtpEncoding(
                active: true,
                maxBitrate: targetBitrateBps,
                minBitrate: minBitrateBps,
                maxFramerate: _qualityConfig.effectiveFps,
                priority: RTCPriorityType.high,
                networkPriority: RTCPriorityType.high,
              ),
            ];
          }
          await sender.setParameters(params);
          debugPrint(
              '[WebRTCManager] Applied video sender parameters: maxBitrate=${targetBitrateBps}bps, minBitrate=${minBitrateBps}bps, fps=${_qualityConfig.effectiveFps}, degradation=maintainFramerate');
        }
      }
    } catch (e) {
      debugPrint('[WebRTCManager] Notice: Could not apply sender parameters: $e');
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
          final rawOfferSdp = message.data['sdp'] as String?;
          final optimizedOfferSdp = SdpOptimizer.optimize(
            rawOfferSdp ?? '',
            bitrateKbps: _qualityConfig.effectiveBitrateKbps,
            fps: _qualityConfig.effectiveFps,
            preferH264: _qualityConfig.enableHardwareAcceleration,
          );
          final sdp = RTCSessionDescription(
            optimizedOfferSdp,
            (message.data['type'] as String?) ?? 'offer',
          );
          await _peerConnection!.setRemoteDescription(sdp);
          _isRemoteDescriptionSet = true;
          debugPrint('[WebRTCManager] Set remote description (Offer)');
          await _drainRemoteCandidatesQueue();

          var answer = await _peerConnection!.createAnswer({});
          final optimizedAnswerSdp = SdpOptimizer.optimize(
            answer.sdp ?? '',
            bitrateKbps: _qualityConfig.effectiveBitrateKbps,
            fps: _qualityConfig.effectiveFps,
            preferH264: _qualityConfig.enableHardwareAcceleration,
          );
          answer = RTCSessionDescription(optimizedAnswerSdp, answer.type);
          await _peerConnection!.setLocalDescription(answer);
          debugPrint('[WebRTCManager] Set local description (Answer with optimized SDP)');

          onSignalingMessageReady?.call(SignalingMessage(
            type: SignalingType.answer,
            data: answer.toMap(),
            senderId: 'receiver',
          ));
          break;

        case SignalingType.answer:
          debugPrint('[WebRTCManager] Processing Answer...');
          if (_peerConnection != null) {
            final rawAnswerSdp = message.data['sdp'] as String?;
            final optimizedAnswerSdp = SdpOptimizer.optimize(
              rawAnswerSdp ?? '',
              bitrateKbps: _qualityConfig.effectiveBitrateKbps,
              fps: _qualityConfig.effectiveFps,
              preferH264: _qualityConfig.enableHardwareAcceleration,
            );
            final sdp = RTCSessionDescription(
              optimizedAnswerSdp,
              (message.data['type'] as String?) ?? 'answer',
            );
            await _peerConnection!.setRemoteDescription(sdp);
            _isRemoteDescriptionSet = true;
            debugPrint('[WebRTCManager] Set remote description (Answer) successfully!');
            await _drainRemoteCandidatesQueue();
            await _applySenderParameters();
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
    _peerConnectionState = state;
    debugPrint('[WebRTCManager] PeerConnectionState: $state');
    switch (state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        _status = ConnectionStateStatus.connected;
        _applySenderParameters();
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
    _iceConnectionState = state;
    debugPrint('[WebRTCManager] IceConnectionState: $state');
    switch (state) {
      case RTCIceConnectionState.RTCIceConnectionStateConnected:
      case RTCIceConnectionState.RTCIceConnectionStateCompleted:
        if (_status != ConnectionStateStatus.connected) {
          _status = ConnectionStateStatus.connected;
          _applySenderParameters();
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
    _lastBytesSent = null;
    _lastBytesReceived = null;
    _lastStatsTimestamp = null;

    _statsTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_peerConnection != null && _status == ConnectionStateStatus.connected) {
        try {
          final now = DateTime.now();
          final stats = await _peerConnection!.getStats();
          double currentFps = 0.0;
          double latency = 12.0; // Default typical LAN RTT ms
          int lostPackets = 0;
          String detectedCodec = _qualityConfig.enableHardwareAcceleration
              ? 'H.264 Hardware'
              : 'Software Video';
          int currentBytesSent = 0;
          int currentBytesReceived = 0;
          bool hasOutbound = false;
          bool hasInbound = false;

          for (final report in stats) {
            if (report.type == 'outbound-rtp') {
              hasOutbound = true;
              if (report.values['framesPerSecond'] != null) {
                currentFps = (report.values['framesPerSecond'] as num).toDouble();
              }
              if (report.values['bytesSent'] != null) {
                currentBytesSent += (report.values['bytesSent'] as num).toInt();
              }
              if (report.values['roundTripTime'] != null) {
                latency = ((report.values['roundTripTime'] as num).toDouble()) * 1000.0;
              }
            } else if (report.type == 'inbound-rtp') {
              hasInbound = true;
              if (report.values['framesPerSecond'] != null) {
                currentFps = (report.values['framesPerSecond'] as num).toDouble();
              }
              if (report.values['bytesReceived'] != null) {
                currentBytesReceived += (report.values['bytesReceived'] as num).toInt();
              }
              if (report.values['roundTripTime'] != null) {
                latency = ((report.values['roundTripTime'] as num).toDouble()) * 1000.0;
              }
              if (report.values['packetsLost'] != null) {
                lostPackets = (report.values['packetsLost'] as num).toInt();
              }
            } else if (report.type == 'candidate-pair' || report.type == 'googCandidatePair') {
              if (report.values['currentRoundTripTime'] != null) {
                latency = ((report.values['currentRoundTripTime'] as num).toDouble()) * 1000.0;
              } else if (report.values['roundTripTime'] != null) {
                latency = ((report.values['roundTripTime'] as num).toDouble()) * 1000.0;
              }
              if (!hasOutbound && report.values['bytesSent'] != null) {
                currentBytesSent = (report.values['bytesSent'] as num).toInt();
              }
              if (!hasInbound && report.values['bytesReceived'] != null) {
                currentBytesReceived = (report.values['bytesReceived'] as num).toInt();
              }
            } else if (report.type == 'codec') {
              final mime = report.values['mimeType']?.toString() ?? '';
              if (mime.toUpperCase().contains('H264')) {
                detectedCodec = 'H.264 Hardware';
              } else if (mime.toUpperCase().contains('VP8')) {
                detectedCodec = 'VP8';
              } else if (mime.toUpperCase().contains('VP9')) {
                detectedCodec = 'VP9';
              } else if (mime.toUpperCase().contains('AV1')) {
                detectedCodec = 'AV1';
              }
            }
          }

          // Calculate actual Mbps throughput
          double calculatedBitrateMbps = 0.0;
          if (_lastStatsTimestamp != null) {
            final seconds = now.difference(_lastStatsTimestamp!).inMilliseconds / 1000.0;
            if (seconds > 0) {
              if (hasOutbound && _lastBytesSent != null) {
                final delta = currentBytesSent - _lastBytesSent!;
                if (delta >= 0) {
                  calculatedBitrateMbps = (delta * 8.0) / (seconds * 1000000.0);
                }
              } else if (hasInbound && _lastBytesReceived != null) {
                final delta = currentBytesReceived - _lastBytesReceived!;
                if (delta >= 0) {
                  calculatedBitrateMbps = (delta * 8.0) / (seconds * 1000000.0);
                }
              }
            }
          }

          if (currentBytesSent > 0) _lastBytesSent = currentBytesSent;
          if (currentBytesReceived > 0) _lastBytesReceived = currentBytesReceived;
          _lastStatsTimestamp = now;

          // If currentFps is 0 but stream is connected, fallback to previous or target
          if (currentFps == 0 && _metrics.fps > 0) {
            currentFps = _metrics.fps;
          }

          _metrics = StreamMetrics(
            fps: currentFps,
            latencyMs: latency,
            bitrateMbps: calculatedBitrateMbps > 0
                ? calculatedBitrateMbps
                : (_metrics.bitrateMbps > 0 ? _metrics.bitrateMbps : 0.0),
            packetLossCount: lostPackets,
            codec: detectedCodec,
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
    _peerConnectionState = null;
    _iceConnectionState = null;
    _lastBytesSent = null;
    _lastBytesReceived = null;
    _lastStatsTimestamp = null;
  }

  @override
  void dispose() {
    stopSession();
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.dispose();
  }
}
