import 'dart:convert';
import 'dart:typed_data';

String decodePredicd(String input) {
  try {
    Uint8List bytes = base64.decode(input);
    if (bytes.length < 2 || bytes[0] != 0xFF || bytes[1] != 0xFE)
      return "ERROR_BOM";

    final buffer = StringBuffer();
    for (int i = 2; i < bytes.length; i += 2) {
      if (i + 1 < bytes.length) {
        int codeUnit = bytes[i] | (bytes[i + 1] << 8);
        buffer.writeCharCode(codeUnit);
      }
    }
    String decoded = buffer.toString();
    // Remove the 8-digit date pattern
    return decoded.replaceAll(RegExp(r'\d{8}'), '');
  } catch (e) {
    return "ERROR: $e";
  }
}

void main() {
  final Map<String, String> data = {
    "Match 1 Home Pred": "//4yADAAMgA2ADAAMgAxADkAB+A=",
    "Match 1 Away Pred": "//4yADAAMgA2ADAAMgAxADkACOA=",
    "Match 1 xG Home": "//4H4AHgMgAwADIANgAwADIAMQA5AAbgDOA=",
    "Match 1 xG Away": "//4H4AHgMgAwADIANgAwADIAMQA5AAngC+A=",
    // From Select-String output
    "Match 2 Home Pred":
        "//4yADAAMgA2ADAAMgAxADkAB+A=", // Same as M1 Home -> \uE007
    "Match 2 Away Pred": "//4yADAAMgA2ADAAMgAxADkABuA=",
    "Match 3 Home Pred": "//4yADAAMgA2ADAAMgAxADkACOA=",
    "Match 3 Away Pred": "//4yADAAMgA2ADAAMgAxADkAB+A=",
    "xG Entry 1": "//4H4AHgMgAwADIANgAwADIAMQA5AAngCeA=",
    "xG Entry 2": "//4H4AHgMgAwADIANgAwADIAMQA5AAjgDuA=",
    "xG Entry 3": "//4H4AHgMgAwADIANgAwADIAMQA5AArgDeA=",
    "xG Entry 4": "//4G4AHgMgAwADIANgAwADIAMQA5AA/gCOA=",
  };

  data.forEach((key, val) {
    String decoded = decodePredicd(val);
    String unicodeRepr = decoded.runes
        .map((r) => 'U+${r.toRadixString(16).padLeft(4, '0').toUpperCase()}')
        .join(' ');
    print('$key: "$decoded" ($unicodeRepr)');
  });
}
