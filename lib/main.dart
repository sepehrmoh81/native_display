import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:window_manager/window_manager.dart';
import 'core/network/discovery_service.dart';
import 'core/theme/apple_theme.dart';
import 'core/theme/liquid_glass.dart';
import 'core/tray/tray_controller.dart';
import 'core/webrtc/webrtc_manager.dart';
import 'features/diagnostics/view/diagnostics_view.dart';
import 'features/receiver/controller/receiver_controller.dart';
import 'features/receiver/view/receiver_view.dart';
import 'features/sender/controller/sender_controller.dart';
import 'features/sender/view/sender_view.dart';
import 'features/settings/controller/settings_controller.dart';
import 'features/settings/view/settings_view.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Desktop window customization
  if (Platform.isMacOS || Platform.isWindows) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(1080, 720),
      minimumSize: Size(800, 560),
      center: true,
      backgroundColor: CupertinoColors.transparent,
      skipTaskbar: false,
      title: 'Native Display',
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Initialize WebRTC managers separately for Sender and Receiver
  final senderWebRTCManager = WebRTCManager();
  await senderWebRTCManager.initialize();

  final receiverWebRTCManager = WebRTCManager();
  await receiverWebRTCManager.initialize();

  // Initialize Network & Controllers
  final discoveryService = DiscoveryService();
  final settingsController = SettingsController();
  final senderController = SenderController(
    discoveryService: discoveryService,
    webrtcManager: senderWebRTCManager,
    settingsController: settingsController,
  );
  final receiverController = ReceiverController(
    discoveryService: discoveryService,
    webrtcManager: receiverWebRTCManager,
  );

  // Initialize Tray / Menu Bar Extra
  if (Platform.isMacOS || Platform.isWindows) {
    await TrayController.instance.initialize(
      onOpenMainWindow: () async {
        await windowManager.show();
        await windowManager.focus();
      },
      onToggleStream: () {
        if (senderController.status == SenderStatus.streaming) {
          senderController.stopStreaming();
        } else {
          senderController.startStreaming();
        }
      },
      onQuit: () {
        senderController.dispose();
        receiverController.dispose();
        senderWebRTCManager.dispose();
        receiverWebRTCManager.dispose();
      },
    );
  }

  runApp(NativeDisplayApp(
    discoveryService: discoveryService,
    senderController: senderController,
    receiverController: receiverController,
    settingsController: settingsController,
  ));
}

class NativeDisplayApp extends StatelessWidget {
  final DiscoveryService discoveryService;
  final SenderController senderController;
  final ReceiverController receiverController;
  final SettingsController settingsController;

  const NativeDisplayApp({
    super.key,
    required this.discoveryService,
    required this.senderController,
    required this.receiverController,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (context, _) {
        return CupertinoApp(
          title: 'Native Display',
          debugShowCheckedModeBanner: false,
          locale: settingsController.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: CupertinoThemeData(
            primaryColor: AppleTheme.systemBlue,
            scaffoldBackgroundColor: AppleTheme.systemBackground,
            barBackgroundColor: CupertinoColors.transparent,
            textTheme: CupertinoTextThemeData(
              textStyle: AppleTheme.body.copyWith(color: CupertinoColors.label),
            ),
          ),
          home: MainShellView(
            discoveryService: discoveryService,
            senderController: senderController,
            receiverController: receiverController,
            settingsController: settingsController,
          ),
        );
      },
    );
  }
}

enum NavigationItem {
  sender(CupertinoIcons.macwindow),
  receiver(CupertinoIcons.device_desktop),
  diagnostics(CupertinoIcons.speedometer),
  settings(CupertinoIcons.gear_alt);

  final IconData icon;
  const NavigationItem(this.icon);

  String getTitle(AppLocalizations l10n) {
    return switch (this) {
      NavigationItem.sender => l10n.navExtendDisplay,
      NavigationItem.receiver => l10n.navReceiveDisplay,
      NavigationItem.diagnostics => l10n.navDiagnostics,
      NavigationItem.settings => l10n.navSettings,
    };
  }
}

class MainShellView extends StatefulWidget {
  final DiscoveryService discoveryService;
  final SenderController senderController;
  final ReceiverController receiverController;
  final SettingsController settingsController;
  final bool? isMacOverride;

  const MainShellView({
    super.key,
    required this.discoveryService,
    required this.senderController,
    required this.receiverController,
    required this.settingsController,
    this.isMacOverride,
  });

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  late NavigationItem _selectedNav;

