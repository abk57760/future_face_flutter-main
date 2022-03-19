import 'dart:io';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:future_face_app/localization/localization_const.dart';
import 'package:future_face_app/main.dart';
import 'package:future_face_app/models/language.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void _changedLang(Language language) {
    Locale _temp;

    switch (language.languageCode) {
      case 'en':
        _temp = Locale(language.languageCode, 'US');
        break;
      case 'fr':
        _temp = Locale(language.languageCode, 'FR');
        break;
      case 'pt':
        _temp = Locale(language.languageCode, 'PT');
        break;
      case 'es':
        _temp = Locale(language.languageCode, 'ES');
        break;
      case 'zh':
        _temp = Locale(language.languageCode, 'CN');
        break;
      case 'ar':
        _temp = Locale(language.languageCode, 'SA');
        break;
      case 'hi':
        _temp = Locale(language.languageCode, 'IN');
        break;
      case 'ur':
        _temp = Locale(language.languageCode, 'PK');
        break;
      default:
        _temp = Locale(language.languageCode, 'US');
    }
    MyApp.setLocale(context, _temp);
  }

  Language activeLang = Language.languageList().first;

  List file = [];

  late final AdWidget adWidget;
  late final InterstitialAd _interstitialAd;
  late final double h, w;
  @override
  void initState() {
    super.initState();

    FacebookAudienceNetwork.init(
        //testingId: "37b1da9d-b48c-4103-a393-2e095e734bd6", //optional
        iOSAdvertiserTrackingEnabled: true //default false
        );
    loadintadd();
    loadbannerad();
    //_listofFiles();
  }

  void loadintadd() {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-2408614506049729/6644512291',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
          },
        ));
  }

  void loadbannerad() {
    BannerAd? myBanner = BannerAd(
      adUnitId: 'ca-app-pub-2408614506049729/5167779093',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => print('Ad loaded.'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Yeh error ha  $error.code');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('Ad opened.'),
        onAdClosed: (Ad ad) => print('Ad closed.'),
        onAdImpression: (Ad ad) => print('Ad impression.'),
      ),
    );
    myBanner.load();
    adWidget = AdWidget(ad: myBanner);

    w = myBanner.size.width.toDouble();
    h = myBanner.size.height.toDouble();
  }

  Future<bool> showExitPopup(context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.deepPurple,
            content: SizedBox(
              height: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Do you want to exit?",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            print('yes selected');
                            exit(0);
                          },
                          child: const Text("Yes"),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.red.shade800),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                          child: ElevatedButton(
                        onPressed: () {
                          print('no selected');
                          Navigator.of(context).pop();
                        },
                        child: const Text("No",
                            style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                        ),
                      ))
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: Scaffold(
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
            margin: const EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 40.0),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/splash-bg.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton<Language>(
                        onChanged: (Language? language) {
                          _changedLang(language!);
                          setState(() {
                            activeLang = language;
                          });
                          //print(language.name);
                        },
                        dropdownColor: Colors.deepPurple,
                        hint: Row(
                          children: [
                            Text(
                              activeLang.name,
                              style: const TextStyle(
                                  fontSize: 20.0, color: Colors.white),
                            ),
                            Text(
                              activeLang.flag,
                              style: const TextStyle(fontSize: 20.0),
                            ),
                          ],
                        ),
                        items: Language.languageList()
                            .map<DropdownMenuItem<Language>>((lang) =>
                                DropdownMenuItem(
                                  value: lang,
                                  key: Key(lang.flag),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Text(
                                        lang.name,
                                        style: const TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        lang.flag,
                                        style: const TextStyle(fontSize: 20.0),
                                      )
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _interstitialAd.show();
                          Navigator.pushNamed(context, '/album');
                        },
                        child: Row(
                          children: [
                            IconButton(
                              icon:
                                  SvgPicture.asset('assets/images/gallery.svg'),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 5.0),
                            Text(
                              getTranslated(context, 'Album'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          getTranslated(context, 'Future_Face'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          getTranslated(context, 'Moving_around_in_TIME'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 40.0),
                        const CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/splash-icon.png'),
                          radius: 130.0,
                        ),
                      ],
                    )
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    _interstitialAd.show();
                    Navigator.pushNamed(context, '/import');
                  },
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 40, 60),
                        child: SvgPicture.asset('assets/images/start.svg'),
                      ),
                      Positioned(
                        bottom: 15.0,
                        left: 15.0,
                        top: 18.0,
                        right: 1.0,
                        child: Column(
                          children: <Widget>[
                            InkWell(
                              child: Text(
                                getTranslated(context, 'Start'),
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
                    //child: Image.asset('assets/listback_image.JPG'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
