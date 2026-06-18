import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong2.dart';
import '../data/cajones_demo.dart';
import 'marcador_parking.dart';

class MapaEstacionamiento extends StatelessWidget {
  const MapaEstacionamiento({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(22.1192, -100.9314), // Coordenadas UPSLP
        initialZoom: 16.5,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.upslp.smart_campus',
        ),
        MarkerLayer(
          markers: cajonesDemo.map((cajon) => construirMarcador(cajon, context)).toList(),
        ),
      ],
    );
  }
}