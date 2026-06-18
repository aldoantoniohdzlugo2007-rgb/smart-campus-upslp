import 'package:latlong2/latlong2.dart';
import '../models/cajon.dart';

final ahora = DateTime.now();

// Lista de datos de prueba
final List<Cajon> cajonesDemo = [
  Cajon(
    id: 'B07',
    nombre: 'B-07',
    tipo: TipoCajon.normal,
    punto: const LatLng(22.12090, -100.98312),
    disponible: true,
    ultimoCambio: ahora.subtract(const Duration(minutes: 5)),
  ),
  Cajon(
    id: 'B08',
    nombre: 'B-08',
    tipo: TipoCajon.normal,
    punto: const LatLng(22.12082, -100.98309),
    disponible: true,
    ultimoCambio: ahora.subtract(const Duration(minutes: 1)),
  ),
];