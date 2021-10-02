import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

Future<bool> checkURL(String url) async {
  try {
    final response = await http.head(Uri.parse(url));

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Please wait..");
      return true;
    } else {
      Fluttertoast.showToast(msg: "Failed to load image ");
    }
  } catch (ex) {
    return false;
  }
  Fluttertoast.showToast(msg: "Failed to load image ");
  return false;
}
