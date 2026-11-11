import Flutter
import UIKit

/// Il motore Flutter parte all'avvio dell'app e non quando si apre la scena del telefono:
/// CarPlay può lanciare l'app con l'iPhone bloccato, senza nessuna finestra sul telefono,
/// e l'audio (gestito lato Dart da audio_service) deve funzionare lo stesso.
/// Telefono e CarPlay usano lo stesso motore, quindi lo stesso player.
@main
@objc class AppDelegate: FlutterAppDelegate {
  lazy var radioEngine = FlutterEngine(name: "radio_wah")

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    radioEngine.run()
    GeneratedPluginRegistrant.register(with: radioEngine)
    RadioBridge.shared.attach(to: radioEngine.binaryMessenger)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

/// Scena del telefono: mostra la UI Flutter del motore condiviso.
final class PhoneSceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene,
          let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

    let flutterViewController = FlutterViewController(
      engine: appDelegate.radioEngine,
      nibName: nil,
      bundle: nil
    )
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = flutterViewController
    self.window = window
    window.makeKeyAndVisible()
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    // Il motore resta vivo (serve all'audio e a CarPlay): si stacca solo la vista.
    (UIApplication.shared.delegate as? AppDelegate)?.radioEngine.viewController = nil
    window = nil
  }
}
