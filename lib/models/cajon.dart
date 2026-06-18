import 'package:latlong2/latlong2.dart';

enum TipoCajon { normal, discapacitado, directivo }

class Cajon {
  final String id;
  final String nombre;
  final TipoCajon tipo;
  final LatLng punto;
  final bool disponible;
  final DateTime ultimoCambio;

  Cajon({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.punto,
    required this.disponible,
    required this.ultimoCambio,
  });
}

// Función para calcular el tiempo transcurrido
String tiempoTranscurrido(DateTime fecha) {
  final diferencia = DateTime.now().difference(fecha);
  
  if (diferencia.inSeconds < 60) {
    return '${diferencia.inSeconds} seg';
  }
  if (diferencia.inMinutes < 60) {
    return '${diferencia.inMinutes} min';
  }
  if (diferencia.inHours < 24) {
    return '${diferencia.inHours} h';
  }
  return '${diferencia.inDays} días';
}