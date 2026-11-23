/// Entità HTML con nome e relativo codice Unicode.
/// Le lettere accentate di Latin-1 (160–255) sono in ordine di codice a partire da 160.
const _latin1Names = [
  'nbsp', 'iexcl', 'cent', 'pound', 'curren', 'yen', 'brvbar', 'sect',
  'uml', 'copy', 'ordf', 'laquo', 'not', 'shy', 'reg', 'macr',
  'deg', 'plusmn', 'sup2', 'sup3', 'acute', 'micro', 'para', 'middot',
  'cedil', 'sup1', 'ordm', 'raquo', 'frac14', 'frac12', 'frac34', 'iquest',
  'Agrave', 'Aacute', 'Acirc', 'Atilde', 'Auml', 'Aring', 'AElig', 'Ccedil',
  'Egrave', 'Eacute', 'Ecirc', 'Euml', 'Igrave', 'Iacute', 'Icirc', 'Iuml',
  'ETH', 'Ntilde', 'Ograve', 'Oacute', 'Ocirc', 'Otilde', 'Ouml', 'times',
  'Oslash', 'Ugrave', 'Uacute', 'Ucirc', 'Uuml', 'Yacute', 'THORN', 'szlig',
  'agrave', 'aacute', 'acirc', 'atilde', 'auml', 'aring', 'aelig', 'ccedil',
  'egrave', 'eacute', 'ecirc', 'euml', 'igrave', 'iacute', 'icirc', 'iuml',
  'eth', 'ntilde', 'ograve', 'oacute', 'ocirc', 'otilde', 'ouml', 'divide',
  'oslash', 'ugrave', 'uacute', 'ucirc', 'uuml', 'yacute', 'thorn', 'yuml',
];

const _namedEntities = <String, int>{
  'amp': 0x26,
  'lt': 0x3C,
  'gt': 0x3E,
  'quot': 0x22,
  'apos': 0x27,
  'lsquo': 0x2018,
  'rsquo': 0x2019,
  'ldquo': 0x201C,
  'rdquo': 0x201D,
  'ndash': 0x2013,
  'mdash': 0x2014,
  'hellip': 0x2026,
  'euro': 0x20AC,
};

final _latin1Entities = {
  for (var i = 0; i < _latin1Names.length; i++) _latin1Names[i]: 160 + i,
};

final _entityPattern = RegExp(r'&(#[xX][0-9a-fA-F]+|#[0-9]+|[A-Za-z][A-Za-z0-9]*);');

/// Decodifica le entità HTML (con nome o numeriche, es. `&uuml;`, `&#252;`, `&#xFC;`)
/// in un'unica passata, così `&amp;uuml;` diventa `&uuml;` e non `ü`.
/// Le entità sconosciute restano invariate. Normalizza anche la punteggiatura tipografica.
String sanitizeHtmlText(String text) {
  final decoded = text.replaceAllMapped(_entityPattern, (match) {
    final body = match.group(1)!;
    final original = match.group(0)!;
    int? codePoint;
    if (body.startsWith('#x') || body.startsWith('#X')) {
      codePoint = int.tryParse(body.substring(2), radix: 16);
    } else if (body.startsWith('#')) {
      codePoint = int.tryParse(body.substring(1));
    } else {
      codePoint = _namedEntities[body] ?? _latin1Entities[body];
    }
    if (codePoint == null || codePoint > 0x10FFFF) return original;
    return String.fromCharCode(codePoint);
  });

  return decoded
      .replaceAll('\u2018', "'")
      .replaceAll('\u2019', "'")
      .replaceAll('\u201C', '"')
      .replaceAll('\u201D', '"')
      .replaceAll('\u2026', '...')
      .replaceAll('\u2013', '-')
      .replaceAll('\u2014', '-');
}
