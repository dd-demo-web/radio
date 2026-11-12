import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    // L'interfaccia è pensata in verticale (riferimento 390 × 844):
    // finestra stretta e alta, ridimensionabile ma non sotto il minimo leggibile.
    self.title = "Radio WAH"
    self.setContentSize(NSSize(width: 430, height: 880))
    self.contentMinSize = NSSize(width: 360, height: 640)
    self.isReleasedWhenClosed = false
    self.center()
    self.setFrameAutosaveName("RadioWAHMainWindow")

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
