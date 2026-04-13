import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:sixam_mart_delivery/features/html/controllers/html_controller.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HtmlViewerScreen extends StatefulWidget {
  final bool isPrivacyPolicy;
  const HtmlViewerScreen({super.key, required this.isPrivacyPolicy});

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {

  @override
  void initState() {
    super.initState();

    Get.find<HtmlController>().getHtmlText(widget.isPrivacyPolicy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: CustomAppBarWidget(title: widget.isPrivacyPolicy ? 'privacy_policy'.tr : 'terms_condition'.tr),

      body: GetBuilder<HtmlController>(builder: (htmlController) {
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 5,
            )],
          ),
          margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: htmlController.htmlText != null ? SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            physics: const BouncingScrollPhysics(),
            child: HtmlWidget(
              htmlController.htmlText ?? '',
              key: Key(widget.isPrivacyPolicy ? 'privacy_policy' : 'terms_condition'),
              onTapUrl: (String url) {
                return launchUrlString(url, mode: LaunchMode.externalApplication);
              },
            ),
          ) : const Center(child: CircularProgressIndicator()),
        );
      }),
    );
  }
}
