import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../models/schedule.dart';
import '../services/radio_api_service.dart';
import '../services/radio_player_controller.dart';
import '../widgets/blurred_artwork_background.dart';
import 'notifications_screen.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with TickerProviderStateMixin {
  bool _volumeOpen = false;
  double _volume = 80.0;
  bool _muted = false;
  bool _reduceMotion = false;
  final GlobalKey _volumeButtonKey = GlobalKey();
  final Object _volumeTapRegionGroup = Object();
  OverlayEntry? _volumeOverlayEntry;
  final RadioApiService _apiService = RadioApiService();
  late Future<WeeklySchedule> _scheduleFuture;
  late AnimationController _eqController;
  late AnimationController _liveDotController;

  @override
  void initState() {
    super.initState();
    _scheduleFuture = _apiService.fetchWeeklySchedule();
    _eqController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _liveDotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _liveDotController.stop();
      _liveDotController.reset();
    } else if (!_liveDotController.isAnimating) {
      _liveDotController.repeat();
    }
  }

  @override
  void dispose() {
    _removeVolumeOverlay();
    _apiService.dispose();
    _eqController.dispose();
    _liveDotController.dispose();
    super.dispose();
  }

  void _toggleVolumePanel(RadioPlayerController controller) {
    if (_volumeOpen) {
      _dismissVolumePanel();
      return;
    }

    final overlay = Overlay.of(context, rootOverlay: true);
    final overlayObject = overlay.context.findRenderObject();
    final buttonObject = _volumeButtonKey.currentContext?.findRenderObject();
    if (overlayObject is! RenderBox ||
        buttonObject is! RenderBox ||
        !overlayObject.hasSize ||
        !buttonObject.hasSize) {
      throw StateError(
        'Impossibile determinare la posizione del pannello volume.',
      );
    }

    final viewPadding = MediaQuery.viewPaddingOf(context);
    final double panelWidth = math
        .max(
          0.0,
          math.min(
            overlayObject.size.width - viewPadding.horizontal - 48,
            440.0,
          ),
        )
        .toDouble();
    final buttonTopLeft = buttonObject.localToGlobal(
      Offset.zero,
      ancestor: overlayObject,
    );
    final left = buttonTopLeft.dx.clamp(
      viewPadding.left,
      overlayObject.size.width - viewPadding.right - panelWidth,
    );
    final safeTop = viewPadding.top;
    final safeBottom = overlayObject.size.height - viewPadding.bottom;
    var top = buttonTopLeft.dy - 52 - 12;
    if (top < safeTop) {
      top = buttonTopLeft.dy + buttonObject.size.height + 12;
    }
    top = top.clamp(safeTop, math.max(safeTop, safeBottom - 52));

    setState(() => _volumeOpen = true);
    _volumeOverlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: left,
        top: top,
        width: panelWidth,
        child: Material(
          color: Colors.transparent,
          child: TapRegion(
            groupId: _volumeTapRegionGroup,
            onTapOutside: (_) => _dismissVolumePanel(),
            child: _buildVolumePanel(controller),
          ),
        ),
      ),
    );
    overlay.insert(_volumeOverlayEntry!);
  }

  void _removeVolumeOverlay() {
    final entry = _volumeOverlayEntry;
    _volumeOverlayEntry = null;
    entry?.remove();
    entry?.dispose();
  }

  void _dismissVolumePanel() {
    _removeVolumeOverlay();
    if (_volumeOpen) setState(() => _volumeOpen = false);
  }

  Widget _buildVolumePanel(RadioPlayerController controller) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF202024),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: _muted ? 'Attiva audio' : 'Disattiva audio',
            icon: Icon(_muted ? Icons.volume_off : Icons.volume_up, size: 22),
            onPressed: () {
              setState(() => _muted = !_muted);
              _volumeOverlayEntry?.markNeedsBuild();
              controller.setVolume(_muted ? 0 : _volume);
            },
          ),
          Expanded(
            child: Semantics(
              label: 'Volume',
              value: '${_muted ? 0 : _volume.toInt()} percento',
              child: CupertinoSlider(
                value: _volume,
                min: 0,
                max: 100,
                activeColor: const Color(0xFFF4F4F2),
                thumbColor: const Color(0xFFF4F4F2),
                onChanged: (value) {
                  setState(() => _volume = value);
                  _volumeOverlayEntry?.markNeedsBuild();
                  controller.setVolume(value);
                },
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '${_muted ? 0 : _volume.toInt()}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  ScheduleItem? _getCurrentShow(WeeklySchedule schedule) {
    final todayIndex = (DateTime.now().weekday - 1).clamp(0, 6);
    final dayKey = WeeklySchedule.dayOrder[todayIndex];
    final items = schedule.days[dayKey] ?? [];

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;

    for (final item in items) {
      try {
        final startParts = item.hourStart.split(':');
        final endParts = item.hourEnd.split(':');
        if (startParts.length < 2 || endParts.length < 2) continue;

        final startMinutes =
            int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
        final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

        if (nowMinutes >= startMinutes && nowMinutes < endMinutes) {
          return item;
        }
      } catch (_) {
        continue;
      }
    }
    return items.isNotEmpty ? items.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RadioPlayerController>();
    final appState = context.watch<RadioAppState>();
    final isPlaying = controller.isPlaying;

    // Start/stop animation based on playing state
    if (isPlaying && !_reduceMotion && !_eqController.isAnimating) {
      _eqController.repeat();
    } else if ((!isPlaying || _reduceMotion) && _eqController.isAnimating) {
      _eqController.stop();
      _eqController.reset();
    }

    return FutureBuilder<WeeklySchedule>(
      future: _scheduleFuture,
      builder: (context, snapshot) {
        final currentShow = snapshot.hasData
            ? _getCurrentShow(snapshot.data!)
            : null;
        final showName = currentShow?.title ?? 'Caricamento...';
        final showGenre = currentShow?.subtitle ?? '';
        final showSlot = currentShow != null
            ? '${currentShow.hourStart} – ${currentShow.hourEnd}'
            : '';
        final isFav = currentShow != null
            ? appState.isFav(currentShow.title)
            : false;

        final artwork =
            controller.currentTrack.artworkLarge ??
            controller.currentTrack.artworkSmall;

        final header = SizedBox(
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (RadioAppState.showProfileAvatar)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, top: 20),
                    child: Semantics(
                      button: true,
                      label: 'Apri profilo',
                      onTap: () => appState.setNavIndex(4),
                      child: ExcludeSemantics(
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => appState.setNavIndex(4),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFFF4F4F2),
                            foregroundColor: const Color(0xFF050506),
                            child: const Text(
                              'LF',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ClipOval(
                  child: Image.asset(
                    'assets/christmas-logo-transparent.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    semanticLabel: 'Radio WAH',
                    errorBuilder: (_, __, ___) => const Text(
                      'Radio WAH',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFC4D600),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (RadioAppState.showSearch)
                      IconButton(
                        tooltip: 'Cerca',
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          // TODO: Implement search functionality
                        },
                      ),
                    if (RadioAppState.showNotifications)
                      Stack(
                        children: [
                          IconButton(
                            tooltip: appState.unreadNotifications
                                ? 'Notifiche non lette'
                                : 'Notifiche',
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsScreen(),
                                ),
                              );
                            },
                          ),
                          if (appState.unreadNotifications)
                            Positioned(
                              right: 10,
                              top: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF33F0FF),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    if (RadioAppState.showFavoriteIcon && currentShow != null)
                      IconButton(
                        tooltip: isFav
                            ? 'Rimuovi dai preferiti'
                            : 'Aggiungi ai preferiti',
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? const Color(0xFFC4D600) : Colors.white,
                        ),
                        onPressed: () => appState.toggleFav(currentShow.title),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );

        return Scaffold(
          body: Stack(
            children: [
              BlurredArtworkBackground(artworkUrl: artwork),
              const BlurredArtworkOverlay(),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          child: Column(
                            children: [
                              header,
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight - 124,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const SizedBox(height: 8),
                                    // Live badge
                                    Container(
                                      constraints: const BoxConstraints(
                                        minHeight: 28,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF050506,
                                        ).withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Semantics(
                                        liveRegion: true,
                                        label:
                                            'In onda ora${showSlot.isEmpty ? '' : ', $showSlot'}',
                                        child: ExcludeSemantics(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _buildLiveDot(),
                                              const SizedBox(width: 8),
                                              Text(
                                                'IN ONDA ORA · $showSlot',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 1.0,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // Interactive Cover art
                                    Semantics(
                                      button: true,
                                      label: 'Passa al programma successivo',
                                      onTap: () => appState.nextLive(),
                                      child: ExcludeSemantics(
                                        child: InkWell(
                                          onTap: () => appState.nextLive(),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: artwork == null
                                                ? const SizedBox(
                                                    width: 220,
                                                    height: 220,
                                                  )
                                                : Image.network(
                                                    artwork,
                                                    width: 220,
                                                    height: 220,
                                                    fit: BoxFit.cover,
                                                    semanticLabel:
                                                        'Copertina del programma $showName',
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            const SizedBox(
                                                              width: 220,
                                                              height: 220,
                                                            ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // Title & Genre
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  showName,
                                                  style: const TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: -0.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  showGenre,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xFFA3A3A8),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Currently playing track + equalizer
                                    Row(
                                      children: [
                                        isPlaying
                                            ? _buildEqualizer()
                                            : _buildStaticEqualizer(),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                controller
                                                        .currentTrack
                                                        .title
                                                        .isNotEmpty
                                                    ? controller
                                                          .currentTrack
                                                          .title
                                                    : 'Rotazione musicale continua',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                controller
                                                        .currentTrack
                                                        .artist
                                                        .isNotEmpty
                                                    ? controller
                                                          .currentTrack
                                                          .artist
                                                    : 'Radio WAH Selection',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFFA3A3A8),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    // Bottom Player Controls
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TapRegion(
                                          groupId: _volumeTapRegionGroup,
                                          child: IconButton(
                                            key: _volumeButtonKey,
                                            tooltip: _volumeOpen
                                                ? 'Nascondi controlli volume'
                                                : 'Mostra controlli volume',
                                            icon: Icon(
                                              _volumeOpen
                                                  ? Icons.volume_up
                                                  : Icons.volume_down,
                                            ),
                                            style: IconButton.styleFrom(
                                              backgroundColor: _volumeOpen
                                                  ? Colors.white24
                                                  : Colors.transparent,
                                              minimumSize: const Size(48, 48),
                                            ),
                                            onPressed: () =>
                                                _toggleVolumePanel(controller),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 76,
                                          height: 76,
                                          child: FloatingActionButton(
                                            tooltip: controller.isPlaying
                                                ? 'Metti in pausa'
                                                : 'Riprendi riproduzione',
                                            backgroundColor: const Color(
                                              0xFFC4D600,
                                            ),
                                            foregroundColor: const Color(
                                              0xFF050506,
                                            ),
                                            elevation: 10,
                                            shape: const CircleBorder(),
                                            onPressed:
                                                controller.togglePlayPause,
                                            child: Icon(
                                              controller.isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              size: 36,
                                            ),
                                          ),
                                        ),
                                        if (RadioAppState.showCastIcon)
                                          IconButton(
                                            tooltip: 'Seleziona uscita audio',
                                            icon: const Icon(Icons.cast),
                                            onPressed: () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Uscita audio: Questo dispositivo',
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        else
                                          const SizedBox(width: 48),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEqualizer() {
    return ExcludeSemantics(
      child: SizedBox(
        width: 24,
        height: 16,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _eqBar(0),
            const SizedBox(width: 3),
            _eqBar(0.2),
            const SizedBox(width: 3),
            _eqBar(0.4),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveDot() {
    if (_reduceMotion) {
      return Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFFC4D600),
          shape: BoxShape.circle,
        ),
      );
    }
    return AnimatedBuilder(
      animation: _liveDotController,
      builder: (context, child) {
        final scale =
            0.8 +
            0.4 * (math.sin(_liveDotController.value * math.pi * 2) + 1) / 2;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFC4D600),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaticEqualizer() {
    return ExcludeSemantics(
      child: SizedBox(
        width: 24,
        height: 16,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 3,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFC4D600),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 3),
            Container(
              width: 3,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFC4D600),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 3),
            Container(
              width: 3,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFC4D600),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eqBar(double delay) {
    return AnimatedBuilder(
      animation: _eqController,
      builder: (context, child) {
        final value = (_eqController.value + delay) % 1.0;
        final scale = 0.3 + (0.7 * (math.sin(value * math.pi * 2) + 1) / 2);
        return Transform.scale(
          scaleY: scale,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFFC4D600),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      },
    );
  }
}
