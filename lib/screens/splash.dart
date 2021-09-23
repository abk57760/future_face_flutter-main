import 'package:flutter/material.dart';
import 'package:future_face_app/localization/localization_const.dart';
import 'package:future_face_app/main.dart';
import 'package:future_face_app/models/language.dart';

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
      default:
        _temp = Locale(language.languageCode, 'US');
    }
    MyApp.setLocale(context, _temp);
  }

  Language activeLang = Language.languageList().first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        print(language.name);
                      },
                      dropdownColor: Colors.deepPurple,
                      hint: Row(
                        children: [
                          Text(
                            activeLang.name,
                            style: const TextStyle(
                                fontSize: 20.0, color: Colors.white),
                          ),
                          Text(activeLang.flag),
                        ],
                      ),
                      icon: const Icon(Icons.language, color: Colors.white),
                      items: Language.languageList()
                          .map<DropdownMenuItem<Language>>(
                              (lang) => DropdownMenuItem(
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
                                        Text(lang.flag)
                                      ],
                                    ),
                                  ))
                          .toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          const Icon(
                            Icons.photo,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5.0),
                          Text(
                            getTranslated(context, 'Album')!,
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
                        getTranslated(context, 'Future_Face')!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40.0,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Text(
                        getTranslated(context, 'Moving_around_in_TIME')!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 50.0),
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
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    margin: const EdgeInsets.only(bottom: 10.0),
                    height: 100.0,
                    constraints: const BoxConstraints(
                      maxWidth: 200.0,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/import');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            getTranslated(context, 'Start')!,
                            style: const TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                          //const SizedBox(width: 3.0),
                          const Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white,
                            size: 30.0,
                          ),
                        ],
                      ),
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
