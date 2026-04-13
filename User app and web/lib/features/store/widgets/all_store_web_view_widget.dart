import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';

class AllStoreWebViewWidget extends StatefulWidget {
  const AllStoreWebViewWidget({super.key});

  @override
  State<AllStoreWebViewWidget> createState() => _AllStoreWebViewWidgetState();
}

class _AllStoreWebViewWidgetState extends State<AllStoreWebViewWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      Get.find<StoreController>().resetStoreData();
      Get.find<StoreController>().getStoreList(1, true);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title:  'all_stores'.tr,
      ),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: CustomScrollView(
        slivers: [
          // const AllStoreFilterWidget(),
          SliverToBoxAdapter(
            child: WebScreenTitleWidget(title: 'all_stores'.tr),
          ),


          SliverToBoxAdapter(
            child: GetBuilder<StoreController>(builder: (storeController) {
              return FooterView(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: PaginatedListView(
                    scrollController: _scrollController,
                    totalSize: storeController.storeModel?.totalSize,
                    offset: storeController.storeModel?.offset,
                    onPaginate: (int? offset) async {
                      print("--------------->");
                      await storeController.getStoreList(offset!, false);
                    },
                    gridColumns: 3,
                    itemView: ItemsView(
                      isStore: true, items: null,
                      stores: storeController.storeModel?.stores,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall,
                        vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
