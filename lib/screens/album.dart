import 'dart:io';
import 'dart:io' as io;
import 'package:flutter/cupertino.dart';
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
  late final InterstitialAd _interstitialAd;
  @override
  void initState() {
    super.initState();
    _listofFiles();
    loadintadd();
  }

  void loadintadd() {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/1033173712',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            loadintadd();
          },
          onAdFailedToLoad: (LoadAdError error) {
            Fluttertoast.showToast(msg: "Add not  loaded successfully");
            loadintadd();
            print('InterstitialAd failed to load: $error');
          },
        ));
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
                    if (_interstitialAd != null) {
                      _interstitialAd.show();
                      _interstitialAd.fullScreenContentCallback =
                          FullScreenContentCallback(
                        onAdShowedFullScreenContent: (InterstitialAd ad) =>
                            print('$ad onAdShowedFullScreenContent.'),
                        onAdDismissedFullScreenContent: (InterstitialAd ad) {},
                        onAdFailedToShowFullScreenContent:
                            (InterstitialAd ad, AdError error) {
                          print(
                              '$ad onAdFailedToShowFullScreenContent: $error');
                          ad.dispose();
                        },
                      );
                      loadintadd();
                      _interstitialAd.show();
                      activeindex = index;
                      Fileobject.set(index);
                      //print(index);
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (ctx) => const AlbumResult()))
                          .then((context) {
                        _listofFiles();
                      });
                    } else {
                      _interstitialAd.show();
                      activeindex = index;
                      Fileobject.set(index);
                      //print(index);
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (ctx) => const AlbumResult()))
                          .then((context) {
                        _listofFiles();
                      });
                    }
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
