import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:future_face_app/localization/demo_localization.dart';

String getTranslated(BuildContext context, String value) {
  if (DemoLocalizations.of(context).getTranslatedValue(value) != null) {
    return DemoLocalizations.of(context).getTranslatedValue(value)!;
  }
  return value;
}
