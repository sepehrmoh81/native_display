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

  // Initialize WebRTC
  final webrtcManager = WebRTCManager();
  await webrtcManager.initialize();

  // Initialize Network & Controllers
  final discoveryService = DiscoveryService();
  final settingsController = SettingsController();
  final senderController = SenderController(
    discoveryService: discoveryService,
    webrtcManager: webrtcManager,
  );
  final receiverController = ReceiverController(
    discoveryService: discoveryService,
    webrtcManager: webrtcManager,
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
      },
    );
  }

  runApp(NativeDisplayApp(
    discoveryService: discoveryService,
    webrtcManager: webrtcManager,
    senderController: senderController,
    receiverController: receiverController,
    settingsController: settingsController,
  ));
}

class NativeDisplayApp extends StatelessWidget {
  final DiscoveryService discoveryService;
  final WebRTCManager webrtcManager;
  final SenderController senderController;
  final ReceiverController receiverController;
  final SettingsController settingsController;

  const NativeDisplayApp({
    super.key,
    required this.discoveryService,
    required this.webrtcManager,
    required this.senderController,
    required this.receiverController,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Native Display',
      debugShowCheckedModeBanner: false,
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
        webrtcManager: webrtcManager,
        senderController: senderController,
        receiverController: receiverController,
        settingsController: settingsController,
      ),
    );
  }
}

enum NavigationItem {
  sender('Extend Display', CupertinoIcons.macwindow),
  receiver('Use as Display', CupertinoIcons.device_desktop),
  diagnostics('Diagnostics', CupertinoIcons.speedometer),
  settings('Settings', CupertinoIcons.gear_alt);

  final String title;
  final IconData icon;
  const NavigationItem(this.title, this.icon);
}

class MainShellView extends StatefulWidget {
  final DiscoveryService discoveryService;
  final WebRTCManager webrtcManager;
  final SenderController senderController;
  final ReceiverController receiverController;
  final SettingsController settingsController;

  const MainShellView({
    super.key,
    required this.discoveryService,
    required this.webrtcManager,
    required this.senderController,
    required this.receiverController,
    required this.settingsController,
  });

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  late NavigationItem _selectedNav;

  @override
  void initState() {
    super.initState();
    // Default to Sender on macOS, Receiver on Windows
    _selectedNav =
        Platform.isWindows ? NavigationItem.receiver : NavigationItem.sender;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;

        if (isCompact) {
          // Compact / Mobile Layout: Cupertino Tab Bar
          return CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              currentIndex: NavigationItem.values.indexOf(_selectedNav),
              onTap: (index) {
                setState(() => _selectedNav = NavigationItem.values[index]);
              },
              items: NavigationItem.values
                  .map((item) => BottomNavigationBarItem(
                        icon: Icon(item.icon),
                        label: item.title,
                      ))
                  .toList(),
            ),
            tabBuilder: (context, index) {
              return CupertinoPageScaffold(
                child: SafeArea(
                  child: _buildContent(NavigationItem.values[index]),
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
                      _buildSidebarHeader(context),
                      const SizedBox(height: AppleTheme.spacing12),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppleTheme.spacing12,
                          ),
                          children: NavigationItem.values
                              .map((item) => _buildSidebarItem(context, item))
                              .toList(),
                        ),
                      ),
                      _buildSidebarFooter(context),
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

  Widget _buildSidebarHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppleTheme.spacing16,
        top: AppleTheme.spacing20,
        right: AppleTheme.spacing16,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
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
              size: 18,
            ),
          ),
          const SizedBox(width: AppleTheme.spacing12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Native Display',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: AppleTheme.resolvedLabel(context),
                ),
              ),
              Text(
                'Mac to Windows Link',
                style: AppleTheme.footnote.copyWith(
                  color: AppleTheme.resolvedTertiaryLabel(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, NavigationItem item) {
    final isSelected = _selectedNav == item;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: GestureDetector(
        onTap: () => setState(() => _selectedNav = item),
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
              Text(
                item.title,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppleTheme.spacing16),
      child: Container(
        padding: const EdgeInsets.all(AppleTheme.spacing12),
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
                color: widget.webrtcManager.status == ConnectionStateStatus.connected
                    ? AppleTheme.systemGreen
                    : AppleTheme.systemOrange,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppleTheme.spacing8),
            Expanded(
              child: Text(
                widget.webrtcManager.status == ConnectionStateStatus.connected
                    ? 'Display Active'
                    : 'System Ready',
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
      NavigationItem.sender => SenderView(controller: widget.senderController),
      NavigationItem.receiver =>
        ReceiverView(controller: widget.receiverController),
      NavigationItem.diagnostics =>
        DiagnosticsView(webrtcManager: widget.webrtcManager),
      NavigationItem.settings =>
        SettingsView(controller: widget.settingsController),
    };
  }
}
