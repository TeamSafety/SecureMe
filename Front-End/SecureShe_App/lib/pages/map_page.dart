import 'package:flutter/material.dart';
import 'package:my_app/models/panel_widget.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    final panelMaxHeight = MediaQuery.of(context).size.height * 0.45;

    return SlidingUpPanel(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
      parallaxEnabled: true,
      parallaxOffset: 0.05,
      minHeight: 50,
      maxHeight: panelMaxHeight,
      body: const Image(
        image: AssetImage('assets/images/mapImage.png'),
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      ),
      panelBuilder: (controller) => PanelWidget(
        controller: controller,
      ),
    );
  }
}
