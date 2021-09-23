import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:future_face_app/constants/urls.dart';
import 'package:future_face_app/controllers/check_url.dart';
import 'package:future_face_app/localization/localization_const.dart';
import 'package:getwidget/getwidget.dart';
import 'package:http/http.dart' as http;
import 'package:gallery_saver/gallery_saver.dart';
import '/models/processed_image.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  File? imageFile;
  Uint8List? imgBytes;
  double _currentSliderValue = 65.0;
  String statusMessage = "";
  bool hasRequestError = true;

  void navigateBack(BuildContext context) {
    Future.delayed(
      const Duration(seconds: 3),
      () => {
        Navigator.pop(context),
      },
    );
  }

  void updateStatusDisplay(
      BuildContext context, String message, bool isErrorMsg) {
    setState(() {
      statusMessage = message;
      if (isErrorMsg) hasRequestError = true;
    });

    // if there's an error, navigate to previous screen
    if (isErrorMsg) navigateBack(context);
  }

  Future<bool> isDeviceConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
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
        print("Uploading image: $activePostServerURI");

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
              print("Response Headers:");
              print(value.headers);

              print("Response (Base64):");
              Map<String, dynamic> imgResponseMap = json.decode(value.body);
              ProcessedImage imgResponse =
                  ProcessedImage.fromJson(imgResponseMap);
              print(imgResponse.s0);

              if (imgResponse.s0 != null) {
                if (mounted) {
                  setState(() {
                    imgBytes = const Base64Decoder().convert(imgResponse.s0!);
                    imgBytes = Uint8List.fromList(imgBytes!);
                    print("Response (Unsigned Int8 List):");
                    print(imgBytes);
                  });
                }
              } else {
                if (mounted) {
                  updateStatusDisplay(context,
                      "Error retrieving data.\nPlease try again.", true);
                }
              }
            } else {
              if (mounted) {
                updateStatusDisplay(
                    context, "Error uploading file.\nPlease try again.", true);
              }
            }
          });
        });
      } else {
        if (mounted) {
          updateStatusDisplay(
              context, "Resource server is down.\nPlease try later.", true);
        }
      }
    } else {
      if (mounted) {
        updateStatusDisplay(
            context,
            "No internet connectivity.\nPlease ensure your device is connected to the internet.",
            true);
      }
    }
  }

  // Future<bool> saveImageToGallery(File imageFileToSave) async {
  //   Directory directory;
  //   try {
  //     if (Platform.isAndroid) {
  //       if (await requestPermission(Permission.storage)) {
  //         directory = (await getExternalStorageDirectory())!;
  //         // build Android root (emulated) path
  //         String newPath = "";
  //         List<String> paths = directory.path.split("/");
  //         for (int x = 1; x < paths.length; x++) {
  //           String folder = paths[x];
  //           if (folder != "Android") {
  //             newPath += "/" + folder;
  //           } else {
  //             break;
  //           }
  //         }
  //         // create FutureFace directory in emulated directory
  //         newPath = newPath + '/$galleryPathName';
  //         directory = Directory(newPath);
  //       } else {
  //         return false;
  //       }
  //     } else {
  //       // if iOS platform, simply request permission and store temporarily
  //       if (await requestPermission(Permission.photos)) {
  //         directory = await getTemporaryDirectory();
  //       } else {
  //         return false;
  //       }
  //     }

  //     // generate a temporary file path to store file at
  //     Random rng = Random();
  //     int randNum = rng.nextInt(10000) + rng.nextInt(10000);
  //     File saveFile =
  //         File(directory.path + "/$imageFileNamePrefix-$randNum.png");

  //     // check FutureFace directory if does not exist
  //     if (!await directory.exists()) {
  //       await directory.create(recursive: true);
  //     }

  //     // ensure FutureFace directory is created
  //     if (await directory.exists()) {
  //       // write file to iOS gallery
  //       if (Platform.isIOS) {
  //         // await ImageGallerySaver.saveFile(saveFile.path,
  //         //     isReturnPathOfIOS: true);
  //       } else {
  //         await imageFileToSave.copy(saveFile.path);
  //       }

  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     print(e);
  //     return false;
  //   }
  // }

  // Future<bool> requestPermission(Permission permission) async {
  //   if (await permission.isGranted) {
  //     return true;
  //   } else {
  //     var result = await permission.request();
  //     if (result == PermissionStatus.granted) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 3),
      () {
        if (imageFile != null) {
          uploadImageToServer(imageFile!);
        } else {
          print('Failed loading image file.');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Map data = ModalRoute.of(context)!.settings.arguments as Map;

    setState(() {
      imageFile = data['image'];
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'Result')!),
        actions: [
          (imgBytes == null)
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        if (imageFile == null) {
                          return;
                        } else if (imageFile != null) {
                          await GallerySaver.saveImage(imageFile!.path);
                          Fluttertoast.showToast(msg: "Image saved to Gallery");
                        } else {
                          Fluttertoast.showToast(
                              msg: "Error in  saving  to Gallery");
                        }
                      },
                      child: const Icon(Icons.save, size: 30.0),
                    ),
                    const SizedBox(width: 10.0),
                    InkWell(
                      onTap: () async {
                        const channel =
                            MethodChannel('channel:me.albie.share/share');
                        channel.invokeMethod('shareFile', 'image.jpg');
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (imgBytes == null)
                      ? const CircularProgressIndicator(color: Colors.white70)
                      : GFAvatar(
                          backgroundImage: MemoryImage(imgBytes!),
                          shape: GFAvatarShape.standard,
                          radius: 150.0,
                        ),
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
                          getTranslated(context, 'Drag_slider_to_adjust_age')!,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Slider(
                          value: _currentSliderValue,
                          min: 25,
                          max: 65,
                          divisions: 4,
                          label: _currentSliderValue.round().toString(),
                          onChanged: (value) {
                            if (mounted) {
                              setState(() {
                                _currentSliderValue = value;
                              });
                            }
                          },
                          onChangeEnd: (value) {
                            if (mounted) {
                              setState(() {
                                imgBytes = null;
                              });
                            }
                            uploadImageToServer(
                                imageFile!, _currentSliderValue);
                          },
                        ),
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
