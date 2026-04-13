import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ShallowRouterHelper {

  static void updateParameter(String key, String value) {
    if(kIsWeb) {
      if (Get.parameters.containsKey(key) && Get.parameters[key] == value) {
        return;
      }
      final newParams = Map<String, String>.from(Get.parameters);
      newParams[key] = value;
      String currentPath = Get.currentRoute.split('?').first;
      String queryString = Uri(queryParameters: newParams).query;
      Get.offNamed('$currentPath?$queryString', preventDuplicates: false);
    }
  }

}