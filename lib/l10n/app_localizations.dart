import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Native Display'**
  String get appName;

  /// App subtitle displayed in the sidebar
  ///
  /// In en, this message translates to:
  /// **'High-Performance Display Extension'**
  String get appTagline;

  /// Status text when app is idle and ready
  ///
  /// In en, this message translates to:
  /// **'System Ready'**
  String get systemReady;

  /// Status text when display stream is active
  ///
  /// In en, this message translates to:
  /// **'Display Active'**
  String get displayActive;

  /// Navigation item for extending display
  ///
  /// In en, this message translates to:
  /// **'Extend Display'**
  String get navExtendDisplay;

  /// Navigation item for receiving display
  ///
  /// In en, this message translates to:
  /// **'Receive Display'**
  String get navReceiveDisplay;

  /// Navigation item for diagnostics
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get navDiagnostics;

  /// Navigation item for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Disconnect button label
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// Connecting status label
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// Enabled status text
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// Disabled status text
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// Title of the sender screen
  ///
  /// In en, this message translates to:
  /// **'Extend Display'**
  String get senderTitle;

  /// Subtitle explaining the sender screen purpose
  ///
  /// In en, this message translates to:
  /// **'Extend your desktop to a secondary display over low-latency Wi-Fi or LAN.'**
  String get senderSubtitle;

  /// Permission alert title
  ///
  /// In en, this message translates to:
  /// **'Screen Recording Permission Required'**
  String get senderPermissionTitle;

  /// Permission alert description
  ///
  /// In en, this message translates to:
  /// **'macOS requires screen recording authorization to capture displays. If recently granted in System Settings, quit and relaunch Native Display for changes to take effect.'**
  String get senderPermissionMessage;

  /// Button to request screen recording permission
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get senderPermissionButton;

  /// Title when Sender screen is opened on non-macOS
  ///
  /// In en, this message translates to:
  /// **'macOS Required'**
  String get senderMacOnlyTitle;

  /// Description explaining why Sender is disabled on Windows
  ///
  /// In en, this message translates to:
  /// **'Display extension is currently exclusive to macOS. On Windows, Native Display functions as a high-performance secondary display receiver.'**
  String get senderMacOnlyDescription;

  /// Button to switch to Receiver mode on Windows
  ///
  /// In en, this message translates to:
  /// **'Switch to Receive Display'**
  String get switchToReceiver;

  /// Sender mode segment for virtual display extension
  ///
  /// In en, this message translates to:
  /// **'Extend Display (Virtual)'**
  String get modeExtend;

  /// Sender mode segment for screen/window mirroring
  ///
  /// In en, this message translates to:
  /// **'Mirror Display or Window'**
  String get modeMirror;

  /// Section header for discovered display receivers
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE RECEIVERS'**
  String get sectionAvailableReceivers;

  /// Empty state title when searching for receivers
  ///
  /// In en, this message translates to:
  /// **'Searching for Display Receivers...'**
  String get searchingReceivers;

  /// Empty state guidance text
  ///
  /// In en, this message translates to:
  /// **'Ensure Native Display is open in Receive Display mode on your target computer on the same local network.'**
  String get searchingReceiversHint;

  /// Button to trigger network rescan
  ///
  /// In en, this message translates to:
  /// **'Scan Network'**
  String get rescanReceivers;

  /// Section header for virtual display settings
  ///
  /// In en, this message translates to:
  /// **'VIRTUAL DISPLAY CONFIGURATION'**
  String get sectionVirtualConfig;

  /// Link button to open macOS display arrangement
  ///
  /// In en, this message translates to:
  /// **'Arrange Displays in macOS Settings'**
  String get arrangeMacDisplays;

  /// Label for virtual display resolution
  ///
  /// In en, this message translates to:
  /// **'Target Resolution'**
  String get targetResolution;

  /// Option to match receiver screen resolution
  ///
  /// In en, this message translates to:
  /// **'Match Receiver ({width}×{height})'**
  String matchReceiverResolution(int width, int height);

  /// Label for refresh rate setting
  ///
  /// In en, this message translates to:
  /// **'Refresh Rate'**
  String get refreshRate;

  /// Label for HiDPI switch
  ///
  /// In en, this message translates to:
  /// **'HiDPI Retina Scaling'**
  String get hidpiRetinaScaling;

  /// HiDPI enabled status text
  ///
  /// In en, this message translates to:
  /// **'Enabled (Sharp text)'**
  String get hidpiEnabled;

  /// HiDPI disabled status text
  ///
  /// In en, this message translates to:
  /// **'Disabled (Standard 1× scaling)'**
  String get hidpiDisabled;

  /// Virtual resolution preset to match receiver automatically
  ///
  /// In en, this message translates to:
  /// **'Match Target Display (Auto)'**
  String get resolutionAuto;

  /// 1080p FHD resolution option
  ///
  /// In en, this message translates to:
  /// **'1080p FHD (1920×1080)'**
  String get resolution1080p;

  /// 1440p QHD resolution option
  ///
  /// In en, this message translates to:
  /// **'1440p QHD (2560×1440)'**
  String get resolution1440p;

  /// 4K UHD resolution option
  ///
  /// In en, this message translates to:
  /// **'4K UHD (3840×2160)'**
  String get resolution4k;

  /// Hint on the sender tab pointing to settings
  ///
  /// In en, this message translates to:
  /// **'Virtual display resolution, refresh rate, and quality presets are managed in Settings.'**
  String get senderSettingsHint;

  /// Button to navigate to settings
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Title of language selection sheet
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageTitle;

  /// Header for mirror source selection
  ///
  /// In en, this message translates to:
  /// **'SELECT DISPLAY OR WINDOW'**
  String get sectionSourceDisplay;

  /// Warning message when no display sources found
  ///
  /// In en, this message translates to:
  /// **'No displays or windows found. Ensure screen recording permission is granted.'**
  String get noDisplaysFound;

  /// Label for full screen capture source
  ///
  /// In en, this message translates to:
  /// **'Full Screen Display'**
  String get fullScreenDisplay;

  /// Label for window capture source
  ///
  /// In en, this message translates to:
  /// **'Application Window'**
  String get appWindow;

  /// Fallback name for a display
  ///
  /// In en, this message translates to:
  /// **'Display {id}'**
  String displayFallback(String id);

  /// Action button to start extending desktop
  ///
  /// In en, this message translates to:
  /// **'Extend to {name}'**
  String startExtend(String name);

  /// Action button to start mirroring
  ///
  /// In en, this message translates to:
  /// **'Mirror to {name}'**
  String startMirror(String name);

  /// Action button to disconnect display
  ///
  /// In en, this message translates to:
  /// **'Disconnect Display'**
  String get disconnectDisplay;

  /// Header for live virtual display preview
  ///
  /// In en, this message translates to:
  /// **'VIRTUAL DISPLAY PREVIEW'**
  String get virtualDisplayPreview;

  /// Header for live mirror capture preview
  ///
  /// In en, this message translates to:
  /// **'LOCAL CAPTURE PREVIEW'**
  String get capturePreview;

  /// Badge overlay for virtual display
  ///
  /// In en, this message translates to:
  /// **'VIRTUAL DISPLAY ACTIVE'**
  String get badgeVirtualActive;

  /// Badge overlay for live stream
  ///
  /// In en, this message translates to:
  /// **'LIVE STREAMING'**
  String get badgeStreamingActive;

  /// Status badge for active virtual display
  ///
  /// In en, this message translates to:
  /// **'Virtual Display Active'**
  String get statusVirtualActive;

  /// Status badge for active mirror display
  ///
  /// In en, this message translates to:
  /// **'Mirroring Active'**
  String get statusMirrorActive;

  /// Status badge while connecting
  ///
  /// In en, this message translates to:
  /// **'Connecting Display...'**
  String get statusConnecting;

  /// Status badge while scanning LAN
  ///
  /// In en, this message translates to:
  /// **'Scanning Network...'**
  String get statusScanning;

  /// Status badge on connection error
  ///
  /// In en, this message translates to:
  /// **'Connection Issue'**
  String get statusError;

  /// Status badge when idle
  ///
  /// In en, this message translates to:
  /// **'Ready to Extend'**
  String get statusReady;

  /// Title of the receiver screen
  ///
  /// In en, this message translates to:
  /// **'Receive Display'**
  String get receiverTitle;

  /// Subtitle explaining receiver purpose
  ///
  /// In en, this message translates to:
  /// **'Use this computer as a high-performance secondary display.'**
  String get receiverSubtitle;

  /// Receiver status pill when listening
  ///
  /// In en, this message translates to:
  /// **'Listening on Local Network'**
  String get statusListening;

  /// Network info under device name
  ///
  /// In en, this message translates to:
  /// **'Port: {port} • Local Discovery Active'**
  String receiverConnectionInfo(int port);

  /// Button to rename receiver
  ///
  /// In en, this message translates to:
  /// **'Rename Device'**
  String get renameDevice;

  /// Title of rename dialog
  ///
  /// In en, this message translates to:
  /// **'Rename Display Receiver'**
  String get renameDeviceTitle;

  /// Placeholder for device name input
  ///
  /// In en, this message translates to:
  /// **'Device Name'**
  String get deviceNamePlaceholder;

  /// Button to enter fullscreen
  ///
  /// In en, this message translates to:
  /// **'Enter Fullscreen'**
  String get enterFullscreen;

  /// Button to exit fullscreen
  ///
  /// In en, this message translates to:
  /// **'Exit Fullscreen'**
  String get exitFullscreen;

  /// Section header for connection steps
  ///
  /// In en, this message translates to:
  /// **'HOW TO CONNECT'**
  String get sectionHowToConnect;

  /// First connection step
  ///
  /// In en, this message translates to:
  /// **'Open Native Display on your primary computer.'**
  String get step1Title;

  /// Second connection step
  ///
  /// In en, this message translates to:
  /// **'Select \"{deviceName}\" under Available Receivers.'**
  String step2Title(String deviceName);

  /// Third connection step
  ///
  /// In en, this message translates to:
  /// **'Click Extend or Mirror. Video will stream automatically with low-latency WebRTC.'**
  String get step3Title;

  /// Overlay status banner text when streaming
  ///
  /// In en, this message translates to:
  /// **'Connected • Display Stream Active'**
  String get receiverConnectedBadge;

  /// Overlay button to restore windowed view
  ///
  /// In en, this message translates to:
  /// **'Windowed'**
  String get windowedMode;

  /// Overlay button to maximize to fullscreen
  ///
  /// In en, this message translates to:
  /// **'Full Screen'**
  String get fullscreenMode;

  /// Title of diagnostics view
  ///
  /// In en, this message translates to:
  /// **'Diagnostics & Performance'**
  String get diagnosticsTitle;

  /// Subtitle of diagnostics view
  ///
  /// In en, this message translates to:
  /// **'Real-time stream telemetry, network latency, and WebRTC pipeline metrics.'**
  String get diagnosticsSubtitle;

  /// Metric card title for FPS
  ///
  /// In en, this message translates to:
  /// **'STREAM FRAMERATE'**
  String get metricFramerate;

  /// Framerate target subtitle
  ///
  /// In en, this message translates to:
  /// **'Target: {fps} FPS'**
  String metricFramerateTarget(int fps);

  /// Metric card title for latency
  ///
  /// In en, this message translates to:
  /// **'NETWORK LATENCY'**
  String get metricLatency;

  /// Latency subtitle when connected and low
  ///
  /// In en, this message translates to:
  /// **'Ultra-Low Latency'**
  String get metricLatencyLow;

  /// Latency subtitle when idle
  ///
  /// In en, this message translates to:
  /// **'Standby'**
  String get metricLatencyStandby;

  /// Metric card title for bandwidth
  ///
  /// In en, this message translates to:
  /// **'BANDWIDTH USAGE'**
  String get metricBandwidth;

  /// Bandwidth allocated subtitle
  ///
  /// In en, this message translates to:
  /// **'Allocated: {bitrate} Mbps'**
  String metricBandwidthAllocated(int bitrate);

  /// Metric card title for packet loss
  ///
  /// In en, this message translates to:
  /// **'PACKET LOSS'**
  String get metricPacketLoss;

  /// Packet loss subtitle when zero
  ///
  /// In en, this message translates to:
  /// **'Zero Dropped Packets'**
  String get metricPacketLossNone;

  /// Packet loss subtitle when packets are dropped
  ///
  /// In en, this message translates to:
  /// **'Network Congestion Detected'**
  String get metricPacketLossDetected;

  /// Section header for pipeline details
  ///
  /// In en, this message translates to:
  /// **'STREAMING PIPELINE'**
  String get sectionStreamingPipeline;

  /// Pipeline detail label for capture engine
  ///
  /// In en, this message translates to:
  /// **'Screen Capture Pipeline'**
  String get capturePipelineLabel;

  /// Pipeline detail value for macOS capture
  ///
  /// In en, this message translates to:
  /// **'Apple ScreenCaptureKit (macOS 12.3+)'**
  String get capturePipelineMac;

  /// Pipeline detail value for Windows capture
  ///
  /// In en, this message translates to:
  /// **'Desktop Duplication API (Windows)'**
  String get capturePipelineWin;

  /// Pipeline detail label for codec
  ///
  /// In en, this message translates to:
  /// **'Video Codec'**
  String get videoCodecLabel;

  /// Pipeline detail label for hardware encoding
  ///
  /// In en, this message translates to:
  /// **'Hardware Acceleration'**
  String get hardwareAccelerationLabel;

  /// Pipeline detail value when hardware acceleration is active
  ///
  /// In en, this message translates to:
  /// **'Enabled (Apple VideoToolbox / NVENC)'**
  String get hardwareAccelerationDetails;

  /// Pipeline detail label for signaling
  ///
  /// In en, this message translates to:
  /// **'Signaling Protocol'**
  String get signalingProtocolLabel;

  /// Pipeline detail value for signaling protocol
  ///
  /// In en, this message translates to:
  /// **'WebSocket JSON-RPC (Port {port})'**
  String signalingProtocolDetails(int port);

  /// Pipeline detail label for discovery
  ///
  /// In en, this message translates to:
  /// **'Discovery Protocol'**
  String get discoveryProtocolLabel;

  /// Pipeline detail value for discovery
  ///
  /// In en, this message translates to:
  /// **'mDNS (Bonjour) + UDP Multicast'**
  String get discoveryProtocolDetails;

  /// Title of settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Subtitle of settings screen
  ///
  /// In en, this message translates to:
  /// **'Configure display streaming quality, network performance, and platform integrations.'**
  String get settingsSubtitle;

  /// Section header for language settings
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get sectionLanguage;

  /// Label for language picker
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// System language option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageSystem;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// German language option
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// Section header for stream quality preset
  ///
  /// In en, this message translates to:
  /// **'STREAMING QUALITY PRESET'**
  String get sectionQualityPreset;

  /// Footer displaying active preset specifications
  ///
  /// In en, this message translates to:
  /// **'Current Target: {width}×{height} @ {fps} FPS ({bitrate} Mbps)'**
  String qualityPresetFooter(int width, int height, int fps, int bitrate);

  /// 720p preset label
  ///
  /// In en, this message translates to:
  /// **'720p (30 FPS)'**
  String get preset720p;

  /// 1080p preset label
  ///
  /// In en, this message translates to:
  /// **'1080p (60 FPS)'**
  String get preset1080p;

  /// 1440p preset label
  ///
  /// In en, this message translates to:
  /// **'1440p (60 FPS)'**
  String get preset1440p;

  /// 4K preset label
  ///
  /// In en, this message translates to:
  /// **'4K (60 FPS)'**
  String get preset4k;

  /// Section header for encoding settings
  ///
  /// In en, this message translates to:
  /// **'ENCODING & PERFORMANCE'**
  String get sectionEncoding;

  /// Footer explaining hardware encoding acceleration
  ///
  /// In en, this message translates to:
  /// **'Hardware acceleration leverages Apple VideoToolbox on macOS and NVENC/QuickSync on Windows.'**
  String get sectionEncodingFooter;

  /// Label for target bitrate slider
  ///
  /// In en, this message translates to:
  /// **'Target Bitrate'**
  String get targetBitrate;

  /// Label for hardware acceleration switch
  ///
  /// In en, this message translates to:
  /// **'Hardware Accelerated Encoding'**
  String get hardwareAcceleration;

  /// Label for low latency switch
  ///
  /// In en, this message translates to:
  /// **'Ultra-Low Latency Mode'**
  String get lowLatencyMode;

  /// Helper note for low latency mode
  ///
  /// In en, this message translates to:
  /// **'Minimizes buffering for instant cursor responsiveness.'**
  String get lowLatencyHelper;

  /// Section header for system integration settings
  ///
  /// In en, this message translates to:
  /// **'SYSTEM & PREFERENCES'**
  String get sectionIntegration;

  /// Label for device name setting
  ///
  /// In en, this message translates to:
  /// **'Device Name'**
  String get deviceName;

  /// Label for virtual display setting toggle
  ///
  /// In en, this message translates to:
  /// **'Virtual Display Extension'**
  String get virtualDisplayToggle;

  /// Helper text explaining virtual display extension
  ///
  /// In en, this message translates to:
  /// **'Creates an independent virtual display space instead of mirroring the current desktop.'**
  String get virtualDisplayHelper;

  /// Label for auto-connect setting
  ///
  /// In en, this message translates to:
  /// **'Auto-Connect on Launch'**
  String get autoConnect;

  /// Label for start minimized setting
  ///
  /// In en, this message translates to:
  /// **'Start in Menu Bar or System Tray'**
  String get startMinimized;

  /// Tray menu status header
  ///
  /// In en, this message translates to:
  /// **'Native Display: {status}'**
  String trayStatus(String status);

  /// Tray menu item to show window
  ///
  /// In en, this message translates to:
  /// **'Open Native Display'**
  String get trayOpenWindow;

  /// Tray menu item to start streaming
  ///
  /// In en, this message translates to:
  /// **'Start Streaming'**
  String get trayStartStreaming;

  /// Tray menu item to stop streaming
  ///
  /// In en, this message translates to:
  /// **'Stop Streaming'**
  String get trayStopStreaming;

  /// Tray menu section header for available displays
  ///
  /// In en, this message translates to:
  /// **'Available Displays:'**
  String get trayAvailableReceivers;

  /// Tray menu item to quit app
  ///
  /// In en, this message translates to:
  /// **'Quit Native Display'**
  String get trayQuit;

  /// Error when streaming is initiated without receiver
  ///
  /// In en, this message translates to:
  /// **'Please select a target display receiver first.'**
  String get errorSelectReceiverFirst;

  /// Error on signaling websocket failure
  ///
  /// In en, this message translates to:
  /// **'Signaling connection error: {error}'**
  String errorSignalingConnection(String error);

  /// Error on WebRTC failure
  ///
  /// In en, this message translates to:
  /// **'WebRTC peer connection failed to establish.'**
  String get errorPeerConnectionFailed;

  /// Error on sudden disconnect
  ///
  /// In en, this message translates to:
  /// **'Connection dropped unexpectedly.'**
  String get errorConnectionDropped;

  /// Error when virtual display creation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create native macOS virtual display.'**
  String get errorCreateVirtualDisplay;

  /// Error when receiver service fails to start
  ///
  /// In en, this message translates to:
  /// **'Could not start receiver service: {error}'**
  String errorReceiverServiceStart(String error);

  /// Error on receiver WebRTC loss
  ///
  /// In en, this message translates to:
  /// **'Connection lost or WebRTC negotiation failed.'**
  String get errorWebRtcNegotiation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
