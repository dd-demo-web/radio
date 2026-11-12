import CarPlay
import Flutter
import UIKit

// MARK: - Ponte Dart <-> nativo

/// Stato che il lato Dart (`lib/services/carplay_bridge.dart`) spinge a ogni cambiamento.
struct RadioLiveState: Equatable {
  struct Show: Equatable {
    let start: String
    let end: String
    let title: String
    let subtitle: String
    let onAir: Bool
  }

  var isPlaying = false
  var trackTitle = ""
  var trackArtist = ""
  var artworkURL: URL?
  var showTitle: String?
  var showTime: String?
  var today: [Show] = []

  init() {}

  init(_ map: [String: Any]) {
    isPlaying = map["isPlaying"] as? Bool ?? false
    trackTitle = map["title"] as? String ?? ""
    trackArtist = map["artist"] as? String ?? ""
    artworkURL = (map["artworkUrl"] as? String).flatMap(URL.init(string:))
    showTitle = map["showTitle"] as? String
    showTime = map["showTime"] as? String
    today = (map["today"] as? [[String: Any]] ?? []).map {
      Show(
        start: $0["start"] as? String ?? "",
        end: $0["end"] as? String ?? "",
        title: $0["title"] as? String ?? "",
        subtitle: $0["subtitle"] as? String ?? "",
        onAir: $0["onAir"] as? Bool ?? false
      )
    }
  }
}

/// Canale `radio_wah/carplay`: riceve lo stato da Dart e gli manda i comandi.
/// Play/pausa dalla schermata In riproduzione non passano di qui: li gestisce
/// audio_service tramite MPRemoteCommandCenter.
final class RadioBridge {
  static let shared = RadioBridge()

  private var channel: FlutterMethodChannel?
  private(set) var state = RadioLiveState()
  var onStateChange: ((RadioLiveState) -> Void)?

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "radio_wah/carplay", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { return result(nil) }
      switch call.method {
      case "state":
        let newState = RadioLiveState(call.arguments as? [String: Any] ?? [:])
        if newState != self.state {
          self.state = newState
          self.onStateChange?(newState)
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    self.channel = channel
  }

  func playLive() {
    channel?.invokeMethod("play", arguments: nil)
  }
}

// MARK: - Scena CarPlay

final class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
  private var interfaceController: CPInterfaceController?
  private var rootTemplate: CPListTemplate?
  private let liveItem = CPListItem(text: "Radio WAH", detailText: "In diretta")
  private var lastToday: [RadioLiveState.Show] = []
  private var artworkTask: URLSessionDataTask?
  private var loadedArtworkURL: URL?

  private static let logo: UIImage? = {
    let key = FlutterDartProject.lookupKey(forAsset: "assets/logo.jpg")
    return Bundle.main.path(forResource: key, ofType: nil).flatMap(UIImage.init(contentsOfFile:))
  }()

  func templateApplicationScene(
    _ templateApplicationScene: CPTemplateApplicationScene,
    didConnect interfaceController: CPInterfaceController
  ) {
    self.interfaceController = interfaceController

    liveItem.setImage(Self.logo)
    liveItem.playingIndicatorLocation = .trailing
    liveItem.handler = { [weak self] _, completion in
      RadioBridge.shared.playLive()
      self?.showNowPlaying()
      completion()
    }

    let nowPlaying = CPNowPlayingTemplate.shared
    nowPlaying.isUpNextButtonEnabled = false
    nowPlaying.isAlbumArtistButtonEnabled = false

    let template = CPListTemplate(title: "Radio WAH", sections: [])
    rootTemplate = template
    interfaceController.setRootTemplate(template, animated: false, completion: nil)

    RadioBridge.shared.onStateChange = { [weak self] state in self?.render(state) }
    render(RadioBridge.shared.state, force: true)
  }

  func templateApplicationScene(
    _ templateApplicationScene: CPTemplateApplicationScene,
    didDisconnect interfaceController: CPInterfaceController
  ) {
    RadioBridge.shared.onStateChange = nil
    artworkTask?.cancel()
    self.interfaceController = nil
    rootTemplate = nil
  }

  private func showNowPlaying() {
    guard let interfaceController,
          !(interfaceController.topTemplate is CPNowPlayingTemplate) else { return }
    interfaceController.pushTemplate(CPNowPlayingTemplate.shared, animated: true, completion: nil)
  }

  private func render(_ state: RadioLiveState, force: Bool = false) {
    liveItem.setText(state.showTitle ?? "Radio WAH")
    liveItem.setDetailText(Self.trackLine(state))
    liveItem.isPlaying = state.isPlaying
    loadArtwork(state.artworkURL)

    guard force || state.today != lastToday else { return }
    lastToday = state.today
    var sections = [CPListSection(items: [liveItem], header: "In diretta", sectionIndexTitle: nil)]
    let shows = state.today
      .prefix(max(CPListTemplate.maximumItemCount - 1, 0))
      .map { show -> CPListItem in
        let item = CPListItem(
          text: show.title,
          detailText: "\(show.start)–\(show.end)" + (show.subtitle.isEmpty ? "" : " · \(show.subtitle)")
        )
        if show.onAir {
          item.setDetailText("IN ONDA · \(show.start)–\(show.end)")
        }
        // Il palinsesto è informativo: si ascolta solo la diretta.
        return item
      }
    if !shows.isEmpty {
      sections.append(CPListSection(items: shows, header: "Oggi", sectionIndexTitle: nil))
    }
    rootTemplate?.updateSections(sections)
  }

  private static func trackLine(_ state: RadioLiveState) -> String {
    let parts = [state.trackTitle, state.trackArtist].filter { !$0.isEmpty && $0 != "Radio Wah" }
    if parts.isEmpty { return state.showTime.map { "In diretta · \($0)" } ?? "In diretta" }
    return parts.joined(separator: " – ")
  }

  private func loadArtwork(_ url: URL?) {
    guard url != loadedArtworkURL else { return }
    loadedArtworkURL = url
    artworkTask?.cancel()
    guard let url else {
      liveItem.setImage(Self.logo)
      return
    }
    artworkTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
      let image = data.flatMap(UIImage.init(data:))
      DispatchQueue.main.async {
        guard let self, self.loadedArtworkURL == url else { return }
        self.liveItem.setImage(image ?? Self.logo)
      }
    }
    artworkTask?.resume()
  }
}
