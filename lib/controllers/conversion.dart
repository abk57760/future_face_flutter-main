import 'dart:convert';
import 'dart:typed_data';

Uint8List convertBase64ToUint(String base64) {
  return Uint8List.fromList(const Base64Decoder().convert(base64));
}
 