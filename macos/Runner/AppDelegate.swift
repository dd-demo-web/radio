import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  // Una radio deve continuare a suonare anche con la finestra chiusa:
  // si riapre dal Dock (o dai tasti multimediali / Centro di Controllo).
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    if !flag {
      sender.windows.first { $0 is MainFlutterWindow }?.makeKeyAndOrderFront(nil)
    }
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
