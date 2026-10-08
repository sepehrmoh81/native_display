import Cocoa
import FlutterMacOS

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
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    super.applicationDidFinishLaunching(notification)
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}

