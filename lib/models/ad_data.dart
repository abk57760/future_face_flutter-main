import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  Future<InitializationStatus> initialization;
  AdState(this.initialization);

  // String get bannerAdUintId => Platform.isAndroid
  //     ? 'ca-app-pub-2408614506049729/5167779093'
  //     : 'ca-app-pub-3940256099942544~3347511713';

  BannerAdListener get adListener => _adlistner;

  final BannerAdListener _adlistner = BannerAdListener(
      onAdLoaded: (ad) => print('Ad loaded : ${ad.adUnitId} .'),
      onAdClosed: (ad) => print('Ad Closed : ${ad.adUnitId} .'),
      onAdFailedToLoad: (ad, error) =>
          print('Ad failed to load : ${ad.adUnitId} , $error'),
      onAdOpened: (ad) => print("Ad openned: ${ad.adUnitId},"));
}
