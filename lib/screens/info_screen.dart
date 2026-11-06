import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  final bool openFaq;

  const InfoScreen({super.key, this.openFaq = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: const Color(0xFF050506),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text('Info', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC4D600),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.mail_outline, color: Color(0xFF050506), size: 18),
                                      SizedBox(width: 8),
                                      Text('Contattaci', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF050506))),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Text('itwahradio@mail.com', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF050506))),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF121214),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF2A2A2E)),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.help_outline, color: Color(0xFF3EFAC5), size: 18),
                                      SizedBox(width: 8),
                                      Text('FAQ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Text('Domande frequenti', style: TextStyle(fontSize: 12, color: Color(0xFFA3A3A8))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?w=800&auto=format&fit=crop&q=80',
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(height: 220, color: const Color(0xFF1C1C1F)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('LA REDAZIONE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: Color(0xFFA3A3A8))),
                      const SizedBox(height: 8),
                      const Text(
                        'Fuori dalle rotte conosciute.',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121214),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DIRETTORE ARTISTICO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: Color(0xFFC4D600))),
                            SizedBox(height: 4),
                            Text('Andrea Laurenza', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Alessandro Aricò, Enrico Barrano, Chiara Beccherle, Arianna Milene Benavides Isves, Riccardo Berticelli, Laura Botticini, Alessandro Camatta, Michele Canarino, Iacopo Carli, Flaminia Carli, Caterina Checcacci, Fiorentino Ciampi, Sara Colombo, Nicola Montefusco, Roberta Normano, Andrea Restelli, Serena Santoriello, Marco Scipolo, Mario Turco, Angelo Volpicella.',
                        style: TextStyle(fontSize: 15, color: Color(0xFFD6D6D9), height: 1.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (openFaq)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 500,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF141416),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(color: const Color(0xFF3A3A40), borderRadius: BorderRadius.circular(3)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Domande frequenti', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Come ascoltare in alta qualità?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                SizedBox(height: 4),
                                Text('Radio WAH trasmette a 320 kbps AAC. Puoi attivare il risparmio dati in Wi-Fi dal tuo profilo.', style: TextStyle(fontSize: 14, color: Color(0xFFA3A3A8), height: 1.4)),
                                SizedBox(height: 16),
                                Text('Quanto tempo restano le puntate in archivio?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                SizedBox(height: 4),
                                Text('Tutte le dirette restano disponibili in archivio per 30 giorni.', style: TextStyle(fontSize: 14, color: Color(0xFFA3A3A8), height: 1.4)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
