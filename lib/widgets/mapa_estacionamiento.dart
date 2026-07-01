import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cajon.dart';
import 'marcador_parking.dart';

class MapaEstacionamiento extends StatelessWidget {
  const MapaEstacionamiento({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // 1. Escucha la colección que creaste en Firebase
      stream: FirebaseFirestore.instance.collection('cajones_estacionamiento').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar los cajones'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Extrae los documentos de Firebase
        final documentos = snapshot.data!.docs;
        
        // 3. Convierte cada documento en un Marcador
        final marcadores = documentos.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final geoPoint = data['punto'] as GeoPoint;

          // Construimos tu objeto Cajon con los datos de la nube
          final cajonNube = Cajon(
            id: doc.id,
            nombre: data['nombre'] ?? '',
            tipo: TipoCajon.normal,
            punto: LatLng(geoPoint.latitude, geoPoint.longitude),
            disponible: data['disponible'] ?? false,
            ultimoCambio: DateTime.now(), // Por ahora usamos la hora actual
          );

          // Llamamos a tu función intacta
          return construirMarcador(cajonNube, context);
        }).toList();

        // 4. Dibuja el mapa con la capa de Carto y los marcadores en vivo
        return FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(22.1192, -100.9314),
            initialZoom: 16.5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.upslp.smartcampus',
            ),
            MarkerLayer(
              markers: marcadores,
            ),
          ],
        );
      },
    );
  }
}