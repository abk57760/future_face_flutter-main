import 'dart:io' as io;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:future_face_app/models/fileobject.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AlbumResult extends StatefulWidget {
  const AlbumResult({Key? key}) : super(key: key);

  @override
  _AlbumResultState createState() => _AlbumResultState();
}

void navigateBack(BuildContext context) {
  Future.delayed(
    const Duration(seconds: 0),
    () => {
      Navigator.pop(context),
    },
  );
}

class _AlbumResultState extends State<AlbumResult> {
  int? activeindex;

  List file = [];
  File? imgFile;
  @override
  void initState() {
    super.initState();
    _listofFiles();
  }

  Future saveandshare(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/flutter.png');
    image.writeAsBytesSync(bytes);

    await Share.shareFiles([image.path]);
  }

  void _listofFiles() async {
    Directory directory;
    directory = (await getExternalStorageDirectory())!;
    String newPath = directory.path + "/Future_Face_App";
    directory = Directory(newPath);
    //print(directory);
    if (directory.existsSync()) {
      setState(() {
        file = io.Directory(directory.path).listSync();
      });
    } else {
      Fluttertoast.showToast(msg: "No directory exists");
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      activeindex = Fileobject.get();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Future Face'), actions: [
        Row(
          children: [
            InkWell(
              onTap: () {
                File filepath = file[activeindex!];
                Uint8List bytes = filepath.readAsBytesSync();

                saveandshare(bytes);
              },
              child: const Icon(Icons.share, size: 30.0),
            ),
            const SizedBox(width: 20.0),
            InkWell(
              onTap: () {
                setState(() {
                  File filepath = file[activeindex!];
                  filepath.delete();
                  Fluttertoast.showToast(msg: "Image Deleted Successfully");
                  Navigator.pop(context);
                });
              },
              child: const Icon(Icons.delete, size: 30.0),
            ),
            const SizedBox(width: 20.0),
          ],
        ),
      ]),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
            colors: [
              Color.fromRGBO(179, 111, 212, 1),
              Color.fromRGBO(103, 87, 186, 1),
            ],
          ),
        ),
        child: Center(
          widthFactor: 40.0,
          heightFactor: 40.0,
          child: Image.file(file[activeindex!]),
        ),
      ),
    );
  }
}
