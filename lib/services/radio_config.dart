/// Endpoint e costanti di configurazione per Radio Wah.
class RadioConfig {
  RadioConfig._();

  /// URL dello stream audio in ascolto diretto (icecast).
  static const String streamUrl =
      'https://stream9.xdevel.com/audio0s978127-2484/stream/icecast.audio';

  /// Endpoint per il palinsesto settimanale.
  static const String scheduleUrl =
      'https://api.xdevel.com/radioplayer/mobileview/schedule-json-read/20351128'
      '?clientId=fcc0d0c4e0159db1802211778ca9820282f5226c';

  /// Endpoint (via proxy CORS) per i metadata del brano corrente.
  static const String metadataUrl =
      'https://cors.xdevel.com/?url=https://api7.xdevel.com/streamsolution/web/metadata/2484/'
      '?clientId=5e9ab6ba0ef6c31a8d27f31d17db0cc34165adee';

  /// Intervallo di refresh dei metadata del brano in riproduzione.
  /// Allineato al player ufficiale xdevel (polling ogni 30s).
  static const Duration metadataPollInterval = Duration(seconds: 30);
}
