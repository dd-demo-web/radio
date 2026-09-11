import 'dart:ui';

import 'package:flutter/material.dart';

/// Sfondo a schermo intero con la copertina del brano corrente, sfocata e
/// scurita leggermente, in modo da essere presente ma poco percettibile
/// (come nel player ufficiale radiowah.deloitte.it).
class BlurredArtworkBackground extends StatelessWidget {
  final String? artworkUrl;

  const BlurredArtworkBackground({super.key, required this.artworkUrl});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRect(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          child: artworkUrl == null
              ? Container(key: const ValueKey('empty'), color: Colors.black)
              : Image.network(
                  artworkUrl!,
                  key: ValueKey(artworkUrl),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(color: Colors.black),
                ),
        ),
      ),
    );
  }
}

/// Applica la sfocatura e l'oscuramento sopra l'immagine di sfondo, così il
/// contenuto in primo piano resta sempre ben leggibile.
class BlurredArtworkOverlay extends StatelessWidget {
  const BlurredArtworkOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
        child: Container(color: Colors.black.withValues(alpha: 0.55)),
      ),
    );
  }
}
