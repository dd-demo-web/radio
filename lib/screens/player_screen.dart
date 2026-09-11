import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/radio_player_controller.dart';
import '../widgets/blurred_artwork_background.dart';
import '../widgets/now_playing_card.dart';
import 'schedule_screen.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final RadioPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RadioPlayerController();
    // Autoplay all'accesso alla app.
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Radio Wah'),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month),
              tooltip: 'Palinsesto settimanale',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScheduleScreen()),
                );
              },
            ),
          ],
        ),
        body: Consumer<RadioPlayerController>(
          builder: (context, controller, _) {
            final artwork =
                controller.currentTrack.artworkLarge ??
                controller.currentTrack.artworkSmall;
            return Stack(
              children: [
                BlurredArtworkBackground(artworkUrl: artwork),
                const BlurredArtworkOverlay(),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const SizedBox(height: kToolbarHeight),
                        Expanded(
                          child: Center(
                            child: NowPlayingCard(
                              track: controller.currentTrack,
                            ),
                          ),
                        ),
                        if (controller.status == RadioPlaybackStatus.error)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              controller.errorMessage ?? 'Errore sconosciuto',
                              style: const TextStyle(color: Colors.redAccent),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else if (controller.autoplayBlocked)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Tocca play per avviare la diretta',
                              style: TextStyle(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        _PlayButton(controller: controller),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final RadioPlayerController controller;

  const _PlayButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isLoading = controller.status == RadioPlaybackStatus.loading;
    return SizedBox(
      width: 84,
      height: 84,
      child: FloatingActionButton(
        onPressed: isLoading ? null : controller.togglePlayPause,
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Icon(
                controller.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 42,
              ),
      ),
    );
  }
}
