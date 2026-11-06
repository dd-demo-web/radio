import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../models/track_metadata.dart';
import '../services/radio_player_controller.dart';

/// Mini player bar shown above the bottom navigation bar
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RadioPlayerController>();
    final appState = context.watch<RadioAppState>();
    final currentTrack = controller.currentTrack;
    final isPlaying = controller.isPlaying;

    if (currentTrack == null) {
      return const SizedBox.shrink();
    }

    final isMixtape = appState.activeMix != null;
    final backgroundColor = isMixtape 
        ? const Color(0xFF14242A) 
        : const Color(0xFF1C1C1F);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 64,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => appState.setNavIndex(0), // Go to player screen
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                // Cover image
                _buildCover(currentTrack),
                const SizedBox(width: 10),
                // Track info
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentTrack.title.isNotEmpty ? currentTrack.title : 'Radio Wah',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _buildTag(isMixtape, isPlaying),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isMixtape 
                                  ? 'Infinito · 64 brani in rotazione'
                                  : '${currentTrack.artist} — ${currentTrack.title}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFD6D6D9),
                                height: 1.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Play/Pause button
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () => controller.togglePlayPause(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCover(TrackMetadata track) {
    final artwork = track.artworkLarge ?? track.artworkSmall;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 44,
        height: 44,
        child: artwork != null
            ? Image.network(
                artwork,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF1C1C1F),
      child: const Icon(Icons.radio, color: Color(0xFFC4D600), size: 24),
    );
  }

  Widget _buildTag(bool isMixtape, bool isPlaying) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isMixtape 
            ? const Color(0xFF3EFAC5) 
            : const Color(0xFFC4D600),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isMixtape ? 'MIXTAPE' : (isPlaying ? '● LIVE' : 'LIVE'),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.08,
          color: isMixtape ? Colors.black : Colors.black,
        ),
      ),
    );
  }
}
