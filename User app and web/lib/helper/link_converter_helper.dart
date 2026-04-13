import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/auth/screens/sign_up_screen.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';

class LinkConverter{

  static String? convertDeepLink(Uri? uri){
    String? link;
    if(uri != null) {
      if (kDebugMode) {
        print('Received Deep Link URI: $uri');
      }

      String host = uri.host;
      if(host.isNotEmpty && AppConstants.webHostedUrl.contains(host)) {
        link = uri.path;
        if(uri.queryParameters.isNotEmpty) {
          link += '?';
          uri.queryParameters.forEach((key, value) {
            link = '$link$key=$value&';
          });
          link = link!.substring(0, link!.length - 1);
        }
      }
    }
    if (kDebugMode) {
      print('Converted Deep Link path: $link');
    }

    ///home page: https://ammart-8bc78.web.app/?module=food&from-splash=false
    ///product details: https://ammart-8bc78.web.app/item-details/capsule-and-tablet-icon-illustration?id=403&page=item&module=grocery
    ///

    Get.find<SplashController>().setDeeplink(uri);

    navigateFromLink(link, uri: uri);
    return link;
  }

  static Future<void> navigateFromLink(String? link, {Uri? uri}) async {
    if(link != null) {
      print('====linked route config: ${Get.find<SplashController>().configModel}');
      if(Get.find<SplashController>().configModel == null) {
        print('======config data call from link converter helper');
       await Get.find<SplashController>().getConfigData(notificationBody: null, canRoute: false);
      }

      if(link.startsWith('/?module=')) {
        if (kDebugMode) {
          print('=======Navigating to initial route: $link');
        }
        String moduleId = uri?.queryParameters['module'] ?? '';
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.toNamed(RouteHelper.getInitialRoute(moduleId: moduleId, fromDeeplink: true));
        });
      } else if(link.startsWith(RouteHelper.store) && !GetPlatform.isWeb) {
        if (kDebugMode) {
          print('=======Navigating to store route: $link');
          ///store details: https://ammart-8bc78.web.app/store/hungry-puppets46?id=46&page=store&module=food
        }
        int storeID = int.tryParse(uri!.queryParameters['id'] ?? '') ?? 0;
        String moduleId = uri.queryParameters['module'] ?? '';
        String page = uri.queryParameters['page'] ?? '';
        String slug = link.split('/').last;
        Future.delayed(const Duration(milliseconds: 500), () {
          print('======store route parameters: storeID: $storeID, moduleId: $moduleId, page: $page, slug: $slug');
          Get.toNamed(RouteHelper.getStoreRoute(id: storeID, page: page, slug: slug, moduleId: moduleId, fromDeeplink: true));
        });
      } else if(link.startsWith(RouteHelper.itemDetails) && !GetPlatform.isWeb) {
        if (kDebugMode) {
          print('=======Navigating to item details route: $link');
        }
        int itemID = int.tryParse(uri!.queryParameters['id'] ?? '') ?? 0;
        String moduleId = uri.queryParameters['module'] ?? '';
        String slug = link.split('/').last;
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.toNamed(RouteHelper.getItemDetailsRoute(itemID, false, slug, slug: slug, moduleId: moduleId, fromDeeplink: true));
        });
      } else if(link.startsWith(RouteHelper.referAndEarn) && !GetPlatform.isWeb) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if(AuthHelper.isLoggedIn()) {
            Get.toNamed(RouteHelper.getReferAndEarnRoute());
          } else {
            String? referCode = uri!.queryParameters['code'];
            Get.to(()=> SignUpScreen(exitFromApp: false, referCode: referCode));
          }
        });
      } else {
        if (kDebugMode) {
          print('=======Unknown deep link route: $link');
        }
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        });
      }
    }
  }

}

