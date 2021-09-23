import 'package:http/http.dart' as http;

Future<bool> checkURL(String url) async {
  try {
    final response = await http.head(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Server response OK');
      return true;
    }
  } catch (ex) {
    print(ex);
  }
  return false;
}
