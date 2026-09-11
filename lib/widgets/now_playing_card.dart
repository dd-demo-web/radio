import 'package:flutter/material.dart';

import '../models/track_metadata.dart';
import '../main.dart';

/// Card che mostra copertina, titolo e artista del brano in onda.
class NowPlayingCard extends StatelessWidget {
  final TrackMetadata track;

  const NowPlayingCard({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final artwork = track.artworkLarge ?? track.artworkSmall;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 320,
              maxHeight: MediaQuery.of(context).size.shortestSide * 0.5,
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: artwork != null
                    ? Image.network(
                        artwork,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                            ? child
                            : _placeholder(loading: true),
                      )
                    : _placeholder(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            track.title.isNotEmpty ? track.title : 'Radio Wah',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            track.artist,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (track.isNew || track.isHit) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (track.isNew)
                  _tag(context, 'NEW', RadioWahColors.deloitteGreen),
                if (track.isHit)
                  _tag(context, 'HIT', RadioWahColors.accentGreen),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _tag(BuildContext context, String label, Color color) {
    final useBlackText = color == RadioWahColors.deloitteGreen;
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: useBlackText ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _placeholder({bool loading = false}) {
    return Container(
      color: Colors.grey.shade900,
      child: Center(
        child: loading
            ? const CircularProgressIndicator()
            : const Icon(Icons.radio, size: 72, color: Colors.white54),
      ),
    );
  }
}
