import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class PaginatedListView extends StatefulWidget {
  final ScrollController scrollController;
  final Function(int? offset) onPaginate;
  final int? totalSize;
  final int? offset;
  final Widget itemView;
  final bool enabledPagination;
  final bool reverse;
  final int? gridColumns; // Number of columns in grid layout for desktop
  const PaginatedListView({super.key, required this.scrollController, required this.onPaginate, required this.totalSize,
    required this.offset, required this.itemView, this.enabledPagination = true, this.reverse = false,
    this.gridColumns,
  });

  @override
  State<PaginatedListView> createState() => _PaginatedListViewState();
}

class _PaginatedListViewState extends State<PaginatedListView> {
  int? _offset;
  late List<int?> _offsetList;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _offset = 1;
    _offsetList = [1];

    widget.scrollController.addListener(() {
      if (widget.scrollController.position.pixels == widget.scrollController.position.maxScrollExtent
          && widget.totalSize != null && !_isLoading && widget.enabledPagination) {
        if(mounted && !ResponsiveHelper.isDesktop(context)) {
          _paginate();
        }
      }
    });
  }

  void _paginate() async {
    int pageSize = (widget.totalSize! / 10).ceil();
    if (_offset! < pageSize && !_offsetList.contains(_offset!+1)) {

      setState(() {
        _offset = _offset! + 1;
        _offsetList.add(_offset);
        _isLoading = true;
      });
      await widget.onPaginate(_offset);
      setState(() {
        _isLoading = false;
      });

    }else {
      if(_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.offset != null) {
      _offset = widget.offset;
      _offsetList = [];
      for(int index=1; index<=widget.offset!; index++) {
        _offsetList.add(index);
      }
    }

    // show the "view more" button
    bool shouldShowViewMore = false;
    if (ResponsiveHelper.isDesktop(context) && widget.totalSize != null) {
      int pageSize = (widget.totalSize! / 10).ceil();
      bool hasMorePages = _offset! < pageSize && !_offsetList.contains(_offset! + 1);
      
      if (hasMorePages && widget.gridColumns != null && widget.gridColumns! > 0) {
        int currentItemsDisplayed = _offset! * 10;
        int remainingItems = widget.totalSize! - currentItemsDisplayed;
        shouldShowViewMore = remainingItems >= widget.gridColumns!;
      } else if (hasMorePages) {
        shouldShowViewMore = true;
      }
    }

    return Column(children: [

      widget.reverse ? const SizedBox() : widget.itemView,

      (ResponsiveHelper.isDesktop(context) && !shouldShowViewMore) ? const SizedBox() : Center(child: Padding(
        padding: (_isLoading || ResponsiveHelper.isDesktop(context)) ? const EdgeInsets.all(Dimensions.paddingSizeSmall) : EdgeInsets.zero,
        child: _isLoading ? const CircularProgressIndicator() : (ResponsiveHelper.isDesktop(context) && widget.totalSize != null) ? InkWell(
          onTap: _paginate,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              color: Theme.of(context).primaryColor,
            ),
            child: Text('view_more'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.white)),
          ),
        ) : const SizedBox(),
      )),

      widget.reverse ? widget.itemView : const SizedBox(),

    ]);
  }
}
