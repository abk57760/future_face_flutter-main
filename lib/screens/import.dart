import 'dart:io';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:future_face_app/localization/localization_const.dart';
import 'package:future_face_app/models/fileobject.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import '/constants/theme.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({Key? key}) : super(key: key);

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  File? imageFile, oldImageFile;
  String screenTitle = "Imported Picture";

  Future pickImage(ImageSource source) async {
    oldImageFile = imageFile;

    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    setState(() {
      if (pickedImage != null) {
        //print("Image Loaded");
        imageFile = File(pickedImage.path);
        if (_interstitialAd != null) {
          _interstitialAd.show();
          _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) =>
                print('$ad onAdShowedFullScreenContent.'),
            onAdDismissedFullScreenContent: (InterstitialAd ad) {},
            onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
              print('$ad onAdFailedToShowFullScreenContent: $error');
              ad.dispose();
            },
          );

          loadintadd();
          cropAndResizeImage(imageFile!);
        } else {
          cropAndResizeImage(imageFile!);
        }
      } else {
        Fluttertoast.showToast(msg: "No Image Selected");
      }
    });
  }

  late final AdWidget adWidget;
  late final InterstitialAd _interstitialAd;
  late final double h, w;
  @override
  void initState() {
    super.initState();
    // _listofFiles();
    loadbannerad();
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

  void loadbannerad() {
    BannerAd myBanner = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) => print('Ad loaded.'),
        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          // Dispose the ad here to free resources.
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) => print('Ad opened.'),
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) => print('Ad closed.'),
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) => print('Ad impression.'),
      ),
    );
    myBanner.load();
    adWidget = AdWidget(ad: myBanner);

    w = myBanner.size.width.toDouble();
    h = myBanner.size.height.toDouble();
  }

  Future cropAndResizeImage(File imageFileToCrop) async {
    String _title = getTranslated(context, 'Resize_Image');
    File? croppedImage = await ImageCropper.cropImage(
        sourcePath: imageFileToCrop.path,
        compressFormat: ImageCompressFormat.png,
        compressQuality: 60,
        maxWidth: 1000,
        maxHeight: 1000,
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: _title,
            toolbarColor: kPrimaryColor,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: kPrimaryColor,
            statusBarColor: kPrimaryColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: _title,
        ));

    setState(() {
      screenTitle = getTranslated(context, 'Resize_Image');
      if (croppedImage != null) {
        Fluttertoast.showToast(msg: "Image Cropped Successfully");
        imageFile = croppedImage;
      } else {
        imageFile = oldImageFile;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, "Import_Picture")),
      ),
      bottomNavigationBar: Container(
        alignment: Alignment.center,
        child: adWidget,
        width: w,
        height: h,
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
              (imageFile != null)
                  ? GFAvatar(
                      backgroundImage: FileImage(imageFile!),
                      shape: GFAvatarShape.square,
                      radius: 150.0,
                    )
                  : const GFAvatar(
                      backgroundImage:
                          AssetImage('assets/images/user-avatar.png'),
                      shape: GFAvatarShape.circle,
                      radius: 150.0,
                    ),
              (imageFile == null) ? pickImageOptionsRow() : proceedOptionRow(),
            ],
          ),
        ),
      ),
    );
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

  Widget pickImageOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20.0),
          constraints: const BoxConstraints(
            maxWidth: 200.0,
          ),
          width: 160.0,
          height: 130.0,
          child: ElevatedButton(
            onPressed: () async {
              if (await _requestPermission(Permission.storage)) {
                pickImage(ImageSource.gallery);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () async {
                      if (await _requestPermission(Permission.storage)) {
                        pickImage(ImageSource.gallery);
                      }
                    },
                    icon: SvgPicture.asset('assets/images/gallery.svg')),
                const SizedBox(height: 10.0),
                Text(
                  getTranslated(context, 'Gallery'),
                  style: const TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20.0),
          constraints: const BoxConstraints(
            maxWidth: 200.0,
          ),
          width: 160.0,
          height: 130.0,
          child: ElevatedButton(
            onPressed: () async {
              if (await _requestPermission(Permission.camera)) {
                pickImage(ImageSource.camera);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () async {
                      if (await _requestPermission(Permission.camera)) {
                        pickImage(ImageSource.camera);
                      }
                    },
                    icon: SvgPicture.asset('assets/images/camera.svg')),
                const SizedBox(height: 10.0),
                Text(
                  getTranslated(context, 'Camera'),
                  style: const TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget proceedOptionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () async {
            Fileobject.setFile(imageFile!);
            if (await ConnectivityWrapper.instance.isConnected) {
              Navigator.pushNamed(
                context,
                '/result',
              );
            } else {
              Fluttertoast.showToast(
                  msg: "Please Check your Internet Conntection");
            }
          },
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                child: SvgPicture.asset('assets/images/proceed.svg'),
              ),
              Positioned(
                bottom: 10.0,
                left: 65.0,
                top: 10.0,
                right: 35.0,
                child: InkWell(
                  child: Text(
                    getTranslated(context, 'Proceed'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
