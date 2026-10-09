// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Native Display';

  @override
  String get appTagline => 'Leistungsstarke Display-Erweiterung';

  @override
  String get systemReady => 'System bereit';

  @override
  String get displayActive => 'Display aktiv';

  @override
  String get navExtendDisplay => 'Display erweitern';

  @override
  String get navReceiveDisplay => 'Display empfangen';

  @override
  String get navDiagnostics => 'Diagnose';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Sichern';

  @override
  String get disconnect => 'Trennen';

  @override
  String get connecting => 'Verbinden...';

  @override
  String get enabled => 'Aktiviert';

  @override
  String get disabled => 'Deaktiviert';

  @override
  String get senderTitle => 'Display erweitern';

  @override
  String get senderSubtitle =>
      'Erweitere deinen Schreibtisch über WLAN oder LAN mit minimaler Latenz auf ein zweites Display.';

  @override
  String get senderPermissionTitle =>
      'Bildschirmaufnahme-Berechtigung erforderlich';

  @override
  String get senderPermissionMessage =>
      'macOS erfordert die Erlaubnis zur Bildschirmaufnahme, um Displays zu erfassen. Falls kürzlich in den Systemeinstellungen aktiviert, beende Native Display vollständig und starte es neu.';

  @override
  String get senderPermissionButton => 'Zugriff erlauben';

  @override
  String get modeExtend => 'Display erweitern (Virtuell)';

  @override
  String get modeMirror => 'Display oder Fenster spiegeln';

  @override
  String get sectionAvailableReceivers => 'VERFÜGBARE EMPFÄNGER';

  @override
  String get searchingReceivers => 'Suche nach Display-Empfängern...';

  @override
  String get searchingReceiversHint =>
      'Stelle sicher, dass Native Display auf dem Zielcomputer im selben lokalen Netzwerk im Empfangsmodus geöffnet ist.';

  @override
  String get rescanReceivers => 'Netzwerk durchsuchen';

  @override
  String get sectionVirtualConfig => 'KONFIGURATION DES VIRTUELLEN DISPLAYS';

  @override
  String get arrangeMacDisplays => 'Displays in macOS-Einstellungen anordnen';

  @override
  String get targetResolution => 'Zielauflösung';

  @override
  String matchReceiverResolution(int width, int height) {
    return 'Empfänger anpassen ($width×$height)';
  }

  @override
  String get refreshRate => 'Bildwiederholrate';

  @override
  String get hidpiRetinaScaling => 'HiDPI Retina-Skalierung';

  @override
  String get hidpiEnabled => 'Aktiviert (Scharfer Text)';

  @override
  String get hidpiDisabled => 'Deaktiviert (1× Standard-Skalierung)';

  @override
  String get resolutionAuto => 'Ziel-Display anpassen (Auto)';

  @override
  String get resolution1080p => '1080p FHD (1920×1080)';

  @override
  String get resolution1440p => '1440p QHD (2560×1440)';

  @override
  String get resolution4k => '4K UHD (3840×2160)';

  @override
  String get senderSettingsHint =>
      'Auflösung, Bildwiederholrate und Stream-Qualität werden in den Einstellungen verwaltet.';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get selectLanguageTitle => 'Sprache auswählen';

  @override
  String get sectionSourceDisplay => 'DISPLAY ODER FENSTER AUSWÄHLEN';

  @override
  String get noDisplaysFound =>
      'Keine Displays oder Fenster gefunden. Stelle sicher, dass die Berechtigung zur Bildschirmaufnahme erteilt ist.';

  @override
  String get fullScreenDisplay => 'Gesamtes Display';

  @override
  String get appWindow => 'App-Fenster';

  @override
  String displayFallback(String id) {
    return 'Display $id';
  }

  @override
  String startExtend(String name) {
    return 'Auf $name erweitern';
  }

  @override
  String startMirror(String name) {
    return 'Auf $name spiegeln';
  }

  @override
  String get disconnectDisplay => 'Display trennen';

  @override
  String get virtualDisplayPreview => 'VORSCHAU DES VIRTUELLEN DISPLAYS';

  @override
  String get capturePreview => 'VORSCHAU DER LOKALEN AUFNAHME';

  @override
  String get badgeVirtualActive => 'VIRTUELLES DISPLAY AKTIV';

  @override
  String get badgeStreamingActive => 'LIVE-STREAMING';

  @override
  String get statusVirtualActive => 'Virtuelles Display aktiv';

  @override
  String get statusMirrorActive => 'Spiegelung aktiv';

  @override
  String get statusConnecting => 'Display wird verbunden...';

  @override
  String get statusScanning => 'Netzwerk wird gescannt...';

  @override
  String get statusError => 'Verbindungsproblem';

  @override
  String get statusReady => 'Bereit zum Erweitern';

  @override
  String get receiverTitle => 'Display empfangen';

  @override
  String get receiverSubtitle =>
      'Verwende diesen Computer als leistungsstarkes zweites Display.';

  @override
  String get statusListening => 'Wartet im lokalen Netzwerk';

  @override
  String receiverConnectionInfo(int port) {
    return 'Port: $port • Lokale Erkennung aktiv';
  }

  @override
  String get renameDevice => 'Gerät umbenennen';

  @override
  String get renameDeviceTitle => 'Display-Empfänger umbenennen';

  @override
  String get deviceNamePlaceholder => 'Gerätename';

  @override
  String get enterFullscreen => 'Vollbild aktivieren';

  @override
  String get exitFullscreen => 'Vollbild beenden';

  @override
  String get sectionHowToConnect => 'VERBINDUNGSAUFBAU';

  @override
  String get step1Title => 'Öffne Native Display auf deinem Hauptcomputer.';

  @override
  String step2Title(String deviceName) {
    return 'Wähle \"$deviceName\" unter Verfügbare Empfänger aus.';
  }

  @override
  String get step3Title =>
      'Klicke auf Erweitern oder Spiegeln. Das Video wird automatisch mit WebRTC mit minimaler Latenz übertragen.';

  @override
  String get receiverConnectedBadge => 'Verbunden • Display-Stream aktiv';

  @override
  String get windowedMode => 'Fenster';

  @override
  String get fullscreenMode => 'Vollbild';

  @override
  String get diagnosticsTitle => 'Diagnose & Leistung';

  @override
  String get diagnosticsSubtitle =>
      'Echtzeit-Telemetrie, Netzwerklatenz und WebRTC-Pipeline-Metriken.';

  @override
  String get metricFramerate => 'STREAM-BILDRATE';

  @override
  String metricFramerateTarget(int fps) {
    return 'Ziel: $fps FPS';
  }

  @override
  String get metricLatency => 'NETZWERKLATENZ';

  @override
  String get metricLatencyLow => 'Ultra-niedrige Latenz';

  @override
  String get metricLatencyStandby => 'Bereit';

  @override
  String get metricBandwidth => 'BANDBREITENNUTZUNG';

  @override
  String metricBandwidthAllocated(int bitrate) {
    return 'Zugewiesen: $bitrate Mbps';
  }

  @override
  String get metricPacketLoss => 'PAKETVERLUST';

  @override
  String get metricPacketLossNone => 'Keine verlorenen Pakete';

  @override
  String get metricPacketLossDetected => 'Netzwerküberlastung erkannt';

  @override
  String get sectionStreamingPipeline => 'STREAMING-PIPELINE';

  @override
  String get capturePipelineLabel => 'Bildschirmaufnahme-Pipeline';

  @override
  String get capturePipelineMac => 'Apple ScreenCaptureKit (macOS 12.3+)';

  @override
  String get capturePipelineWin => 'Desktop Duplication API (Windows)';

  @override
  String get videoCodecLabel => 'Video-Codec';

  @override
  String get hardwareAccelerationLabel => 'Hardwarebeschleunigung';

  @override
  String get hardwareAccelerationDetails =>
      'Aktiviert (Apple VideoToolbox / NVENC)';

  @override
  String get signalingProtocolLabel => 'Signalisierungsprotokoll';

  @override
  String signalingProtocolDetails(int port) {
    return 'WebSocket JSON-RPC (Port $port)';
  }

  @override
  String get discoveryProtocolLabel => 'Erkennungsprotokoll';

  @override
  String get discoveryProtocolDetails => 'mDNS (Bonjour) + UDP-Multicast';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSubtitle =>
      'Konfiguriere Streaming-Qualität, Netzwerkleistung und Systemintegrationen.';

  @override
  String get sectionLanguage => 'SPRACHE';

  @override
  String get appLanguage => 'App-Sprache';

  @override
  String get languageSystem => 'Systemstandard';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get sectionQualityPreset => 'STREAMING-QUALITÄT';

  @override
  String qualityPresetFooter(int width, int height, int fps, int bitrate) {
    return 'Aktuelles Ziel: $width×$height bei $fps FPS ($bitrate Mbps)';
  }

  @override
  String get preset720p => '720p (30 FPS)';

  @override
  String get preset1080p => '1080p (60 FPS)';

  @override
  String get preset1440p => '1440p (60 FPS)';

  @override
  String get preset4k => '4K (60 FPS)';

  @override
  String get sectionEncoding => 'KODIERUNG & LEISTUNG';

  @override
  String get sectionEncodingFooter =>
      'Hardwarebeschleunigung nutzt Apple VideoToolbox unter macOS und NVENC/QuickSync unter Windows.';

  @override
  String get targetBitrate => 'Ziel-Bitrate';

  @override
  String get hardwareAcceleration => 'Hardwarebeschleunigte Kodierung';

  @override
  String get lowLatencyMode => 'Ultra-niedrige Latenz';

  @override
  String get lowLatencyHelper =>
      'Minimiert Pufferzeiten für verzögerungsfreie Zeigerreaktion.';

  @override
  String get sectionIntegration => 'SYSTEM & EINSTELLUNGEN';

  @override
  String get deviceName => 'Gerätename';

  @override
  String get virtualDisplayToggle => 'Virtuelle Display-Erweiterung';

  @override
  String get virtualDisplayHelper =>
      'Erstellt einen unabhängigen virtuellen Displaybereich anstatt den aktuellen Schreibtisch zu spiegeln.';

  @override
  String get autoConnect => 'Beim Start automatisch verbinden';

  @override
  String get startMinimized =>
      'In Menüleiste oder Infobereich minimiert starten';

  @override
  String trayStatus(String status) {
    return 'Native Display: $status';
  }

  @override
  String get trayOpenWindow => 'Native Display öffnen';

  @override
  String get trayStartStreaming => 'Streaming starten';

  @override
  String get trayStopStreaming => 'Streaming stoppen';

  @override
  String get trayAvailableReceivers => 'Verfügbare Displays:';

  @override
  String get trayQuit => 'Native Display beenden';

  @override
  String get errorSelectReceiverFirst =>
      'Wähle zuerst einen Ziel-Display-Empfänger aus.';

  @override
  String errorSignalingConnection(String error) {
    return 'Signalisierungs-Verbindungsfehler: $error';
  }

  @override
  String get errorPeerConnectionFailed =>
      'WebRTC-Peer-Verbindung konnte nicht aufgebaut werden.';

  @override
  String get errorConnectionDropped => 'Verbindung wurde unerwartet getrennt.';

  @override
  String get errorCreateVirtualDisplay =>
      'Erstellen des nativen virtuellen macOS-Displays fehlgeschlagen.';

  @override
  String errorReceiverServiceStart(String error) {
    return 'Empfängerdienst konnte nicht gestartet werden: $error';
  }

  @override
  String get errorWebRtcNegotiation =>
      'Verbindung verloren oder WebRTC-Aushandlung fehlgeschlagen.';
}
