import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_display/core/constants/app_constants.dart';
import 'package:native_display/core/network/models/peer_device.dart';
import 'package:native_display/core/network/models/signaling_message.dart';
import 'package:native_display/core/theme/liquid_glass.dart';
import 'package:native_display/features/settings/controller/settings_controller.dart';
import 'package:native_display/l10n/app_localizations.dart';

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

    test('manages locale selection', () {
      final controller = SettingsController();
      expect(controller.locale, isNull);

      controller.setLocale(const Locale('es'));
      expect(controller.locale, const Locale('es'));

      controller.setLocale(const Locale('de'));
      expect(controller.locale, const Locale('de'));

      controller.setLocale(null);
      expect(controller.locale, isNull);
    });

    test('manages virtual resolution presets and dimension resolving', () {
      final controller = SettingsController();
      expect(controller.resolutionPreset, VirtualResolutionPreset.auto);

      // Auto mode matches receiver if available
      final (autoW, autoH) = controller.resolveDisplayDimensions(
        receiverWidth: 2560,
        receiverHeight: 1440,
      );
      expect(autoW, 2560);
      expect(autoH, 1440);

      // Auto mode fallbacks to default if receiver is null
      final (defW, defH) = controller.resolveDisplayDimensions();
      expect(defW, 1920);
      expect(defH, 1080);

      // Explicit preset overrides receiver
      controller.setResolutionPreset(VirtualResolutionPreset.uhd4k);
      final (k4W, k4H) = controller.resolveDisplayDimensions(
        receiverWidth: 1280,
        receiverHeight: 720,
      );
      expect(k4W, 3840);
      expect(k4H, 2160);

      controller.setVirtualFps(120.0);
      expect(controller.virtualFps, 120.0);

      controller.setVirtualHiDPI(false);
      expect(controller.virtualHiDPI, false);
    });
  });

  group('Localization & Translation Tests', () {
    test('verifies English, Spanish, and German AppLocalizations', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final es = await AppLocalizations.delegate.load(const Locale('es'));
      final de = await AppLocalizations.delegate.load(const Locale('de'));

      // Check App Title & Tagline
      expect(en.appName, 'Native Display');
      expect(es.appName, 'Native Display');
      expect(de.appName, 'Native Display');

      expect(en.appTagline, 'High-Performance Display Extension');
      expect(es.appTagline, 'Extensión de pantalla de alto rendimiento');
      expect(de.appTagline, 'Leistungsstarke Display-Erweiterung');

      // Check Navigation
      expect(en.navExtendDisplay, 'Extend Display');
      expect(es.navExtendDisplay, 'Extender pantalla');
      expect(de.navExtendDisplay, 'Display erweitern');

      expect(en.navReceiveDisplay, 'Receive Display');
      expect(es.navReceiveDisplay, 'Recibir pantalla');
      expect(de.navReceiveDisplay, 'Display empfangen');

      expect(en.navDiagnostics, 'Diagnostics');
      expect(es.navDiagnostics, 'Diagnósticos');
      expect(de.navDiagnostics, 'Diagnose');

      expect(en.navSettings, 'Settings');
      expect(es.navSettings, 'Ajustes');
      expect(de.navSettings, 'Einstellungen');

      // Check Receiver steps & parameterized strings
      expect(en.step1Title, 'Open Native Display on your primary computer.');
      expect(es.step1Title, 'Abre Native Display en tu ordenador principal.');
      expect(de.step1Title, 'Öffne Native Display auf deinem Hauptcomputer.');

      expect(en.step2Title('Desktop-PC'), 'Select "Desktop-PC" under Available Receivers.');
      expect(es.step2Title('Desktop-PC'), 'Selecciona "Desktop-PC" en Receptores disponibles.');
      expect(de.step2Title('Desktop-PC'), 'Wähle "Desktop-PC" unter Verfügbare Empfänger aus.');

      // Check Sender actions & parameters
      expect(en.startExtend('Windows PC'), 'Extend to Windows PC');
      expect(es.startExtend('Windows PC'), 'Extender a Windows PC');
      expect(de.startExtend('Windows PC'), 'Auf Windows PC erweitern');

      expect(en.matchReceiverResolution(1920, 1080), 'Match Receiver (1920×1080)');
      expect(es.matchReceiverResolution(1920, 1080), 'Coincidir con receptor (1920×1080)');
      expect(de.matchReceiverResolution(1920, 1080), 'Empfänger anpassen (1920×1080)');

      expect(en.extendMacOnlyNotice, contains('macOS only'));
      expect(es.extendMacOnlyNotice, contains('macOS'));
      expect(de.extendMacOnlyNotice, contains('macOS'));
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

    testWidgets('renders localized CupertinoApp in Spanish and German', (tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: _TestLocalizedWidget.build,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Ajustes'), findsOneWidget);
      expect(find.text('Extender pantalla'), findsOneWidget);
    });
  });
}

class _TestLocalizedWidget {
  static Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CupertinoPageScaffold(
      child: Column(
        children: [
          Text(l10n.navSettings),
          Text(l10n.navExtendDisplay),
        ],
      ),
    );
  }
}
