import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SmartCampusApp());
}

class SmartCampusApp extends StatelessWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Campus UPSLP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  Cajon? cajonSeleccionado;

  static const LatLng centroUpslp = LatLng(22.12115, -100.98370);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff071426),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 58,
              width: double.infinity,
              alignment: Alignment.center,
              color: const Color(0xff071426),
              child: const Text(
                'Estacionamiento UPSLP – Calle Sara Rivera',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('cajones_estacionamiento')
                    .orderBy('nombre')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Error de conexión con Firebase',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final cajones = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final nombre = data['nombre'] ?? doc.id;
                    final disponible = data['disponible'] == true;

                    final geo = data['punto'] as GeoPoint?;
                    final punto = geo != null
                        ? LatLng(geo.latitude, geo.longitude)
                        : centroUpslp;

                    final x = (data['x'] as num?)?.toDouble();
                    final y = (data['y'] as num?)?.toDouble();

                    final posicion = x != null && y != null
                        ? Offset(x, y)
                        : posicionCroquis(nombre);

                    final ultimoCambioFirebase = data['ultimoCambio'];
                    final ultimoCambio = ultimoCambioFirebase is Timestamp
                        ? ultimoCambioFirebase.toDate()
                        : DateTime.now();

                    return Cajon(
                      nombre: nombre,
                      punto: punto,
                      posicion: posicion,
                      disponible: disponible,
                      ultimoCambio: ultimoCambio,
                    );
                  }).toList();

                  final disponibles = cajones.where((c) => c.disponible).length;
                  final ocupados = cajones.length - disponibles;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final esPantallaChica = constraints.maxWidth < 1000;

                      return Row(
                        children: [
                          Expanded(
                            flex: esPantallaChica ? 6 : 7,
                            child: MapaEstacionamiento(
                              cajones: cajones,
                              centro: centroUpslp,
                              cajonSeleccionado: cajonSeleccionado,
                              onSeleccionar: (cajon) {
                                setState(() {
                                  cajonSeleccionado = cajon;
                                });
                              },
                            ),
                          ),
                          Container(width: 1, color: Colors.white24),
                          Expanded(
                            flex: esPantallaChica ? 4 : 3,
                            child: PanelInformacion(
                              cajones: cajones,
                              disponibles: disponibles,
                              ocupados: ocupados,
                              cajonSeleccionado: cajonSeleccionado,
                              onSeleccionar: (cajon) {
                                setState(() {
                                  cajonSeleccionado = cajon;
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapaEstacionamiento extends StatelessWidget {
  final List<Cajon> cajones;
  final LatLng centro;
  final Cajon? cajonSeleccionado;
  final void Function(Cajon cajon) onSeleccionar;

  const MapaEstacionamiento({
    super.key,
    required this.cajones,
    required this.centro,
    required this.cajonSeleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/croquis_upslp.png',
            fit: BoxFit.fill,
          ),
        ),
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: cajones.map((cajon) {
                  final seleccionado =
                      cajonSeleccionado?.nombre == cajon.nombre;

                  final posicion = cajon.posicion;

                  return Positioned(
                    left: constraints.maxWidth * posicion.dx - 7,
                    top: constraints.maxHeight * posicion.dy - 7,
                    child: GestureDetector(
                      onTap: () => onSeleccionar(cajon),
                      child: MarcadorParking(
                        disponible: cajon.disponible,
                        seleccionado: seleccionado,
                        size: 14,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xff071426).withOpacity(0.92),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                MarcadorLeyenda(color: Colors.green, texto: 'Disponible'),
                SizedBox(width: 20),
                MarcadorLeyenda(color: Colors.red, texto: 'Ocupado'),
              ],
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xff071426).withOpacity(0.92),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Última actualización: hace unos segundos  ↻',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

Offset posicionCroquis(String nombre) {
  switch (nombre) {
    case 'A-01':
      return const Offset(0.143, 0.150);
    case 'A-02':
      return const Offset(0.143, 0.175);
    case 'A-03':
      return const Offset(0.143, 0.200);
    case 'A-04':
      return const Offset(0.143, 0.225);
    case 'A-05':
      return const Offset(0.143, 0.250);
    case 'A-06':
      return const Offset(0.143, 0.275);
    case 'A-07':
      return const Offset(0.143, 0.300);
    case 'A-08':
      return const Offset(0.143, 0.325);
    case 'A-09':
      return const Offset(0.143, 0.350);
    case 'A-10':
      return const Offset(0.143, 0.375);
    case 'A-11':
      return const Offset(0.143, 0.400);
    case 'A-12':
      return const Offset(0.143, 0.425);
    case 'A-13':
      return const Offset(0.143, 0.450);
    case 'A-14':
      return const Offset(0.143, 0.475);
    case 'A-15':
      return const Offset(0.143, 0.500);
    case 'A-16':
      return const Offset(0.143, 0.525);
    case 'A-17':
      return const Offset(0.143, 0.550);
    case 'A-18':
      return const Offset(0.143, 0.575);
    case 'A-19':
      return const Offset(0.143, 0.600);
    case 'A-20':
      return const Offset(0.143, 0.625);
    case 'A-21':
      return const Offset(0.143, 0.650);
    case 'A-22':
      return const Offset(0.143, 0.675);
    case 'A-23':
      return const Offset(0.143, 0.700);
    case 'A-24':
      return const Offset(0.143, 0.725);

    case 'B-01':
      return const Offset(0.252, 0.217);
    case 'B-02':
      return const Offset(0.252, 0.242);
    case 'B-03':
      return const Offset(0.252, 0.267);
    case 'B-04':
      return const Offset(0.252, 0.292);
    case 'B-05':
      return const Offset(0.252, 0.317);
    case 'B-06':
      return const Offset(0.252, 0.342);
    case 'B-07':
      return const Offset(0.252, 0.367);
    case 'B-08':
      return const Offset(0.252, 0.392);

    default:
      return const Offset(0.50, 0.50);
  }
}

class PanelInformacion extends StatelessWidget {
  final List<Cajon> cajones;
  final int disponibles;
  final int ocupados;
  final Cajon? cajonSeleccionado;
  final void Function(Cajon cajon) onSeleccionar;

  const PanelInformacion({
    super.key,
    required this.cajones,
    required this.disponibles,
    required this.ocupados,
    required this.cajonSeleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffedf1f5),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TarjetaResumen(
            disponibles: disponibles,
            ocupados: ocupados,
            total: cajones.length,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TarjetaDetalle(
              cajones: cajones,
              cajonSeleccionado: cajonSeleccionado,
              onSeleccionar: onSeleccionar,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Smart Campus UPSLP – Monitoreo en tiempo real',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class TarjetaResumen extends StatelessWidget {
  final int disponibles;
  final int ocupados;
  final int total;

  const TarjetaResumen({
    super.key,
    required this.disponibles,
    required this.ocupados,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const EncabezadoTarjeta(titulo: 'Resumen general'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DatoResumen(
                  numero: disponibles,
                  texto: 'Disponibles',
                  color: Colors.green,
                ),
                SeparadorVertical(),
                DatoResumen(
                  numero: ocupados,
                  texto: 'Ocupados',
                  color: Colors.red,
                ),
                SeparadorVertical(),
                DatoResumen(
                  numero: total,
                  texto: 'Total',
                  color: Colors.blueGrey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TarjetaDetalle extends StatelessWidget {
  final List<Cajon> cajones;
  final Cajon? cajonSeleccionado;
  final void Function(Cajon cajon) onSeleccionar;

  const TarjetaDetalle({
    super.key,
    required this.cajones,
    required this.cajonSeleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const EncabezadoTarjeta(titulo: 'Detalle de cajones'),
          Expanded(
            child: ListView.separated(
              itemCount: cajones.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final cajon = cajones[index];
                final seleccionado =
                    cajonSeleccionado?.nombre == cajon.nombre;

                return Material(
                  color: seleccionado
                      ? const Color(0xffe8f1ff)
                      : Colors.transparent,
                  child: InkWell(
                    onTap: () => onSeleccionar(cajon),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          MarcadorParking(
                            disponible: cajon.disponible,
                            seleccionado: seleccionado,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cajón ${cajon.nombre}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  cajon.disponible ? 'Disponible' : 'Ocupado',
                                  style: TextStyle(
                                    color: cajon.disponible
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                cajon.disponible
                                    ? 'Desocupado hace'
                                    : 'Ocupado hace',
                                style: const TextStyle(fontSize: 11),
                              ),
                              Text(
                                tiempoTranscurrido(cajon.ultimoCambio),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.access_time,
                            color: Colors.blueGrey,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EncabezadoTarjeta extends StatelessWidget {
  final String titulo;

  const EncabezadoTarjeta({
    super.key,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      alignment: Alignment.center,
      color: const Color(0xff071426),
      child: Text(
        titulo,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
    );
  }
}

class DatoResumen extends StatelessWidget {
  final int numero;
  final String texto;
  final Color color;

  const DatoResumen({
    super.key,
    required this.numero,
    required this.texto,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$numero',
            style: TextStyle(
              color: color,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class SeparadorVertical extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 52,
      color: Colors.black12,
    );
  }
}

class MarcadorParking extends StatelessWidget {
  final bool disponible;
  final bool seleccionado;
  final double size;

  const MarcadorParking({
    super.key,
    required this.disponible,
    this.seleccionado = false,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    final color = disponible ? Colors.green : Colors.red;
    final markerSize = seleccionado ? size + 3 : size;

    return Container(
      width: markerSize,
      height: markerSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: seleccionado ? Colors.white : Colors.white70,
          width: seleccionado ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 3,
            offset: Offset(1, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'P',
        style: TextStyle(
          color: Colors.white,
          fontSize: markerSize * 0.58,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class MarcadorLeyenda extends StatelessWidget {
  final Color color;
  final String texto;

  const MarcadorLeyenda({
    super.key,
    required this.color,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white70, width: 2),
          ),
          alignment: Alignment.center,
          child: const Text(
            'P',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class Cajon {
  final String nombre;
  final LatLng punto;
  final Offset posicion;
  final bool disponible;
  final DateTime ultimoCambio;

  const Cajon({
    required this.nombre,
    required this.punto,
    required this.posicion,
    required this.disponible,
    required this.ultimoCambio,
  });
}

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