import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../services/radio_player_controller.dart';
import '../widgets/blurred_artwork_background.dart';
import 'notifications_screen.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _volumeOpen = false;
  double _volume = 80.0;
  bool _muted = false;

  final List<Map<String, dynamic>> _liveShows = [
    {
      'name': 'Moka',
      'genre': 'Il buongiorno di Radio WAH',
      'slot': '8:30 – 10:00',
      'startHour': 8, 'startMinute': 30,
      'endHour': 10, 'endMinute': 0,
      'id': 'moka',
      'image': 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=600&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Ruby Tuesday',
      'genre': 'Rock d’autore e rarità',
      'slot': '10:00 – 12:30',
      'startHour': 10, 'startMinute': 0,
      'endHour': 12, 'endMinute': 30,
      'id': 'ruby',
      'image': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Funky Reload',
      'genre': 'Funk, soul e disco',
      'slot': '12:30 – 14:30',
      'startHour': 12, 'startMinute': 30,
      'endHour': 14, 'endMinute': 30,
      'id': 'funky',
      'image': 'https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?w=600&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Liquid',
      'genre': 'Elettronica e ambient',
      'slot': '14:30 – 17:30',
      'startHour': 14, 'startMinute': 30,
      'endHour': 17, 'endMinute': 30,
      'id': 'liquid',
      'image': 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=600&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Fresh Sounds',
      'genre': 'Le novità della settimana',
      'slot': '17:30 – 19:00',
      'startHour': 17, 'startMinute': 30,
      'endHour': 19, 'endMinute': 0,
      'id': 'fresh',
      'image': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&auto=format&fit=crop&q=80',
    },
  ];

  int _getCurrentLiveShowIndex() {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;

    for (int i = 0; i < _liveShows.length; i++) {
      final show = _liveShows[i];
      final startMin = show['startHour'] * 60 + show['startMinute'];
      final endMin = show['endHour'] * 60 + show['endMinute'];
      if (nowMinutes >= startMin && nowMinutes < endMin) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RadioPlayerController>();
    final appState = context.watch<RadioAppState>();
    
    final showIndex = appState.liveIndex > 0 ? appState.liveIndex : _getCurrentLiveShowIndex();
    final show = _liveShows[showIndex];
    final isFav = appState.isFav(show['id']!);

    final artwork = controller.currentTrack.artworkLarge ??
        controller.currentTrack.artworkSmall ??
        show['image']!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => appState.setNavIndex(4), // Go to Profile
            child: CircleAvatar(
              backgroundColor: const Color(0xFFF4F4F2),
              foregroundColor: const Color(0xFF050506),
              child: const Text('LF', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ),
        ),
        title: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 2,
                offset: Offset.zero,
              ),
            ],
          ),
          child: Image.asset(
            'assets/logo.jpg',
            height: 126,
            width: 126,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Text(
              'Radio WAH',
              style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFC4D600)),
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
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
          IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? const Color(0xFFC4D600) : Colors.white),
            onPressed: () => appState.toggleFav(show['id']!),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          BlurredArtworkBackground(artworkUrl: artwork),
          const BlurredArtworkOverlay(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(height: 8),
                          // Live badge
                          Container(
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF050506).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFC4D600),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'IN ONDA ORA · ${show['slot']}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Interactive Cover art
                          GestureDetector(
                            onTap: () => appState.nextLive(),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                artwork,
                                width: 220,
                                height: 220,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 220,
                                  height: 220,
                                  color: const Color(0xFF1C1C1F),
                                  child: const Icon(Icons.radio, size: 64, color: Color(0xFFC4D600)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Title & Genre
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        show['name']!,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        show['genre']!,
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
                              _Equalizer(isPlaying: controller.isPlaying),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.currentTrack.title.isNotEmpty
                                          ? controller.currentTrack.title
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
                                      controller.currentTrack.artist.isNotEmpty
                                          ? controller.currentTrack.artist
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
                          Stack(
                            alignment: Alignment.bottomCenter,
                            clipBehavior: Clip.none,
                            children: [
                              if (_volumeOpen)
                                Positioned(
                                  bottom: 84,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 52,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF202024).withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(26),
                                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(_muted ? Icons.volume_off : Icons.volume_up, size: 22),
                                          onPressed: () => setState(() => _muted = !_muted),
                                        ),
                                        Expanded(
                                          child: Slider(
                                            value: _muted ? 0 : _volume,
                                            min: 0,
                                            max: 100,
                                            activeColor: const Color(0xFFF4F4F2),
                                            inactiveColor: Colors.white24,
                                            onChanged: (val) {
                                              setState(() {
                                                _volume = val;
                                                _muted = false;
                                              });
                                            },
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
                                  ),
                                ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                         icon: Icon(_volumeOpen ? Icons.volume_up : Icons.volume_down),
                                    style: IconButton.styleFrom(
                                      backgroundColor: _volumeOpen ? Colors.white24 : Colors.transparent,
                                      minimumSize: const Size(44, 44),
                                    ),
                                    onPressed: () => setState(() => _volumeOpen = !_volumeOpen),
                                  ),
                                  SizedBox(
                                    width: 76,
                                    height: 76,
                                    child: FloatingActionButton(
                                      backgroundColor: const Color(0xFFC4D600),
                                      foregroundColor: const Color(0xFF050506),
                                      elevation: 10,
                                      shape: const CircleBorder(),
                                      onPressed: controller.togglePlayPause,
                                      child: Icon(
                                        controller.isPlaying ? Icons.pause : Icons.play_arrow,
                                        size: 36,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cast),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Uscita audio: Questo dispositivo')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
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
  }
}

class _Equalizer extends StatelessWidget {
  final bool isPlaying;

  const _Equalizer({required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _bar(isPlaying ? 0.8 : 0.3),
          _bar(isPlaying ? 1.0 : 0.3),
          _bar(isPlaying ? 0.5 : 0.3),
        ],
      ),
    );
  }

  Widget _bar(double heightFactor) {
    return Container(
      width: 3,
      height: 24 * heightFactor,
      decoration: BoxDecoration(
        color: const Color(0xFFC4D600),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
