import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import 'notifications_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  bool _isSearching = false;
  String _searchQuery = '';

  final List<Map<String, String>> _songs = [
    {
      'quote': '“There is a light that never goes out, and it’s playing right here.”',
      'title': 'There Is a Light That Never Goes Out',
      'artist': 'The Smiths',
    },
    {
      'quote': '“Music is the soundtrack of your life when words are not enough.”',
      'title': 'Midnight City',
      'artist': 'M83',
    },
    {
      'quote': '“Let the rhythm take control and guide you through the night.”',
      'title': 'Around the World',
      'artist': 'Daft Punk',
    },
  ];

  final List<Map<String, String>> _moods = [
    {
      'id': 'poptherapy',
      'name': 'Pop Therapy',
      'phrase': 'Ritornelli che fanno bene',
      'image': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&auto=format&fit=crop&q=80',
    },
    {
      'id': 'nightshift',
      'name': 'Night Shift',
      'phrase': 'Elettronica per le ore tarde',
      'image': 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=600&auto=format&fit=crop&q=80',
    },
    {
      'id': 'deepfocus',
      'name': 'Deep Focus',
      'phrase': 'Ambient e suoni organici',
      'image': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&auto=format&fit=crop&q=80',
    },
    {
      'id': 'funkdeluxe',
      'name': 'Funk Deluxe',
      'phrase': 'Groove e bassline immortali',
      'image': 'https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?w=600&auto=format&fit=crop&q=80',
    },
    {
      'id': 'acoustic',
      'name': 'Acoustic Soul',
      'phrase': 'Voci e chitarre scrostate',
      'image': 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=600&auto=format&fit=crop&q=80',
    },
    {
      'id': 'analog',
      'name': 'Analog Dreams',
      'phrase': 'Synth caldi e nastri magnetici',
      'image': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=600&auto=format&fit=crop&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<RadioAppState>();
    final currentSong = _songs[appState.songIndex];

    final filteredMoods = _moods.where((m) {
      if (_searchQuery.isEmpty) return true;
      return (m['name']! + ' ' + m['phrase']!).toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header or Search Bar
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Cerca un mood o un mixtape',
                          hintStyle: const TextStyle(color: Color(0xFF8E8E94)),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFFA3A3A8)),
                          filled: true,
                          fillColor: const Color(0xFF1C1C1F),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _isSearching = false;
                        _searchQuery = '';
                      }),
                      child: const Text('Annulla', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Discover',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    Row(
                      children: [
                        if (RadioAppState.showSearch)
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => setState(() => _isSearching = true),
                          )
                        else
                          const SizedBox(width: 48),
                        if (RadioAppState.showNotifications)
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                            ),
                          )
                        else
                          const SizedBox(width: 48),
                      ],
                    ),
                  ],
                ),
              ),

            // Category Tabs (Mixtape / Dirette in archivio)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF16161A),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: const Text('Mixtape', style: TextStyle(color: Color(0xFF050506), fontSize: 13, fontWeight: FontWeight.w800)),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Switch or show archive view if desired
                      },
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.center,
                        child: const Text('Dirette in archivio', style: TextStyle(color: Color(0xFFD6D6D9), fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                children: [
                  if (!_isSearching) ...[
                    // Featured Quote Card (White background card matching prototype)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: List.generate(_songs.length, (i) {
                              final active = i == appState.songIndex;
                              return GestureDetector(
                                onTap: () => appState.setSongIndex(i),
                                child: Container(
                                  width: active ? 16 : 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(
                                    color: active ? const Color(0xFF111113) : const Color(0xFFC7C7CC),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentSong['quote']!,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontStyle: FontStyle.italic,
                              fontSize: 22,
                              color: Color(0xFF111113),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentSong['title']!,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111113)),
                                  ),
                                  Text(
                                    currentSong['artist']!,
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF5A5A60)),
                                  ),
                                ],
                              ),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111113),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Icon(Icons.share, color: Colors.white, size: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Esplora per mood',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${filteredMoods.length} mixtape',
                          style: const TextStyle(fontSize: 12, color: Color(0xFFA3A3A8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Mood Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 18,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filteredMoods.length,
                    itemBuilder: (context, index) {
                      final mood = filteredMoods[index];
                      return GestureDetector(
                        onTap: () {
                          appState.setActiveMix(mood['id']);
                          appState.setNavIndex(0); // Go to live player with active mix
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  mood['image']!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFF1C1C1F),
                                    child: const Icon(Icons.music_note, color: Color(0xFFC4D600)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mood['name']!,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              mood['phrase']!,
                              style: const TextStyle(fontSize: 13, color: Color(0xFFA3A3A8)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
