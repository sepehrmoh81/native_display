// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Native Display';

  @override
  String get appTagline => 'Extensión de pantalla de alto rendimiento';

  @override
  String get systemReady => 'Sistema listo';

  @override
  String get displayActive => 'Pantalla activa';

  @override
  String get navExtendDisplay => 'Extender pantalla';

  @override
  String get navReceiveDisplay => 'Recibir pantalla';

  @override
  String get navDiagnostics => 'Diagnósticos';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get connecting => 'Conectando...';

  @override
  String get enabled => 'Activado';

  @override
  String get disabled => 'Desactivado';

  @override
  String get senderTitle => 'Extender pantalla';

  @override
  String get senderSubtitle =>
      'Extiende tu escritorio a una pantalla secundaria mediante Wi-Fi o red local de baja latencia.';

  @override
  String get senderPermissionTitle =>
      'Se requiere permiso de grabación de pantalla';

  @override
  String get senderPermissionMessage =>
      'macOS requiere autorización de grabación de pantalla para capturar pantallas. Si la concediste recientemente en Ajustes del Sistema, cierra y vuelve a abrir Native Display para que surta efecto.';

  @override
  String get senderPermissionButton => 'Conceder permiso';

  @override
  String get senderMacOnlyTitle => 'Se requiere macOS';

  @override
  String get senderMacOnlyDescription =>
      'La extensión de pantalla actualmente es exclusiva de macOS. En Windows, Native Display funciona como receptor de pantalla secundaria de alto rendimiento.';

  @override
  String get switchToReceiver => 'Cambiar a Recibir pantalla';

  @override
  String get modeExtend => 'Extender pantalla (Virtual)';

  @override
  String get modeMirror => 'Duplicar pantalla o ventana';

  @override
  String get sectionAvailableReceivers => 'RECEPTORES DISPONIBLES';

  @override
  String get searchingReceivers => 'Buscando receptores de pantalla...';

  @override
  String get searchingReceiversHint =>
      'Asegúrate de que Native Display esté abierto en modo Recibir pantalla en el equipo de destino dentro de la misma red local.';

  @override
  String get rescanReceivers => 'Escanear red';

  @override
  String get sectionVirtualConfig => 'CONFIGURACIÓN DE PANTALLA VIRTUAL';

  @override
  String get arrangeMacDisplays => 'Organizar pantallas en Ajustes de macOS';

  @override
  String get targetResolution => 'Resolución de destino';

  @override
  String matchReceiverResolution(int width, int height) {
    return 'Coincidir con receptor ($width×$height)';
  }

  @override
  String get refreshRate => 'Frecuencia de actualización';

  @override
  String get hidpiRetinaScaling => 'Escalado HiDPI Retina';

  @override
  String get hidpiEnabled => 'Activado (Texto nítido)';

  @override
  String get hidpiDisabled => 'Desactivado (Escalado estándar 1×)';

  @override
  String get resolutionAuto => 'Coincidir con pantalla de destino (Auto)';

  @override
  String get resolution1080p => '1080p FHD (1920×1080)';

  @override
  String get resolution1440p => '1440p QHD (2560×1440)';

  @override
  String get resolution4k => '4K UHD (3840×2160)';

  @override
  String get senderSettingsHint =>
      'La resolución, frecuencia de actualización y calidad se gestionan en Ajustes.';

  @override
  String get openSettings => 'Abrir Ajustes';

  @override
  String get selectLanguageTitle => 'Seleccionar idioma';

  @override
  String get sectionSourceDisplay => 'SELECCIONAR PANTALLA O VENTANA';

  @override
  String get noDisplaysFound =>
      'No se encontraron pantallas ni ventanas. Asegúrate de conceder el permiso de grabación de pantalla.';

  @override
  String get fullScreenDisplay => 'Pantalla completa';

  @override
  String get appWindow => 'Ventana de aplicación';

  @override
  String displayFallback(String id) {
    return 'Pantalla $id';
  }

  @override
  String startExtend(String name) {
    return 'Extender a $name';
  }

  @override
  String startMirror(String name) {
    return 'Duplicar a $name';
  }

  @override
  String get disconnectDisplay => 'Desconectar pantalla';

  @override
  String get virtualDisplayPreview => 'VISTA PREVIA DE PANTALLA VIRTUAL';

  @override
  String get capturePreview => 'VISTA PREVIA DE CAPTURA LOCAL';

  @override
  String get badgeVirtualActive => 'PANTALLA VIRTUAL ACTIVA';

  @override
  String get badgeStreamingActive => 'TRANSMISIÓN EN VIVO';

  @override
  String get statusVirtualActive => 'Pantalla virtual activa';

  @override
  String get statusMirrorActive => 'Duplicación activa';

  @override
  String get statusConnecting => 'Conectando pantalla...';

  @override
  String get statusScanning => 'Escaneando red...';

  @override
  String get statusError => 'Problema de conexión';

  @override
  String get statusReady => 'Listo para extender';

  @override
  String get receiverTitle => 'Recibir pantalla';

  @override
  String get receiverSubtitle =>
      'Usa este equipo como pantalla secundaria de alto rendimiento.';

  @override
  String get statusListening => 'A la escucha en red local';

  @override
  String receiverConnectionInfo(int port) {
    return 'Puerto: $port • Detección local activa';
  }

  @override
  String get renameDevice => 'Renombrar dispositivo';

  @override
  String get renameDeviceTitle => 'Renombrar receptor de pantalla';

  @override
  String get deviceNamePlaceholder => 'Nombre del dispositivo';

  @override
  String get enterFullscreen => 'Entrar en pantalla completa';

  @override
  String get exitFullscreen => 'Salir de pantalla completa';

  @override
  String get sectionHowToConnect => 'CÓMO CONECTAR';

  @override
  String get step1Title => 'Abre Native Display en tu ordenador principal.';

  @override
  String step2Title(String deviceName) {
    return 'Selecciona \"$deviceName\" en Receptores disponibles.';
  }

  @override
  String get step3Title =>
      'Haz clic en Extender o Duplicar. El vídeo se transmitirá automáticamente mediante WebRTC de baja latencia.';

  @override
  String get receiverConnectedBadge => 'Conectado • Flujo de pantalla activo';

  @override
  String get windowedMode => 'Ventana';

  @override
  String get fullscreenMode => 'Pantalla completa';

  @override
  String get diagnosticsTitle => 'Diagnóstico y rendimiento';

  @override
  String get diagnosticsSubtitle =>
      'Telemetría en tiempo real, latencia de red y métricas del flujo WebRTC.';

  @override
  String get metricFramerate => 'TASA DE FOTOGRAMAS';

  @override
  String metricFramerateTarget(int fps) {
    return 'Objetivo: $fps FPS';
  }

  @override
  String get metricLatency => 'LATENCIA DE RED';

  @override
  String get metricLatencyLow => 'Latencia ultrabaja';

  @override
  String get metricLatencyStandby => 'En espera';

  @override
  String get metricBandwidth => 'USO DE ANCHO DE BANDA';

  @override
  String metricBandwidthAllocated(int bitrate) {
    return 'Asignado: $bitrate Mbps';
  }

  @override
  String get metricPacketLoss => 'PÉRDIDA DE PAQUETES';

  @override
  String get metricPacketLossNone => 'Sin pérdida de paquetes';

  @override
  String get metricPacketLossDetected => 'Congestión de red detectada';

  @override
  String get sectionStreamingPipeline => 'CANAL DE TRANSMISIÓN';

  @override
  String get capturePipelineLabel => 'Motor de captura de pantalla';

  @override
  String get capturePipelineMac => 'Apple ScreenCaptureKit (macOS 12.3+)';

  @override
  String get capturePipelineWin => 'Desktop Duplication API (Windows)';

  @override
  String get videoCodecLabel => 'Códec de vídeo';

  @override
  String get hardwareAccelerationLabel => 'Aceleración por hardware';

  @override
  String get hardwareAccelerationDetails =>
      'Activado (Apple VideoToolbox / NVENC)';

  @override
  String get signalingProtocolLabel => 'Protocolo de señalización';

  @override
  String signalingProtocolDetails(int port) {
    return 'WebSocket JSON-RPC (Puerto $port)';
  }

  @override
  String get discoveryProtocolLabel => 'Protocolo de detección';

  @override
  String get discoveryProtocolDetails => 'mDNS (Bonjour) + Difusión UDP';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSubtitle =>
      'Configura la calidad de transmisión, el rendimiento de red y las integraciones del sistema.';

  @override
  String get sectionLanguage => 'IDIOMA';

  @override
  String get appLanguage => 'Idioma de la aplicación';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get sectionQualityPreset => 'AJUSTE DE CALIDAD DE TRANSMISIÓN';

  @override
  String qualityPresetFooter(int width, int height, int fps, int bitrate) {
    return 'Objetivo actual: $width×$height a $fps FPS ($bitrate Mbps)';
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
  String get sectionEncoding => 'CODIFICACIÓN Y RENDIMIENTO';

  @override
  String get sectionEncodingFooter =>
      'La aceleración por hardware aprovecha Apple VideoToolbox en macOS y NVENC/QuickSync en Windows.';

  @override
  String get targetBitrate => 'Tasa de bits objetivo';

  @override
  String get hardwareAcceleration => 'Codificación acelerada por hardware';

  @override
  String get lowLatencyMode => 'Modo de latencia ultrabaja';

  @override
  String get lowLatencyHelper =>
      'Minimiza el búfer para una respuesta inmediata del cursor.';

  @override
  String get sectionIntegration => 'SISTEMA Y PREFERENCIAS';

  @override
  String get deviceName => 'Nombre del dispositivo';

  @override
  String get virtualDisplayToggle => 'Extensión de pantalla virtual';

  @override
  String get virtualDisplayHelper =>
      'Crea un espacio de pantalla virtual independiente en lugar de duplicar el escritorio actual.';

  @override
  String get autoConnect => 'Conectar automáticamente al iniciar';

  @override
  String get startMinimized =>
      'Iniciar en barra de menús o bandeja del sistema';

  @override
  String trayStatus(String status) {
    return 'Native Display: $status';
  }

  @override
  String get trayOpenWindow => 'Abrir Native Display';

  @override
  String get trayStartStreaming => 'Iniciar transmisión';

  @override
  String get trayStopStreaming => 'Detener transmisión';

  @override
  String get trayAvailableReceivers => 'Pantallas disponibles:';

  @override
  String get trayQuit => 'Salir de Native Display';

  @override
  String get errorSelectReceiverFirst =>
      'Selecciona primero un receptor de pantalla de destino.';

  @override
  String errorSignalingConnection(String error) {
    return 'Error de conexión de señalización: $error';
  }

  @override
  String get errorPeerConnectionFailed =>
      'No se pudo establecer la conexión WebRTC.';

  @override
  String get errorConnectionDropped =>
      'La conexión se interrumpió inesperadamente.';

  @override
  String get errorCreateVirtualDisplay =>
      'Error al crear la pantalla virtual nativa de macOS.';

  @override
  String errorReceiverServiceStart(String error) {
    return 'No se pudo iniciar el servicio de receptor: $error';
  }

  @override
  String get errorWebRtcNegotiation =>
      'Conexión perdida o error en la negociación WebRTC.';
}
