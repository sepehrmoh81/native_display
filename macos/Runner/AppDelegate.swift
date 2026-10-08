import Cocoa
import FlutterMacOS

//
//  VirtualDisplayManager
//  Manages macOS native virtual displays using CoreGraphics CGVirtualDisplay APIs.
//
class VirtualDisplayManager {
  static let shared = VirtualDisplayManager()

  private var activeDisplays: [CGDirectDisplayID: CGVirtualDisplay] = [:]
  private let lock = NSLock()

  private init() {}

  /// Creates and activates a virtual display in macOS WindowServer.
  func createDisplay(
    width: UInt32,
    height: UInt32,
    refreshRate: Double = 60.0,
    hiDPI: Bool = true,
    name: String = "NativeDisplay Virtual Monitor"
  ) -> [String: Any]? {
    lock.lock()
    defer { lock.unlock() }

    guard NSClassFromString("CGVirtualDisplay") != nil else {
      NSLog("[VirtualDisplayManager] Error: CGVirtualDisplay class not found in CoreGraphics.")
      return nil
    }

    let descriptor = CGVirtualDisplayDescriptor()
    descriptor.queue = DispatchQueue.main
    descriptor.name = name

    let scaleFactor: UInt32 = hiDPI ? 2 : 1
    descriptor.maxPixelsWide = max(width * scaleFactor, 3840)
    descriptor.maxPixelsHigh = max(height * scaleFactor, 2160)
    descriptor.sizeInMillimeters = CGSize(width: 600, height: 340)
    descriptor.productID = 0x8888
    descriptor.vendorID = 0x7777
    descriptor.serialNum = UInt32(activeDisplays.count + 1)

    descriptor.terminationHandler = { [weak self] _, terminatedDisplay in
      guard let self = self else { return }
      self.lock.lock()
      self.activeDisplays.removeValue(forKey: terminatedDisplay.displayID)
      self.lock.unlock()
      NSLog("[VirtualDisplayManager] Virtual display %u terminated by system.", terminatedDisplay.displayID)
    }

    guard let display = CGVirtualDisplay(descriptor: descriptor) else {
      NSLog("[VirtualDisplayManager] Failed to instantiate CGVirtualDisplay.")
      return nil
    }

    let settings = CGVirtualDisplaySettings()
    settings.hiDPI = hiDPI ? 1 : 0
    settings.modes = [
      CGVirtualDisplayMode(width: width, height: height, refreshRate: refreshRate > 0 ? refreshRate : 60.0)
    ]

    guard display.apply(settings) else {
      NSLog("[VirtualDisplayManager] Failed to apply settings to CGVirtualDisplay.")
      return nil
    }

    let displayId = display.displayID
    activeDisplays[displayId] = display
    NSLog("[VirtualDisplayManager] Created virtual display ID %u (%@, %ux%u @ %.1fHz)", displayId, name, width, height, refreshRate)

    return [
      "displayId": Int(displayId),
      "name": name,
      "width": Int(width),
      "height": Int(height),
      "refreshRate": refreshRate > 0 ? refreshRate : 60.0,
      "isVirtual": true
    ]
  }

  /// Destroys a virtual display by its display ID.
  func destroyDisplay(displayId: CGDirectDisplayID) -> Bool {
    lock.lock()
    defer { lock.unlock() }

    if activeDisplays.removeValue(forKey: displayId) != nil {
      NSLog("[VirtualDisplayManager] Destroyed virtual display ID %u", displayId)
      return true
    }
    return false
  }

  /// Destroys all active virtual displays.
  func destroyAll() {
    lock.lock()
    defer { lock.unlock() }

    NSLog("[VirtualDisplayManager] Destroying all (%ld) virtual displays", activeDisplays.count)
    activeDisplays.removeAll()
  }

