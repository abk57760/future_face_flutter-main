import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:future_face_app/constants/urls.dart';
import 'package:future_face_app/controllers/check_url.dart';
import 'package:future_face_app/localization/localization_const.dart';
import 'package:future_face_app/models/fileobject.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '/models/processed_image.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool? _isButtonDisabled;
  File? imageFile;
  Uint8List? imgBytes;
  double _currentSliderValue = 65;
  String statusMessage = "";
  bool hasRequestError = true;
  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;

  void navigateBack(BuildContext context) {
    Future.delayed(
      const Duration(seconds: 1),
      () => {
        Navigator.pop(context),
      },
    );
  }

  void updateStatusDisplay(
      BuildContext context, String message, bool isErrorMsg) {
    setState(() {
      statusMessage = message;
      // Fluttertoast.showToast(msg: statusMessage);
      if (isErrorMsg) hasRequestError = true;
    });

    // if there's an error, navigate to previous screen
    if (isErrorMsg) Navigator.pop(context);
  }

  Future<bool> isDeviceConnected() async {
    return true;
  }

  void uploadImageToServer(File image, [double ageValue = 65.0]) async {
    String activePostServerURI = "";
    bool isAnyServerOnline = false;

    updateStatusDisplay(context, "Applying age filter.\nPlease wait...", false);

    if (await isDeviceConnected()) {
      if (await checkURL(futureFaceServerURL)) {
        if (mounted) {
          setState(() {
            isAnyServerOnline = true;
            activePostServerURI = futureFacePostURL;
          });
        }
      } else {
        navigateBack(context);
      }

      if (isAnyServerOnline) {
        // print("Uploading image: $activePostServerURI");

        // build multipart request and send
        var request =
            http.MultipartRequest("POST", Uri.parse(activePostServerURI));
        request.files.add(await http.MultipartFile.fromPath('img', image.path,
            filename: image.path));
        request.fields['age'] = ageValue.toInt().toString();

        request.send().then((response) {
          // listen for response stream
          http.Response.fromStream(response).then((value) {
            // response OK
            if (value.statusCode == 200) {
              //print("Response Headers:");
              //print(value.headers);

              //print("Response (Base64):");

              Map<String, dynamic> imgResponseMap = json.decode(value.body);
              ProcessedImage imgResponse =
                  ProcessedImage.fromJson(imgResponseMap);
              //print(imgResponse.s0);

              if (imgResponse.s0 != null) {
                if (mounted) {
                  setState(() {
                    imgBytes = const Base64Decoder().convert(imgResponse.s0!);
                    imgBytes = Uint8List.fromList(imgBytes!);
                    // print("Response (Unsigned Int8 List):");
                    // print(imgBytes);

                    imageFile = File.fromRawPath(imgBytes!);
                  });
                }
              } else {
                if (mounted) {
                  Fluttertoast.showToast(
                      msg: "Error retrieving data.\nPlease try again.");
                  updateStatusDisplay(context,
                      "Error retrieving data.\nPlease try again.", true);
                }
              }
            } else {
              if (mounted) {
                Fluttertoast.showToast(
                    msg: "Error in uploading File  \n Please Try Again");
                updateStatusDisplay(
                    context, "Error uploading file.\nPlease try again.", true);
              }
            }
          });
        });
      } else {
        if (mounted) {
          Fluttertoast.showToast(
              msg: "Resource Server are busy. \nPlease try again.");
          updateStatusDisplay(
              context, "Resource server is down.\nPlease try later.", true);
        }
      }
    } else {
      if (mounted) {}
    }
  }

  Future saveandshare(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/flutter.png');
    image.writeAsBytesSync(bytes);

    await Share.shareFiles([image.path]);
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  Future<bool> saveImage(Uint8List bytes) async {
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = (await getExternalStorageDirectory())!;
          String newPath = "";
          // print(directory);

          newPath = directory.path + "/Future_Face_App";
          directory = Directory(newPath);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      } else if (await directory.exists()) {
        if (_interstitialAd != null) {
          _interstitialAd.show();
          loadintadd();
          final time = DateTime.now()
              .toIso8601String()
              .replaceAll(",", "-")
              .replaceAll(":", "-");

          final name = 'Futureface-$time';

          File saveFile = File(directory.path + "/$name.png");
          saveFile.writeAsBytes(bytes.buffer
              .asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
          await ImageGallerySaver.saveImage(bytes, name: name);
          Fluttertoast.showToast(msg: "Image Saved");
          Navigator.pushNamed(context, '/album');
          if (Platform.isIOS) {
            await ImageGallerySaver.saveFile(saveFile.path,
                isReturnPathOfIOS: true);
          }
          return true;
        } else {
          final time = DateTime.now()
              .toIso8601String()
              .replaceAll(",", "-")
              .replaceAll(":", "-");

          final name = 'Futureface-$time';

          File saveFile = File(directory.path + "/$name.png");
          saveFile.writeAsBytes(bytes.buffer
              .asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
          await ImageGallerySaver.saveImage(bytes, name: name);
          Fluttertoast.showToast(msg: "Image Saved");
          Navigator.pushNamed(context, '/album');
          if (Platform.isIOS) {
            await ImageGallerySaver.saveFile(saveFile.path,
                isReturnPathOfIOS: true);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      //print(e);
      return false;
    }
  }

  late final AdWidget adWidget;
  late final InterstitialAd _interstitialAd;
  @override
  void initState() {
    super.initState();
    _isButtonDisabled = false;
    loadintadd();
    FacebookAudienceNetwork.init(
        testingId: "37b1da9d-b48c-4103-a393-2e095e734bd6", //optional
        iOSAdvertiserTrackingEnabled: true //default false
        );
    Future.delayed(
      const Duration(seconds: 1),
      () {
        if (imageFile != null) {
          uploadImageToServer(imageFile!);
        } else {
          Fluttertoast.showToast(msg: "Failed to load image ");
        }
      },
    );
  }

  void Loadfb() {
    FacebookInterstitialAd.loadInterstitialAd(
      placementId: "IMG_16_9_APP_INSTALL#YOUR_PLACEMENT_ID",
      listener: (result, value) {
        if (result == InterstitialAdResult.LOADED) {
          FacebookInterstitialAd.showInterstitialAd();
        }
      },
    );
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

  @override
  Widget build(BuildContext context) {
    setState(() {
      imageFile = Fileobject.getFile();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'Result')),
        actions: [
          if (imgBytes == null)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              children: [
                InkWell(
                  onTap: () {
                    saveImage(imgBytes!);
                  },
                  child: const Icon(Icons.save, size: 30.0),
                ),
                const SizedBox(width: 10.0),
                InkWell(
                  onTap: () {
                    saveandshare(imgBytes!);
                  },
                  child: const Icon(Icons.share, size: 30.0),
                ),
                const SizedBox(width: 20.0),
              ],
            ),
        ],
      ),
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
        child: Container(
          margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/splash-bg.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  (imgBytes == null)
                      ? const CircularProgressIndicator(color: Colors.white70)
                      : (CarouselSlider(
                          items: [
                            Container(
                              margin: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                image: DecorationImage(
                                  image: FileImage(imageFile!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                image: DecorationImage(
                                  image: MemoryImage(imgBytes!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                          options: CarouselOptions(
                            height: 300.0,
                            reverse: false,
                            enableInfiniteScroll: false,
                          ),
                        )),
                  const SizedBox(
                    height: 60.0,
                    width: 60.0,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          getTranslated(context, 'Drag_slider_to_adjust_age'),
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CupertinoSlider(
                          value: _currentSliderValue,
                          min: 25,
                          max: 65,
                          divisions: 4,
                          activeColor: Colors.white,
                          //label: _currentSliderValue.round().toString(),
                          onChanged: (value) {
                            if (mounted) {
                              setState(() {
                                _currentSliderValue = value;
                              });
                            }
                          },
                          onChangeEnd: (value) {
                            setState(() {
                              _isButtonDisabled = true;
                            });
                          },
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Current Age: ${_currentSliderValue.toInt()}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 25),
                        (_isButtonDisabled == true)
                            ? ElevatedButton(
                                onPressed: () {
                                  const CircularProgressIndicator(
                                      color: Colors.white70);
                                  uploadImageToServer(
                                      imageFile!, _currentSliderValue);
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      (getTranslated(context, 'Proceed')),
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Container()
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
