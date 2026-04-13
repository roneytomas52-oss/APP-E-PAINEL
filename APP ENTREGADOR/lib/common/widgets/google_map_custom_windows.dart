// // library;
//
// import 'dart:io';
// import 'package:flutter/material.dart';
//
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// /// Controller to add, update and control the custom info windows.
// class GoogleMapCustomWindowController {
//   /// Add custom [Widget] and [Marker]'s [LatLng] to [CustomMapInfoWindow] and make it visible.
//   Function(List<Widget>, List<LatLng>)? addInfoWindow;
//
//   /// Notifies [CustomMapInfoWindow] to redraw as per change in position.
//   VoidCallback? onCameraMove;
//
//   /// Hides [CustomMapInfoWindow].
//   VoidCallback? hideInfoWindow;
//
//   /// Holds [GoogleMapController] for calculating [CustomMapInfoWindow] position.
//   GoogleMapController? googleMapController;
//
//   void dispose() {
//     addInfoWindow = null;
//     onCameraMove = null;
//     hideInfoWindow = null;
//     googleMapController = null;
//   }
// }
//
// /// A stateful widget responsible to create widget based custom info window.
// class CustomMapInfoWindow extends StatefulWidget {
//   /// A [GoogleMapCustomWindowController] to manipulate [CustomMapInfoWindow] state.
//   final GoogleMapCustomWindowController controller;
//
//   /// Offset to maintain space between [Marker] and [CustomMapInfoWindow].
//   final Offset offset;
//
//   /// Height of [CustomMapInfoWindow].
//   final double height;
//
//   /// Width of [CustomMapInfoWindow].
//   final double width;
//
//   const CustomMapInfoWindow({
//     super.key,
//     required this.controller,
//     this.offset = const Offset(0, 50),
//     this.height = 50,
//     this.width = 100,
//   }) : assert(height >= 0),
//         assert(width >= 0);
//
//   @override
//   State<CustomMapInfoWindow> createState() => _CustomMapInfoWindowState();
// }
//
// class _CustomMapInfoWindowState extends State<CustomMapInfoWindow> {
//   bool _showNow = false;
//   List<double> _leftMargin = [0];
//   List<double> _topMargin = [0];
//   List<Widget>? _childs;
//   List<LatLng?>? _latLng;
//
//   @override
//   void initState() {
//     super.initState();
//     widget.controller.addInfoWindow = _addInfoWindow;
//     widget.controller.onCameraMove = _onCameraMove;
//     widget.controller.hideInfoWindow = _hideInfoWindow;
//   }
//
//   /// Calculate the position on [CustomMapInfoWindow] and redraw on screen.
//   void _updateInfoWindow() async {
//     if (_latLng == null ||
//         _childs == null ||
//         widget.controller.googleMapController == null) {
//       return;
//     }
//     double devicePixelRatio =
//     Platform.isAndroid ? MediaQuery.of(context).devicePixelRatio : 1.0;
//     // List<ScreenCoordinate> screenCoordinate = [];
//     List<double> left = [];
//     List<double> top = [];
//
//     for (LatLng? latLng in _latLng!) {
//       ScreenCoordinate screenCoordinate = await widget
//           .controller
//           .googleMapController!
//           .getScreenCoordinate(latLng!);
//       left.add(
//         (screenCoordinate.x.toDouble() / devicePixelRatio) -
//             ((widget.width / 2) + widget.offset.dx),
//       );
//       top.add(
//         (screenCoordinate.y.toDouble() / devicePixelRatio) -
//             (widget.offset.dy + widget.height),
//       );
//     }
//     setState(() {
//       _showNow = true;
//       _leftMargin = left;
//       _topMargin = top;
//     });
//   }
//
//   /// Assign the [Widget] and [Marker]'s [LatLng].
//   void _addInfoWindow(List<Widget> child, List<LatLng> latLng) {
//     _childs = child;
//     _latLng = latLng;
//     _updateInfoWindow();
//   }
//
//   /// Notifies camera movements on [GoogleMap].
//   void _onCameraMove() {
//     if (!_showNow) return;
//     _updateInfoWindow();
//   }
//
//   /// Disables [CustomMapInfoWindow] visibility.
//   void _hideInfoWindow() {
//     setState(() {
//       _showNow = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print('==========rrrr====> ${_leftMargin} // ${_leftMargin.length}');
//     if (_latLng == null ||
//         _latLng!.isEmpty ||
//         _childs == null ||
//         _childs!.isEmpty ||
//         _leftMargin.isEmpty || _leftMargin.length == 1) {
//       return const SizedBox.shrink();
//     }
//     return Stack(
//       children:
//       _latLng!.map((e) {
//         return Positioned(
//           left: _leftMargin[_latLng!.indexOf(e)],
//           top: _topMargin[_latLng!.indexOf(e)],
//           child: Visibility(
//             visible:
//             (_showNow == false ||
//                 (_leftMargin[_latLng!.indexOf(e)] == 0 &&
//                     _topMargin[_latLng!.indexOf(e)] == 0) ||
//                 _childs == null ||
//                 e == null)
//                 ? false
//                 : true,
//             child: SizedBox(
//               height: widget.height,
//               width: widget.width,
//               child: _childs![_latLng!.indexOf(e)],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