  /// Returns the list of currently active virtual display IDs.
  func getActiveDisplayIds() -> [Int] {
    lock.lock()
    defer { lock.unlock() }
    return activeDisplays.keys.map { Int($0) }
  }
}

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    // Keep app running in menu bar / background for streaming
    return false
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    if let window = mainFlutterWindow,
       let controller = window.contentViewController as? FlutterViewController {
      let screenChannel = FlutterMethodChannel(
        name: "com.nativedisplay.app/screen",
        binaryMessenger: controller.engine.binaryMessenger
      )

      screenChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        switch call.method {
        case "hasScreenRecordingPermission":
          if #available(macOS 10.15, *) {
            result(CGPreflightScreenCaptureAccess())
          } else {
            result(true)
          }
        case "requestScreenRecordingPermission":
          if #available(macOS 11.0, *) {
            result(CGRequestScreenCaptureAccess())
          } else {
            result(true)
          }
        case "getNativeDisplays":
          var displayCount: UInt32 = 0
          CGGetActiveDisplayList(0, nil, &displayCount)
          var allocatedDisplays = [CGDirectDisplayID](repeating: 0, count: Int(displayCount))
          CGGetActiveDisplayList(displayCount, &allocatedDisplays, &displayCount)

          var displayInfos: [[String: Any]] = []
          let mainDisplayID = CGMainDisplayID()

          for displayID in allocatedDisplays {
            let bounds = CGDisplayBounds(displayID)
            let isMain = (displayID == mainDisplayID)
            let isBuiltIn = CGDisplayIsBuiltin(displayID) != 0

            let mode = CGDisplayCopyDisplayMode(displayID)
            let refreshRate = mode?.refreshRate ?? 60.0
            let name = isBuiltIn ? "Built-in Retina Display" : "External Display (\(displayID))"

            displayInfos.append([
              "displayId": Int(displayID),
              "name": name,
              "width": Int(bounds.width),
              "height": Int(bounds.height),
              "refreshRate": refreshRate > 0 ? refreshRate : 60.0,
              "isMain": isMain,
              "isBuiltIn": isBuiltIn
            ])
          }
          result(displayInfos)
        case "openDisplaySettings":
          if let url = URL(string: "x-apple.systempreferences:com.apple.Displays-Settings.extension") {
            NSWorkspace.shared.open(url)
            result(true)
          } else {
            result(false)
          }
        default:
          result(FlutterMethodNotImplemented)
        }
      }

      let virtualDisplayChannel = FlutterMethodChannel(
        name: "com.nativedisplay.app/virtual_display",
        binaryMessenger: controller.engine.binaryMessenger
      )

      virtualDisplayChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        switch call.method {
        case "createVirtualDisplay":
          guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Arguments must be a dictionary", details: nil))
            return
          }
          let width = UInt32((args["width"] as? Int) ?? 1920)
          let height = UInt32((args["height"] as? Int) ?? 1080)
          let refreshRate = (args["refreshRate"] as? Double) ?? 60.0
          let hiDPI = (args["hiDPI"] as? Bool) ?? true
          let name = (args["name"] as? String) ?? "NativeDisplay Virtual Monitor"

          if let displayInfo = VirtualDisplayManager.shared.createDisplay(
            width: width,
            height: height,
            refreshRate: refreshRate,
            hiDPI: hiDPI,
            name: name
          ) {
            result(displayInfo)
          } else {
            result(FlutterError(code: "CREATE_FAILED", message: "Failed to create virtual display", details: nil))
          }

        case "destroyVirtualDisplay":
          guard let args = call.arguments as? [String: Any],
                let displayId = args["displayId"] as? Int else {
            result(FlutterError(code: "INVALID_ARGS", message: "displayId required", details: nil))
            return
          }
          let success = VirtualDisplayManager.shared.destroyDisplay(displayId: CGDirectDisplayID(displayId))
          result(success)

        case "destroyAllVirtualDisplays":
          VirtualDisplayManager.shared.destroyAll()
          result(true)

        case "getActiveVirtualDisplays":
          result(VirtualDisplayManager.shared.getActiveDisplayIds())

        case "openDisplaySettings":
          if let url = URL(string: "x-apple.systempreferences:com.apple.Displays-Settings.extension") {
            NSWorkspace.shared.open(url)
            result(true)
          } else {
            result(false)
          }

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    super.applicationDidFinishLaunching(notification)
  }

  override func applicationWillTerminate(_ notification: Notification) {
    // Clean up any remaining virtual displays so no ghost screens persist
    VirtualDisplayManager.shared.destroyAll()
    super.applicationWillTerminate(notification)
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}

