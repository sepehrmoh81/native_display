import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_display/core/constants/app_constants.dart';
import 'package:native_display/core/network/models/peer_device.dart';
import 'package:native_display/core/network/models/signaling_message.dart';
import 'package:native_display/core/theme/liquid_glass.dart';
import 'package:native_display/features/settings/controller/settings_controller.dart';

void main() {
  group('SignalingMessage Tests', () {
    test('serializes and deserializes Offer message correctly', () {
      const msg = SignalingMessage(
        type: SignalingType.offer,
        data: {'sdp': 'v=0\r\no=...'},
        senderId: 'mac-sender',
      );

      final encoded = msg.encode();
      final decoded = SignalingMessage.decode(encoded);

      expect(decoded.type, SignalingType.offer);
      expect(decoded.data['sdp'], 'v=0\r\no=...');
      expect(decoded.senderId, 'mac-sender');
    });

    test('serializes and deserializes Candidate message correctly', () {
      const msg = SignalingMessage(
        type: SignalingType.candidate,
        data: {'candidate': 'candidate:1 1 UDP ...', 'sdpMLineIndex': 0},
        senderId: 'windows-receiver',
      );

      final encoded = msg.encode();
      final decoded = SignalingMessage.decode(encoded);

      expect(decoded.type, SignalingType.candidate);
      expect(decoded.data['sdpMLineIndex'], 0);
    });
  });

  group('PeerDevice Tests', () {
    test('correctly decodes PeerDevice JSON', () {
      final device = PeerDevice(
        id: 'win-desktop-1',
        name: 'Living Room PC',
        host: '192.168.1.150',
        port: 8989,
        mode: AppMode.receiver,
        platform: DevicePlatform.windows,
        screenWidth: 2560,
        screenHeight: 1440,
        refreshRate: 144,
      );

      final encoded = device.encode();
      final decoded = PeerDevice.decode(encoded);

      expect(decoded.name, 'Living Room PC');
      expect(decoded.host, '192.168.1.150');
      expect(decoded.mode, AppMode.receiver);
      expect(decoded.platform, DevicePlatform.windows);
      expect(decoded.screenWidth, 2560);
      expect(decoded.refreshRate, 144);
      expect(decoded.endpoint, 'ws://192.168.1.150:8989/ws');
    });
  });

  group('SettingsController Tests', () {
    test('updates quality preset and propagates bitrate and fps', () {
      final controller = SettingsController();
      expect(controller.qualityConfig.preset, StreamQualityPreset.balanced1080p60);

      controller.updatePreset(StreamQualityPreset.fidelity1440p60);
      expect(controller.qualityConfig.preset, StreamQualityPreset.fidelity1440p60);
      expect(controller.qualityConfig.width, 2560);
      expect(controller.qualityConfig.height, 1440);
      expect(controller.qualityConfig.effectiveBitrateKbps, 25000);
    });

    test('toggles hardware acceleration and low latency', () {
      final controller = SettingsController();
      expect(controller.qualityConfig.enableHardwareAcceleration, true);

      controller.toggleHardwareAcceleration(false);
      expect(controller.qualityConfig.enableHardwareAcceleration, false);

      controller.toggleLowLatency(false);
      expect(controller.qualityConfig.lowLatencyMode, false);
    });
  });

  group('UI & Cupertino Widget Tests', () {
    testWidgets('renders LiquidGlassSurface properly', (tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: LiquidGlassSurface(
                child: Text('Glass Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Glass Content'), findsOneWidget);
    });
  });
}
