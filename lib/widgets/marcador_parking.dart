import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/cajon.dart';

Marker construirMarcador(Cajon cajon, BuildContext context) {
  return Marker(
    point: cajon.punto,
    width: 45,
    height: 45,
    child: GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${cajon.nombre} | Estado: ${cajon.disponible ? "Libre" : "Ocupado"} \nÚltimo cambio: ${tiempoTranscurrido(cajon.ultimoCambio)}'),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: cajon.disponible ? Colors.green.withOpacity(0.85) : Colors.red.withOpacity(0.85),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
        ),
        child: const Icon(Icons.local_parking, color: Colors.white, size: 22),
      ),
    ),
  );
}