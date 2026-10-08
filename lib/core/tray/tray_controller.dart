// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tray_manager/legacy.dart';
import 'package:window_manager/window_manager.dart';

class TrayController with TrayListener {
  static final TrayController instance = TrayController._internal();
  TrayController._internal();

  bool _isInitialized = false;
  VoidCallback? onOpenMainWindow;
  VoidCallback? onToggleStream;
  VoidCallback? onQuit;

  String _statusTitle = 'Native Display: Idle';

  Future<void> initialize({
    VoidCallback? onOpenMainWindow,
    VoidCallback? onToggleStream,
    VoidCallback? onQuit,
  }) async {
    if (_isInitialized || (!Platform.isMacOS && !Platform.isWindows)) return;

    this.onOpenMainWindow = onOpenMainWindow;
    this.onToggleStream = onToggleStream;
    this.onQuit = onQuit;

    try {
      trayManager.addListener(this);
      // Set an icon or system icon
      if (Platform.isMacOS) {
        await trayManager.setIcon(
          'assets/icons/tray_icon.png', // Fallback or custom
          isTemplate: true,
        );
      }
      await updateMenu(statusText: 'Ready', isStreaming: false);
      _isInitialized = true;
    } catch (e) {
      debugPrint('[TrayController] Initialization error: $e');
    }
  }

  Future<void> updateMenu({
    required String statusText,
    required bool isStreaming,
    List<String> receiverNames = const [],
  }) async {
    if (!_isInitialized && (Platform.isMacOS || Platform.isWindows)) {
      try {
        trayManager.addListener(this);
        _isInitialized = true;
      } catch (_) {}
    }

    _statusTitle = 'Native Display: $statusText';

    final List<MenuItem> menuItems = [
      MenuItem(
        key: 'status',
        label: _statusTitle,
        disabled: true,
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'open_window',
        label: 'Open Native Display Window',
      ),
      MenuItem(
        key: 'toggle_stream',
        label: isStreaming ? 'Stop Streaming' : 'Start Streaming',
      ),
    ];

    if (receiverNames.isNotEmpty) {
      menuItems.add(MenuItem.separator());
      menuItems.add(MenuItem(
        key: 'receivers_header',
        label: 'Available Displays:',
        disabled: true,
      ));
      for (final name in receiverNames) {
        menuItems.add(MenuItem(
          key: 'receiver_$name',
          label: '• $name',
        ));
      }
    }

    menuItems.addAll([
      MenuItem.separator(),
      MenuItem(
        key: 'quit',
        label: 'Quit Native Display',
      ),
    ]);

    try {
      final menu = Menu(items: menuItems);
      await trayManager.setContextMenu(menu);
      await trayManager.setToolTip('Native Display');
    } catch (e) {
      debugPrint('[TrayController] Failed to update context menu: $e');
    }
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'open_window':
        await windowManager.show();
        await windowManager.focus();
        onOpenMainWindow?.call();
        break;
      case 'toggle_stream':
        onToggleStream?.call();
        break;
      case 'quit':
        onQuit?.call();
        await windowManager.destroy();
        exit(0);
      default:
        break;
    }
  }

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }
}
