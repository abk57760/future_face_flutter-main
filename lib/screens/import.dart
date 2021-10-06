import 'dart:io';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:future_face_app/localization/localization_const.dart';
import 'package:future_face_app/models/fileobject.dart';
import 'package:getwidget/getwidget.dart';
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

        cropAndResizeImage(imageFile!);
      } else {
        Fluttertoast.showToast(msg: "No Image Selected");
      }
    });
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
                left: 0.0,
                top: 10.0,
                right: 35.0,
                child: Column(
                  children: <Widget>[
                    InkWell(
                      child: Text(
                        getTranslated(context, 'Proceed'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