  bool get _isMac => widget.isMacOverride ?? Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    // Default to Sender on macOS, Receiver on Windows/others
    _selectedNav = _isMac ? NavigationItem.sender : NavigationItem.receiver;
    widget.senderController.addListener(_onStateUpdate);
    widget.receiverController.addListener(_onStateUpdate);
  }

  @override
  void dispose() {
    widget.senderController.removeListener(_onStateUpdate);
    widget.receiverController.removeListener(_onStateUpdate);
    super.dispose();
  }

  void _onStateUpdate() {
    if (mounted) setState(() {});
  }

  void _onSelectNav(NavigationItem item) {
    if (item == NavigationItem.sender && !_isMac) return;
    if (_selectedNav == item) return;
    setState(() => _selectedNav = item);
    if (!Platform.isWindows) {
      if (item == NavigationItem.receiver) {
        widget.receiverController.startListening();
      } else {
        widget.receiverController.stopListening();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isFullscreen = widget.receiverController.isFullscreen;

    if (isFullscreen) {
      // Fullscreen mode: HIDE sidebar, hide tab bar, fill 100% of the display
      return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.black,
        child: _buildContent(_selectedNav),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;

        if (isCompact) {
          // Compact / Mobile Layout: Cupertino Tab Bar
          final navItems = NavigationItem.values
              .where((item) => item != NavigationItem.sender || Platform.isMacOS)
              .toList();
          final currentIndex = navItems.indexOf(_selectedNav);

          return CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              currentIndex: currentIndex >= 0 ? currentIndex : 0,
              onTap: (index) => _onSelectNav(navItems[index]),
              items: navItems
                  .map((item) => BottomNavigationBarItem(
                        icon: Icon(item.icon),
                        label: item.getTitle(l10n),
                      ))
                  .toList(),
            ),
            tabBuilder: (context, index) {
              return CupertinoPageScaffold(
                child: SafeArea(
                  child: _buildContent(navItems[index]),
                ),
              );
            },
          );
        }

        // Desktop Split View (Sidebar + Content Pane)
        return CupertinoPageScaffold(
          child: Row(
            children: [
              // Liquid Glass Functional Layer: Sidebar
              SizedBox(
                width: 240,
                child: LiquidGlassSurface(
                  variant: LiquidGlassVariant.regular,
                  borderRadius: 0,
                  border: Border(
                    right: BorderSide(
                      color: CupertinoDynamicColor.resolve(
                        AppleTheme.separator,
                        context,
                      ),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSidebarHeader(context, l10n),
                      const SizedBox(height: AppleTheme.spacing12),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppleTheme.spacing12,
                          ),
                          children: NavigationItem.values
                              .map((item) => _buildSidebarItem(context, item, l10n))
                              .toList(),
                        ),
                      ),
                      _buildSidebarFooter(context, l10n),
                    ],
                  ),
                ),
              ),

              // Detail Content Pane
              Expanded(
                child: Container(
                  color: CupertinoDynamicColor.resolve(
                    AppleTheme.systemBackground,
                    context,
                  ),
                  child: SafeArea(
                    child: _buildContent(_selectedNav),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppleTheme.spacing16,
        top: AppleTheme.spacing20,
        right: AppleTheme.spacing16,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
            ),
            child: const Icon(
              CupertinoIcons.macwindow,
              color: CupertinoColors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: AppleTheme.spacing12),
          Expanded(
            child: Text(
              l10n.appName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: AppleTheme.resolvedLabel(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context,
    NavigationItem item,
    AppLocalizations l10n,
  ) {
    final isSelected = _selectedNav == item;
    final isSupported = item != NavigationItem.sender || _isMac;

    final itemWidget = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: MouseRegion(
        cursor: isSupported ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: GestureDetector(
          onTap: isSupported ? () => _onSelectNav(item) : null,
          child: Opacity(
            opacity: isSupported ? 1.0 : 0.38,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppleTheme.spacing12,
                vertical: AppleTheme.spacing8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? CupertinoDynamicColor.resolve(
                        AppleTheme.systemBlue.withValues(alpha: 0.14),
                        context,
                      )
                    : CupertinoColors.transparent,
                borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 18,
                    color: isSelected
                        ? AppleTheme.systemBlue
                        : CupertinoDynamicColor.resolve(
                            AppleTheme.secondaryLabel,
                            context,
                          ),
                  ),
                  const SizedBox(width: AppleTheme.spacing12),
                  Expanded(
                    child: Text(
                      item.getTitle(l10n),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppleTheme.systemBlue
                            : CupertinoDynamicColor.resolve(
                                AppleTheme.label,
                                context,
                              ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isSupported)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: CupertinoDynamicColor.resolve(
                          AppleTheme.tertiarySystemFill,
                          context,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppleTheme.radiusSmall),
                      ),
                      child: Text(
                        'macOS',
                        style: AppleTheme.caption.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppleTheme.resolvedTertiaryLabel(context),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return itemWidget;
  }

  Widget _buildSidebarFooter(BuildContext context, AppLocalizations l10n) {
    final isConnected =
        widget.senderController.webrtcManager.status == ConnectionStateStatus.connected ||
        widget.receiverController.webrtcManager.status == ConnectionStateStatus.connected;

    return Padding(
      padding: const EdgeInsets.all(AppleTheme.spacing16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppleTheme.spacing12,
          vertical: AppleTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
            AppleTheme.tertiarySystemFill,
            context,
          ),
          borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppleTheme.systemGreen,
                shape: BoxShape.circle,
                boxShadow: isConnected
                    ? [
                        BoxShadow(
                          color: AppleTheme.systemGreen.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: AppleTheme.spacing8),
            Expanded(
              child: Text(
                isConnected ? l10n.displayActive : l10n.systemReady,
                style: AppleTheme.footnote.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppleTheme.resolvedSecondaryLabel(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(NavigationItem navItem) {
    return switch (navItem) {
      NavigationItem.sender => SenderView(
          controller: widget.senderController,
          onOpenSettings: () => _onSelectNav(NavigationItem.settings),
          onSwitchToReceiver: () => _onSelectNav(NavigationItem.receiver),
          isMacOverride: widget.isMacOverride,
        ),
      NavigationItem.receiver =>
        ReceiverView(controller: widget.receiverController),
      NavigationItem.diagnostics => DiagnosticsView(
          webrtcManager: widget.receiverController.status == ReceiverStatus.connected
              ? widget.receiverController.webrtcManager
              : (widget.senderController.status == SenderStatus.streaming ||
                      widget.senderController.status == SenderStatus.connecting)
                  ? widget.senderController.webrtcManager
                  : (_isMac
                      ? widget.senderController.webrtcManager
                      : widget.receiverController.webrtcManager),
        ),
      NavigationItem.settings =>
        SettingsView(controller: widget.settingsController),
    };
  }
}
