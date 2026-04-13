  import 'package:flutter/material.dart';

  class OfferScreen extends StatefulWidget {
    final int? selectedIndex;
    final bool? canBack;
    const OfferScreen({super.key, this.selectedIndex = 0, this.canBack = false});

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> with TickerProviderStateMixin{

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
  