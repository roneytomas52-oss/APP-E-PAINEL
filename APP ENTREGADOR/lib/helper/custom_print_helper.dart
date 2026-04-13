import 'package:flutter/foundation.dart';

void customPrint(Object? text){
  if (kDebugMode) {
    print(text);
  }
}