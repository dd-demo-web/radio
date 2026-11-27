import 'package:flutter_test/flutter_test.dart';
import 'package:radio_wah/models/html_text.dart';

void main() {
  test('decodifica le entità con nome di vocali accentate', () {
    expect(sanitizeHtmlText('&uuml;&auml;&ouml;'), 'üäö');
    expect(sanitizeHtmlText('&agrave;&egrave;&igrave;&ograve;&ugrave;'), 'àèìòù');
    expect(sanitizeHtmlText('&Eacute;&Uuml;&ccedil;'), 'ÉÜç');
  });

  test('decodifica le entità numeriche decimali ed esadecimali', () {
    expect(sanitizeHtmlText('&#252;'), 'ü');
    expect(sanitizeHtmlText('&#xFC;'), 'ü');
  });

  test('decodifica una sola volta e lascia le entità sconosciute', () {
    expect(sanitizeHtmlText('&amp;uuml;'), '&uuml;');
    expect(sanitizeHtmlText('&unknown; &#xZZ;'), '&unknown; &#xZZ;');
  });
}
 