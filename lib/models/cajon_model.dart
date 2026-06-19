import 'package:cloud_firestore/cloud_firestore.dart';

class CajonModel {
  final String id;
  final String nombre;
  final bool disponible;
  final String tipo;
  final double x;
  final double y;
  final DateTime ultimoCambio;

  const CajonModel({
    required this.id,
    required this.nombre,
    required this.disponible,
    required this.tipo,
    required this.x,
    required this.y,
    required this.ultimoCambio,
  });

  factory CajonModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return CajonModel(
      id: doc.id,
      nombre: (data['nombre'] ?? doc.id).toString(),
      disponible: data['disponible'] == true,
      tipo: (data['tipo'] ?? 'normal').toString(),
      x: ((data['x'] ?? 0.5) as num).toDouble(),
      y: ((data['y'] ?? 0.5) as num).toDouble(),
      ultimoCambio: data['ultimoCambio'] is Timestamp
          ? (data['ultimoCambio'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}