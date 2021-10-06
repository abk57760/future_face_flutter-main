import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io' as io;
import 'package:future_face_app/localization/localization_const.dart';
import 'package:future_face_app/main.dart';
import 'package:future_face_app/models/language.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';

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
            // Keep a reference to the ad so you can show it later.

            _interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
          },
        ));
    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
      },
      onAdImpression: (InterstitialAd ad) => print('$ad impression occurred.'),
    );
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

  @override
  Widget build(BuildContext context) {
    // BannerAd bAd = BannerAd(
    //   size: AdSize.banner,
    //   adUnitId: 'ca-app-pub-2408614506049729/5167779093',
    //   listener: BannerAdListener(onAdLoaded: (Ad ad) {
    //     print("Ad loaded");
    //   }, onAdFailedToLoad: (Ad ad, LoadAdError error) {
    //     print("Ad not loaded");
    //     ad.dispose();
    //   }, onAdOpened: (Ad ad) {
    //     print("Ad loaded");
    //   }),
    //   request: const AdRequest(),
    // );
    return Scaffold(
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
                                          fontSize: 15.0, color: Colors.white),
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
                        if (_interstitialAd != null) {
                          _interstitialAd.show();
                        } else {
                          Navigator.pushNamed(
                            context,
                            '/album',
                          );
                        }
                      },
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_interstitialAd != null) {
                                _interstitialAd.show();
                              } else {
                                Navigator.pushNamed(
                                  context,
                                  '/album',
                                );
                              }
                            },
                            icon: SvgPicture.asset('assets/images/gallery.svg'),
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
                        radius: 120.0,
                      ),
                    ],
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
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
                                onTap: () {
                                  Navigator.pushNamed(context, '/import');
                                },
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
            ],
          ),
        ),
      ),
    );
  }
}
