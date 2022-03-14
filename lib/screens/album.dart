import 'dart:io';
import 'dart:io' as io;
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:future_face_app/models/fileobject.dart';
import 'package:future_face_app/screens/share_album.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({Key? key}) : super(key: key);

  @override
  _AlbumScreenState createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  List filerec = [];
  int activeindex = 0;

  void navigateBack(BuildContext context) {
    Future.delayed(
      const Duration(seconds: 0),
      () => {
        Navigator.pop(context),
      },
    );
  }

  int num = 0;
  late final AdWidget adWidget;

  @override
  void initState() {
    super.initState();
    _listofFiles();
    FacebookAudienceNetwork.init(
        testingId: "37b1da9d-b48c-4103-a393-2e095e734bd6", //optional
        iOSAdvertiserTrackingEnabled: true //default false
        );
  }

  void loadfb() {
    FacebookInterstitialAd.loadInterstitialAd(
      placementId: "IMG_16_9_APP_INSTALL#YOUR_PLACEMENT_ID",
      listener: (result, value) {
        if (result == InterstitialAdResult.LOADED) {
          FacebookInterstitialAd.showInterstitialAd();
        }
      },
    );
  }

  void _listofFiles() async {
    Directory directory;
    directory = (await getExternalStorageDirectory())!;
    String newPath = directory.path + "/Future_Face_App";
    directory = Directory(newPath);
    //print(directory);
    if (directory.existsSync()) {
      setState(() {
        filerec = io.Directory(directory.path).listSync();
      });
    } else {
      Fluttertoast.showToast(msg: "No directory exists");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Future Face')),
      body: Container(
        padding: const EdgeInsets.all(10.0),
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
        child: GridView.builder(
          itemCount: filerec.length,
          reverse: false,
          padding: const EdgeInsets.all(2.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 5.0, mainAxisSpacing: 5.0),
          itemBuilder: (BuildContext context, int index) {
            return Center(
              child: Card(
                elevation: 20.0,
                shape: Border.all(width: 4),
                child: InkWell(
                  onTap: () {
                    activeindex = index;
                    Fileobject.set(index);
                    //print(index);
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (ctx) => const AlbumResult()))
                        .then((context) {
                      _listofFiles();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 20,
                      child: ((Image.file(filerec[index]))),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
