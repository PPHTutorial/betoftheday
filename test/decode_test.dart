import 'dart:convert';
import 'dart:typed_data';

void main() {
  // Examples from raw_schedule.html
  // Prediction: <span class="of-meta" meta-info="//4yADAAMgA2ADAAMgAxADkAB+A="></span>
  // Prediction: <span class="of-meta" meta-info="//4yADAAMgA2ADAAMgAxADkACOA="></span>
  // xG: <span class="of-meta" meta-info="//4H4AHgMgAwADIANgAwADIAMQA5AAbgDOA="></span>

  final inputs = [
    "//4yADAAMgA2ADAAMgAxADkAB+A=",
    "//4yADAAMgA2ADAAMgAxADkACOA=",
    "//4H4AHgMgAwADIANgAwADIAMQA5AAbgDOA="
  ];

  for (final input in inputs) {
    try {
      print('Input: $input');
      // 1. Remove // prefix? Or maybe it's part of the b64?
      // standard B64 usually doesn't start with // unless it's specific data.
      // But \xff\xfe is /v8= in B64.
      // Let's try decoding the whole string first.

      String cleanInput = input;
      // The slash might be valid b64 chars.

      Uint8List bytes = base64.decode(cleanInput);
      print(
          'Bytes (hex): ${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

      // Check for BOM (FF FE) -> UTF-16LE
      if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
        print('Detected UTF-16LE BOM');
        // Decode UTF-16LE
        // Dart doesn't have a direct Utf16Decoder in core, but we can iterate pairs
        final buffer = StringBuffer();
        for (int i = 2; i < bytes.length; i += 2) {
          if (i + 1 < bytes.length) {
            int codeUnit = bytes[i] | (bytes[i + 1] << 8);
            buffer.writeCharCode(codeUnit);
          }
        }
        print('Decoded UTF-16LE: "${buffer.toString()}"');
      } else {
        print(
            'Decoded ASCII/UTF8: "${utf8.decode(bytes, allowMalformed: true)}"');
      }
    } catch (e) {
      print('Error decoding: $e');
    }
    print('---');
  }
}
